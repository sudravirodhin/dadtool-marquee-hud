--[[ lyrics_store.lua — disk I/O for cached lyrics. Marquee is DISPLAY-ONLY: it reads
  LRCs but never produces them (the dadtool importer is the producer).

  Reads cached "<key>.lrc"; records a "<key>.miss" marker (so we don't re-queue songs
  known to have no synced lyrics); queues "no-lyrics-yet" notes to "_requests.jsonl"
  (one JSON object per line) for the importer (dadtool `dad lyrics --queue`) to satisfy —
  in practice only BUILT-IN game songs, since dadtool pre-produces imported ones.

  Path convention matches history_handler (relative to the game working dir). --]]
local log = require("utils.log")
local json = require("utils.json")

local M = {}

local DIR = "./ue4ss/Mods/Marquee/Scripts/data/lyrics/"
local REQUESTS = DIR .. "_requests.jsonl"

local function readFile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local c = f:read("*all")
  f:close()
  return c
end

local function exists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

-- Cached synced lyrics text for a key, or nil.
function M.LoadLrc(key)
  if not key or key == "" then return nil end
  return readFile(DIR .. key .. ".lrc")
end

-- Have we already recorded "no synced lyrics available" for this key?
function M.HasMiss(key)
  if not key or key == "" then return false end
  return exists(DIR .. key .. ".miss")
end

-- Is there already cached synced lyrics for this key? (existence check, no file read)
function M.HasLrc(key)
  if not key or key == "" then return false end
  return exists(DIR .. key .. ".lrc")
end

-- Append a fetch request (de-duped per session). `info` = resolver result.
-- Per-song lyric timing offset in seconds (e.g. when the importer trimmed leading silence).
function M.LoadOffset(key)
  if not key or key == "" then return 0 end
  return tonumber(readFile(DIR .. key .. ".offset")) or 0
end

function M.SaveOffset(key, val)
  if not key or key == "" then return end
  local f = io.open(DIR .. key .. ".offset", "w")
  if f then f:write(tostring(val)); f:close() end
end

local queued = {}
function M.QueueRequest(info)
  local key = info and info.key
  if not key or key == "" or queued[key] then return end
  queued[key] = true

  local ok, line = pcall(json.encode, {
    key = info.key,
    artist = info.artist or "",
    title = info.title or "",
    durationSec = info.durationSec or 0,
    isImported = info.isImported and true or false,
    songName = info.songName or "",
  })
  if not ok then return end

  local f = io.open(REQUESTS, "a")
  if not f then
    log.debug("[lyrics] cannot open requests file: " .. REQUESTS)
    return
  end
  f:write(line .. "\n")
  f:close()
  log.debug(string.format("[lyrics] queued fetch: %s - %s (%ss)",
    tostring(info.artist), tostring(info.title), tostring(info.durationSec)))
end

return M
