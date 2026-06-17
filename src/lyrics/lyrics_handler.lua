--[[ lyrics_handler.lua — orchestrates synced lyrics.

  OnSongStart : resolve song -> load cached LRC (or queue a fetch request)
  Tick        : read the music playhead, advance the engine, update the HUD
  OnSongEnd   : clear + hide
  Toggle      : enable/disable at runtime

  Playhead = PagodaMusicSubsystem:GetTimelinePosition() (seconds; freezes on pause,
  resets on restart) — so sync is drift-free with no special pause handling. --]]
local M = {}

local log = require("utils.log")
local cfg = require("config")
local resolver = require("lyrics.lyrics_resolver")
local store = require("lyrics.lyrics_store")
local lrc = require("lyrics.lrc")
local engine = require("lyrics.lyrics_engine")
local lyrics_hud = require("lyrics.lyrics_hud")

-- DEBUG: last Tick stage, written to a file so a native crash localizes precisely.
local STAGE = "./ue4ss/Mods/Marquee/Scripts/data/lyrics/_tick_stage.txt"
local function mark(s)
  if not cfg.LYRICS_DEBUG then return end   -- off by default: no per-tick disk I/O
  local f = io.open(STAGE, "w")
  if f then f:write(tostring(s)); f:close() end
end

M.enabled = (cfg.LYRICS_ENABLED ~= false)
M._tickCount = 0
M._subsys = nil
M._active = false   -- a song WITH lyrics is currently loaded

-- "lyrics not found" notice: hold at full, then fade out (counted in Tick ticks)
local NOTICE_HOLD = cfg.LYRICS_NOTICE_HOLD_TICKS or 28
local NOTICE_FADE = cfg.LYRICS_NOTICE_FADE_TICKS or 18
M._notice = 0   -- remaining notice ticks (hold+fade); 0 = inactive
M._songKey = nil
M._songOffset = 0   -- per-song lyric offset (sec): + = lyrics earlier
M._offsetReadout = 0

local function getSubsys()
  if M._subsys then
    local ok, valid = pcall(function() return M._subsys:IsValid() end)
    if ok and valid then return M._subsys end
  end
  local insts = FindAllOf("PagodaMusicSubsystem")
  M._subsys = (insts and insts[1]) or nil
  return M._subsys
end

function M.EnsureUI()
  if not lyrics_hud.IsValid() then
    lyrics_hud.Create()
  end
end

function M.OnSongStart(state)
  if not M.enabled then return end
  engine.Clear()
  M._active = false
  M._tickCount = 0
  M._notice = 0
  M._songKey = nil
  M._songOffset = 0
  M._offsetReadout = 0

  local info = resolver.Resolve(state)
  if not info then
    log.debug("[lyrics] could not resolve current song")
    lyrics_hud.Hide()   -- nothing to show; never leave a bar from the prior song
    return
  end

  M._songKey = info.key
  M._songOffset = store.LoadOffset(info.key)   -- per-song manual sync correction

  -- Load + parse BEFORE drawing anything: the karaoke bar is created only when we
  -- actually have lyrics (or a brief notice to show), never just to sit there empty.
  local text = store.LoadLrc(info.key)
  local parsed = text and lrc.parse(text) or nil
  if parsed and #parsed.lines > 0 then
    engine.Load(parsed)
    M._active = true
    M.EnsureUI()                 -- create the bar now that there's something to show
    lyrics_hud.SetActive(true)
    lyrics_hud.SetOpacity(1)
    lyrics_hud.Update("", "")    -- start blank; Tick fills the current line
    -- confirm lyrics are loaded if there's a wait before the first line
    local firstT = parsed.lines[1] and parsed.lines[1].t or 0
    if cfg.LYRICS_SHOW_NOTICE ~= false and firstT > (cfg.LYRICS_READY_MIN_WAIT or 4) then
      M._notice = NOTICE_HOLD + NOTICE_FADE
      lyrics_hud.ShowNotice("♪ lyrics ready")
    end
    log.info(string.format("[lyrics] loaded %d lines for '%s' (key=%s)",
      #parsed.lines, tostring(info.title), info.key))
    return
  end

  -- No synced lyrics. Show a brief "not found" notice (Tick tears the bar down once
  -- it fades), or draw nothing at all when notices are disabled.
  if cfg.LYRICS_SHOW_NOTICE ~= false then
    M.EnsureUI()
    lyrics_hud.SetActive(true)
    M._notice = NOTICE_HOLD + NOTICE_FADE
    lyrics_hud.ShowNotice("♪ lyrics not found")
  else
    lyrics_hud.Hide()
  end

  -- No cached LRC. dadtool works off the boot catalog manifest (_catalog.jsonl), which already
  -- lists every song — so we no longer queue individual songs here; just note it for the log.
  log.debug("[lyrics] no synced lyrics for key=" .. info.key)
end

function M.OnSongEnd()
  engine.Clear()
  M._active = false
  M._notice = 0
  lyrics_hud.Hide()   -- HIDE not destroy: reuse the bar across songs to avoid create/destroy churn
                      -- (avoids rebuilding the bar every song); GC'd on map change anyway
end

function M.Tick()
  if not M.enabled then return end
  if not lyrics_hud.IsValid() then return end

  -- fade the transient notice (runs even when no song lyrics are active)
  if M._notice > 0 then
    M._notice = M._notice - 1
    local alpha = (M._notice < NOTICE_FADE) and (M._notice / NOTICE_FADE) or 1.0
    lyrics_hud.SetOpacity(alpha)
    if M._notice <= 0 then
      lyrics_hud.SetOpacity(1)
      lyrics_hud.Hide()   -- reuse the bar; the lyric Tick re-shows it below when lyrics are active
    end
    return   -- while a notice is showing it takes precedence over lyric display
  end

  if not M._active then return end

  local subsys = getSubsys()
  if not subsys then return end

  -- Instrument EVERY tick (whole song) so a crash localizes precisely:
  --   marker == "done …"  -> last lyrics tick finished; crash was NOT in lyrics
  --   marker == a stage    -> crash WAS in lyrics, at that exact call (+ time/line)

  -- Only touch the playhead while the song is actually PLAYING (count-in not ready).
  local playing = false
  pcall(function() playing = (subsys:IsSongPlaying() == true) end)
  if not playing then return end

  local ok, pos = pcall(function() return subsys:GetTimelinePosition() end)
  if not ok or type(pos) ~= "number" then return end
  pos = pos + (cfg.LYRICS_OFFSET_SEC or 0) + (M._songOffset or 0)

  local cur, nxt = engine.At(pos)

  -- brief on-screen readout right after a nudge
  if M._offsetReadout and M._offsetReadout > 0 then
    M._offsetReadout = M._offsetReadout - 1
    if cur == nil or cur == "" then
      cur = string.format("lyric offset %+.1fs", M._songOffset or 0)
    else
      nxt = string.format("[offset %+.1fs]", M._songOffset or 0)
    end
  end

  -- crash localizer (only when cfg.LYRICS_DEBUG): write ONLY on a line change, never
  -- per tick — so even when enabled it's well under 1 write/sec (SSD-safe).
  if cur ~= M._lastMarkedCur then
    M._lastMarkedCur = cur
    mark(string.format("t=%.1f cur=%s", pos, tostring(cur and cur:sub(1, 48) or "")))
  end
  lyrics_hud.Update(cur or "", nxt or "")
end

-- Live per-song lyric-sync calibration (saved per song to <key>.offset).
function M.NudgeOffset(delta)
  if not M._songKey or M._songKey == "" then return end
  M._songOffset = (M._songOffset or 0) + delta
  store.SaveOffset(M._songKey, M._songOffset)
  M._offsetReadout = 30
  log.info(string.format("[lyrics] offset %s = %+.2fs", M._songKey, M._songOffset))
end

function M.ResetOffset()
  if not M._songKey or M._songKey == "" then return end
  M._songOffset = 0
  store.SaveOffset(M._songKey, 0)
  M._offsetReadout = 30
  log.info("[lyrics] offset reset for " .. tostring(M._songKey))
end

-- Dump the FULL catalog manifest (_catalog.jsonl: every in-game + imported song's current key
-- + title/artist) so dadtool always has the complete song list to generate lyrics from. No
-- per-song queue. Returns the count seen (>=0), or nil if the catalog isn't loaded yet (caller
-- retries). The main.lua trigger runs this once per game load.
-- Process one catalog entry (which may be a wrapped TArray element) into the manifest.
local function handleSong(elem, acc)
  pcall(function()
    local song = elem
    pcall(function() if song and song.get then song = song:get() end end)   -- unwrap wrapped element
    if not song or not song:IsValid() then return end
    local full = song:GetFullName()
    if not full or full:find("Default__") then return end   -- skip the class-default object
    acc.seen = acc.seen + 1
    local st = { SongName = song.SongName:ToString(), AssetPath = full,
                 SongUniqueID = song:GetImportedSongUniqueID() }
    pcall(function() st.SongIsImported = song.bImportedSong end)
    pcall(function() st.SongLengthSec = song.SongLengthSec end)
    pcall(function()
      local pb = song.PerformedBy
      local pn = (pb and #pb) or 0
      if type(pn) == "number" and pn >= 1 and pb[1] ~= nil then st.SongArtist = pb[1]:ToString() end
    end)
    local info = resolver.Resolve(st)
    if info and info.key then
      acc.manifest[#acc.manifest + 1] = info   -- record EVERY song into the manifest (no per-song queue)
    end
  end)
end

function M.DumpCatalogManifest()
  if not M.enabled then return 0 end
  local cats = FindAllOf("PagodaSongCatalogSubsystem")
  if not cats or #cats == 0 then return nil end
  local sub = cats[1]
  local arr = nil
  pcall(function() arr = sub:GetAllSongs() end)       -- official BlueprintPure getter
  if not arr then pcall(function() arr = sub.SongAssets end) end   -- fall back to backing array
  if not arr then return nil end

  local acc = { seen = 0, manifest = {} }
  -- object-pointer TArrays iterate cleanest via ForEach; fall back to numeric indexing
  pcall(function() arr:ForEach(function(_, e) handleSong(e, acc) end) end)
  if acc.seen == 0 then
    local n = 0; pcall(function() n = #arr end)
    for i = 1, n do handleSong(arr[i], acc) end
  end

  if acc.seen == 0 then return nil end   -- catalog not populated with real songs yet -> caller retries
  pcall(function() store.WriteCatalog(acc.manifest) end)   -- full current-catalog snapshot for dadtool
  log.info(string.format("[lyrics] catalog manifest: %d songs dumped for dadtool", #acc.manifest))
  return acc.seen
end

function M.Toggle()
  M.enabled = not M.enabled
  lyrics_hud.SetActive(M.enabled)
  log.info("[lyrics] " .. (M.enabled and "enabled" or "disabled"))
  return M.enabled
end

return M
