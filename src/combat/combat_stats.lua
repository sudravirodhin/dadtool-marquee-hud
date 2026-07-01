--[[ combat_stats.lua — reads Dead as Disco's OWN performance signals. No hooks.

  The game grades on Score + Combo + Sync Meter + Multiplier (full API in the
  dad-combat-stats-api memory). We POLL these on the HUD loop and snapshot them
  at song end — a handful of safe getter/attribute reads, never intercepting moves.
  That's the whole point of the pivot: read the values the game already computes
  (the same tallies it uses for unlocks) instead of intercepting individual moves.

  Everything here is pcall-guarded; any read can fail to nil without breaking a tick. --]]
local M = {}

local UEHelpers = require("UEHelpers")
local log = require("utils.log")
local cfg = require("config")

local function call_is_valid(o)
  return o:IsValid()
end

local function is_valid(o)
  if not o then return false end
  local t = type(o)
  if t == "table" then return true end
  if t == "userdata" then
    local ok, res = pcall(call_is_valid, o)
    return not ok or res == true
  end
  return false
end

local function is_indexable(obj)
  return is_valid(obj)
end

local function safe(fn) local ok, r = pcall(fn); if ok then return r end end
local function valid(o) return is_valid(o) end

-- ---- cached handles (re-fetched whenever they go invalid, e.g. after a map load) ----
local _diagged = false   -- one-shot move-key diagnostic (logs once ever, not per read)
local function scoreComp()
  local pc = safe(function() return is_indexable(UEHelpers) and UEHelpers.GetPlayerController() end)
  local sc = (pc and is_indexable(pc) and safe(function() return pc:GetScoreComponent() end)) or nil
  return valid(sc) and sc or nil
end
local function playerState()
  local pc = safe(function() return is_indexable(UEHelpers) and UEHelpers.GetPlayerController() end)
  local ps = (pc and is_indexable(pc) and safe(function() return pc.PlayerState end)) or nil
  return valid(ps) and ps or nil
end

local _musicSubsys = nil
local function GetMusicSubsystem()
  if _musicSubsys and _musicSubsys:IsValid() then return _musicSubsys end
  local insts = FindAllOf("PagodaMusicSubsystem")
  _musicSubsys = (insts and insts[1]) or nil
  return valid(_musicSubsys) and _musicSubsys or nil
end

-- Read a GAS attribute's live value: the field is an FGameplayAttributeData, value
-- lives in .CurrentValue (plain numbers pass straight through).
local function attr(attrSet, name)
  if not is_indexable(attrSet) then return nil end
  local a = safe(function() return attrSet[name] end)
  if a == nil then return nil end
  if type(a) == "number" then return a end
  if not is_indexable(a) then return nil end
  local cv = safe(function() return a.CurrentValue end)
  if type(cv) == "number" then return cv end
  return nil
end

local function playerOnlyAttrs()
  local ps = playerState()
  if not ps then return nil end
  local poas = safe(function() return ps.PlayerOnlyAttributeSet end)
  return valid(poas) and poas or nil
end

--[[ ---- live snapshot (call each HUD tick) ----
  Returns a flat table of what the player is doing RIGHT NOW. Any field may be nil
  if that source isn't ready yet (count-in, between songs); callers must tolerate nil. --]]
function M.Poll()
  local out = {}
  local sc = scoreComp()
  if sc then
    out.score = safe(function() return sc:GetCombatScore() end)
  end
  local poas = playerOnlyAttrs()
  if poas then
    -- combo intentionally NOT polled: the game already shows it (it IS the beat counter),
    -- so a Combo readout duplicates the native HUD and wastes a per-tick attribute read.
    -- Max combo is read once at song end via GetMaxComboCount instead.
    out.sync    = attr(poas, "MusicSyncMeter")
    out.maxSync = attr(poas, "MaxMusicSyncMeter")
    out.mult    = attr(poas, "CombatScoreGainMult")
  end
  local subsys = GetMusicSubsystem()
  if subsys then
    out.bpm = safe(function() return subsys:GetBPM() end)
  end
  return out
end

-- Sync meter as a 0..1 fraction of its max (the rhythm "how perfect am I" gauge).
function M.SyncFraction(snap)
  if not snap or type(snap.sync) ~= "number" then return nil end
  local mx = (type(snap.maxSync) == "number" and snap.maxSync > 0) and snap.maxSync or 140
  return math.max(0, math.min(1, snap.sync / mx))
end



--[[ ---- running accumulation (folds a snapshot into the session state) ----
  Builds the avg/peak sync + "time at max sync" streak that stand in for
  "concurrent perfects", plus tracks the live max combo. Pure arithmetic. --]]
function M.Accumulate(state, snap)
  if not state or not snap then return end
  local f = M.SyncFraction(snap)
  if f then
    state.SyncSamples = (state.SyncSamples or 0) + 1
    state.SyncSum     = (state.SyncSum or 0) + f
    state.SyncPeak    = math.max(state.SyncPeak or 0, f)
  end
  if type(snap.score) == "number" then state.TotalScore = snap.score end
  if type(snap.mult)  == "number" then state.Multiplier = snap.mult end
  if type(snap.bpm)   == "number" and snap.bpm > 0 then state.Bpm = snap.bpm end

  -- Capture the per-move breakdown: either throughout play if configured (throttled),
  -- or safely during the song's ending window (last 3 seconds) when combat has ceased (unthrottled).
  local shouldPollThrottled = cfg.POLL_MOVE_SCORES_IN_GAME
  local shouldPollUnthrottled = false

  if not shouldPollThrottled then
    local subsys = GetMusicSubsystem()
    if subsys then
      local pos = safe(function() return subsys:GetTimelinePosition() end)
      local len = state.SongLengthSec or safe(function() return subsys:GetSongLengthSeconds() end)
      if type(pos) == "number" and type(len) == "number" and len > 3 then
        shouldPollUnthrottled = (pos >= len - 3.0)
      end
    end
  end

  if shouldPollThrottled then
    state.__moveTick = (state.__moveTick or 0) + 1
    if state.__moveTick % 3 == 0 then
      local m = M.ReadMoveScores()
      if #m > 0 then state.MoveScores = m end
    end
  elseif shouldPollUnthrottled then
    local m = M.ReadMoveScores()
    if #m > 0 then state.MoveScores = m end
  end

  -- 1. PB Ghost Tracker (delta display)
  state.PbDelta = nil
  if state.CachedPB and type(state.CachedPB.highScore) == "number" and state.CachedPB.highScore > 0 then
    local subsys = GetMusicSubsystem()
    if subsys then
      local pos = safe(function() return subsys:GetTimelinePosition() end)
      local len = state.SongLengthSec or safe(function() return subsys:GetSongLengthSeconds() end)
      if type(pos) == "number" and type(len) == "number" and len > 0 then
        local expected = state.CachedPB.highScore * (pos / len)
        state.PbDelta = (state.TotalScore or 0) - expected
      end
    end
  end

  -- 3. Hype status (rolling average of sync accuracy over the last 10s -> 25 samples)
  state.RecentSync = state.RecentSync or {}
  if f then
    table.insert(state.RecentSync, f)
    if #state.RecentSync > 25 then
      table.remove(state.RecentSync, 1)
    end
    local sum = 0
    for _, v in ipairs(state.RecentSync) do sum = sum + v end
    state.RecentSyncAvg = sum / #state.RecentSync

    if #state.RecentSync >= 5 and state.RecentSyncAvg >= 0.90 then
      state.HypeStatus = "ON FIRE"
    else
      state.HypeStatus = "—"
    end
  else
    state.HypeStatus = "—"
  end
end

function M.AvgSync(state)
  if not state or not state.SyncSamples or state.SyncSamples == 0 then return nil end
  return state.SyncSum / state.SyncSamples
end

--[[ ---- per-move score breakdown (read at song end) ----
  CombatActionScores is a TMap<action, score> on the score component's ScoreBreakdown.
  Confirmed iterable via :ForEach on this UE4SS build (keys/values arrive wrapped, so
  :get() each). Returns a list sorted by score desc: { {move=<raw key str>, score=n}, ... }.
  NOTE: the key's friendly name mapping is refined once we see the raw key format in-game. --]]
-- The CombatActionScores map is keyed by a UScript Struct (the game IDs combat actions
-- by a struct — most likely an FGameplayTag). Pull a readable name out of it; return nil
-- if we can't, so the UI shows a clean fallback label rather than a pointer.
local function moveKeyName(key)
  if key == nil then return nil end
  if type(key) == "string" or type(key) == "number" then return tostring(key) end
  if not is_indexable(key) then return nil end
  -- FGameplayTag.TagName is an FName -> "Family.Action"
  local n = safe(function()
    local t = key.TagName
    return t and is_indexable(t) and t.ToString and t:ToString()
  end)
  if type(n) == "string" and n ~= "" and n ~= "None" then return n end
  -- other common identifier fields (some may wrap their own TagName)
  for _, f in ipairs({ "ActionTag", "GameplayTag", "Tag", "Name", "ActionName" }) do
    local v = safe(function()
      local x = key[f]
      if type(x) == "string" then return x end
      if type(x) == "userdata" and is_indexable(x) then
        local tag = x.TagName
        if is_indexable(tag) and tag.ToString then
          return tag:ToString()
        end
        if x.ToString then
          return x:ToString()
        end
      end
    end)
    if type(v) == "string" and v ~= "" and v ~= "None" then return v end
  end
  return nil
end

function M.ReadMoveScores()
  local sc = scoreComp()
  if not sc then return {} end
  local sb = safe(function() return sc.ScoreBreakdown end)
  local map = sb and safe(function() return sb.CombatActionScores end)
  if not map then return {} end

  local out = {}
  safe(function()
    map:ForEach(function(k, v)
      local key = safe(function() return is_indexable(k) and k.get and k:get() end)
      local val = safe(function() return is_indexable(v) and v.get and v:get() end)
      if type(val) ~= "number" then val = safe(function() return is_indexable(v) and tonumber(v) end) end
      -- one-shot diagnostic on the first key ever seen, so we can finalize the name extraction
      if not _diagged then
        _diagged = true
        log.debug(string.format("[combat] move-key diag: get=%s | k:ToString=%s | TagName=%s",
          tostring(key),
          tostring(safe(function() return is_indexable(k) and k:ToString() end)),
          tostring(safe(function() return is_indexable(key) and key.TagName and key.TagName:ToString() end))))
      end
      if type(val) == "number" then
        local name = moveKeyName(key)
        if not name then
          local s = safe(function() return is_indexable(k) and k:ToString() end)   -- wrapped-param repr, sometimes the tag
          if type(s) == "string" and not s:find("Struct") and s ~= "" then name = s end
        end
        out[#out + 1] = { move = name, raw = tostring(key), score = val }
      end
    end)
  end)
  table.sort(out, function(a, b) return a.score > b.score end)
  return out
end

-- The game's own level grade (meta-progression Stars). nil if unavailable (e.g. Infinite Disco).
function M.ReadStars()
  local ps = playerState()
  if not ps then return nil end
  local pd = safe(function() return ps.PlaythroughData end)
  if not valid(pd) then return nil end
  return safe(function() return pd:GetStars() end)
end

-- Snapshot everything into state at song end (for the results screen + XP).
function M.CaptureFinal(state)
  if not state then return end
  if state.__capturedFinal then return end
  state.__capturedFinal = true

  local snap = M.Poll()
  M.Accumulate(state, snap)
  -- max combo straight from the score component (we no longer poll combo each tick)
  local mc = safe(function() local s = scoreComp(); return s and s:GetMaxComboCount() end)
  if type(mc) == "number" then state.MaxCombo = mc end
  local fm = M.ReadMoveScores()
  if #fm > 0 then state.MoveScores = fm end   -- fresh read if available, else keep the in-play capture
  state.FinalAvgSync = M.AvgSync(state)
  state.FinalPeakSync = state.SyncPeak
  local stars = M.ReadStars()
  if stars ~= nil then
    state.StarsAtEnd = stars
    if type(state.StarsStart) == "number" then
      state.StarsEarned = math.max(0, state.StarsAtEnd - state.StarsStart)  -- stars earned THIS song
    end
  end
  log.debug(string.format("[combat] final: score=%s maxCombo=%s avgSync=%s peakSync=%s moves=%d",
    tostring(state.TotalScore), tostring(state.MaxCombo),
    state.FinalAvgSync and string.format("%.2f", state.FinalAvgSync) or "nil",
    state.FinalPeakSync and string.format("%.2f", state.FinalPeakSync) or "nil",
    #(state.MoveScores or {})))
end




-- Reset the per-song accumulators (call at song start).
function M.Reset(state)
  if not state then return end
  state.__capturedFinal = false
  state.SyncSamples, state.SyncSum, state.SyncPeak = 0, 0, 0
  state.SyncStreak, state.SyncStreakMax = 0, 0
  state.Combo, state.MaxCombo, state.Multiplier = 0, 0, 1
  state.MoveScores = nil
  state.__moveTick = 0
  state.FinalAvgSync, state.FinalPeakSync = nil, nil
  state.StarsAtEnd, state.StarsEarned = nil, nil
  state.StarsStart = M.ReadStars()    -- baseline for "stars earned this song"

  -- Clear and initialize our features' state
  state.PbDelta = nil
  state.RecentSync = {}
  state.RecentSyncAvg = 0
  state.HypeStatus = "—"
  state.Bpm = nil
end

function M.ClearCache()
  _musicSubsys = nil
end

function M.RecordHit(state, combo)
  if not state then return end
  local prevCombo = state.Combo or 0
  state.Combo = combo

  if combo == 0 or combo < prevCombo then
    state.SyncStreak = 0
    pcall(function() require("imgui.in_game_progress_hud").Update(state, M.Poll()) end)
    return
  end

  local snap = M.Poll()
  if not snap then return end
  local f = M.SyncFraction(snap)
  if f then
    if f >= 0.95 then
      state.SyncStreak = (state.SyncStreak or 0) + 1
      state.SyncStreakMax = math.max(state.SyncStreakMax or 0, state.SyncStreak)
    else
      state.SyncStreak = 0
    end
    pcall(function() require("imgui.in_game_progress_hud").Update(state, snap) end)
  end
end

return M
