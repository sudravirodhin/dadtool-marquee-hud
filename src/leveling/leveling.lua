--[[ leveling.lua — XP + levels for Marquee.

  XP = cumulative lifetime combat score, weighted by rhythm sync x(0.75 + 0.5*avgSync)
       (sync = the game's own "perfect-timing" gauge, MusicSyncMeter; 0 -> x0.75,
       0.5 -> x1.0, 1.0 -> x1.25). 20 dance-themed levels on an escalating threshold curve.
       See dad-combat-stats-api. NOT accuracy/miss based — that was the old Osu! model.

  Persists to data/profile.json (separate from per-song performance_history). --]]
local M = {}

local json = require("utils.json")
local log = require("utils.log")
local cfg = require("config")

local PROFILE_PATH = "./ue4ss/Mods/Marquee/Scripts/data/profile.json"

-- Title per level (index = level).
local TITLES = cfg.LEVEL_TITLES or {
  "Wallflower", "Toe-Tapper", "Two-Stepper", "The Shuffler", "Boogie Cadet",
  "Funky Footwork", "The Bus Stop", "Hustle Hopeful", "Groove Rider", "The Robot",
  "Mirrorball Mover", "Moonwalker", "Boogie Wonder", "Funk Commander", "Saturday Night Fever",
  "Nonstop Hustler", "Discotheque Don", "Studio 54 Royalty", "Disco Inferno", "Eternal Groovemaster",
}
local MAX_LEVEL = #TITLES

-- Cumulative XP to REACH each level (~50000*(L-1)^2.07, rounded). Override via cfg.LEVEL_THRESHOLDS.
local THRESHOLDS = cfg.LEVEL_THRESHOLDS or {
  0, 50000, 150000, 300000, 550000, 900000, 1400000, 2100000, 3000000, 4200000,
  5800000, 7800000, 10400000, 13500000, 17500000, 22500000, 29000000, 37000000, 47000000, 60000000,
}

-- pretty 1,234,567
function M.Commafy(n)
  n = math.floor(tonumber(n) or 0)
  local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
  return (s:gsub("^,", ""))
end

function M.Title(level)
  level = math.max(1, math.min(math.floor(level or 1), MAX_LEVEL))
  return TITLES[level]
end

-- escalating tier color for a level: {R,G,B}
function M.LevelColor(level)
  level = level or 1
  if level >= 18 then return { 1, 0.82, 0.15 }       -- gold (legend)
  elseif level >= 14 then return { 1, 0.4, 0.8 }     -- pink (master)
  elseif level >= 10 then return { 0.3, 0.9, 1 }     -- cyan (flashy)
  elseif level >= 5 then return { 0.4, 1, 0.5 }      -- emerald (groove)
  else return { 0.55, 0.8, 1 } end                    -- sky blue (beginner)
end

function M.LevelForXp(xp)
  local lvl = 1
  for L = 1, MAX_LEVEL do
    if xp >= THRESHOLDS[L] then lvl = L else break end
  end
  return lvl
end

-- returns level, nextThresholdXp (nil if maxed), xpToNext (nil if maxed)
function M.Progress(xp)
  local lvl = M.LevelForXp(xp)
  if lvl >= MAX_LEVEL then return lvl, nil, nil end
  local nextAt = THRESHOLDS[lvl + 1]
  return lvl, nextAt, math.max(0, nextAt - xp)
end

--[[ ---- profile persistence ---- ]]
local function loadProfile()
  local f = io.open(PROFILE_PATH, "r")
  if not f then return nil end   -- absent -> caller seeds from history
  local c = f:read("*all"); f:close()
  if not c or c == "" then return { xp = 0, level = 1 } end
  local ok, data = pcall(json.decode, c)
  if not ok or type(data) ~= "table" then return { xp = 0, level = 1 } end
  return { xp = tonumber(data.xp) or 0, level = tonumber(data.level) or 1 }
end

local function saveProfile(p)
  local ok, c = pcall(json.encode, p)
  if not ok then return end
  local tmp = PROFILE_PATH .. ".tmp"
  local f = io.open(tmp, "w")
  if not f then return end
  f:write(c); f:close()
  os.remove(PROFILE_PATH)
  if not os.rename(tmp, PROFILE_PATH) then
    local g = io.open(PROFILE_PATH, "w")
    if g then g:write(c); g:close() end
  end
end

-- One-time seed: convert existing PB history into starting XP (weighted like a run).
function M.SeedFromHistory()
  local total = 0
  pcall(function()
    local history = require("handlers.history_handler").LoadHistory()
    if type(history) ~= "table" then return end
    for _, pb in pairs(history) do
      local score = tonumber(pb.highScore) or 0
      if score > 0 then
        local sync = tonumber(pb.bestSync) or 0.5   -- old records had no sync; assume mid
        sync = math.max(0, math.min(1, sync))
        total = total + math.floor(score * (0.75 + 0.5 * sync) + 0.5)
      end
    end
  end)
  return math.floor(total)
end

M._profile = nil
function M.Get()
  if M._profile then return M._profile end
  local p = loadProfile()
  if not p then   -- first ever run: seed from existing history
    local xp = M.SeedFromHistory()
    p = { xp = xp, level = M.LevelForXp(xp) }
    saveProfile(p)
    if xp > 0 then
      log.info(string.format("[leveling] seeded %d XP from history -> Lv%d %s", xp, p.level, M.Title(p.level)))
    end
  end
  M._profile = p
  return M._profile
end

-- XP for one finished run: the game's OWN combat score, weighted by rhythm sync (the
-- DaD-native "perfect" signal — see dad-combat-stats-api). avgSync 0 -> x0.75,
-- 0.5 -> x1.0, 1.0 -> x1.25. No accuracy/miss concept; score already bakes in combo+mult.
function M.XpForRun(state)
  local score = tonumber(state.TotalScore) or 0
  if score <= 0 then return 0 end
  local sync = tonumber(state.FinalAvgSync) or 0
  sync = math.max(0, math.min(1, sync))
  return math.floor(score * (0.75 + 0.5 * sync) + 0.5)
end

-- Award XP for a finished run (idempotent per song via state.__xpAwarded).
-- Stuffs a summary into state.Leveling for the results HUD; returns it.
function M.AwardForRun(state)
  if not state then return nil end
  if state.__xpAwarded then return state.Leveling end

  local p = M.Get()
  local prevLevel = M.LevelForXp(p.xp)
  local gained = M.XpForRun(state)

  p.xp = p.xp + gained
  p.level = M.LevelForXp(p.xp)
  saveProfile(p)

  local lvl, nextAt, xpToNext = M.Progress(p.xp)
  local result = {
    xpGained = gained,
    totalXp = p.xp,
    level = lvl,
    title = M.Title(lvl),
    leveledUp = lvl > prevLevel,
    prevLevel = prevLevel,
    nextTitle = (lvl < MAX_LEVEL) and M.Title(lvl + 1) or nil,
    nextThreshold = nextAt,
    xpToNext = xpToNext,
  }
  state.Leveling = result
  state.__xpAwarded = true

  if result.leveledUp then
    log.info(string.format("[leveling] LEVEL UP! Lv%d %s (+%d XP, total %d)",
      lvl, result.title, gained, p.xp))
  else
    log.debug(string.format("[leveling] +%d XP (Lv%d %s, total %d)", gained, lvl, result.title, p.xp))
  end
  return result
end

return M
