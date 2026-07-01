--[[ lyrics_store.lua — disk I/O for cached lyrics. Marquee is DISPLAY-ONLY: it reads
  LRCs but never produces them (the dadtool importer is the producer).

  Reads cached "<key>.lrc"; writes the full catalog manifest ("_catalog.jsonl") so
  dadtool knows every song in the game. Per-song offset files (<key>.offset) persist
  manual lyric-timing corrections made with F9/F10.

  Path convention matches history_handler (relative to the game working dir). --]]
local log = require("utils.log")
local json = require("utils.json")

local M = {}

local DIR = "./ue4ss/Mods/Marquee/Scripts/data/lyrics/"
local CATALOG  = DIR .. "_catalog.jsonl"

local function readFile(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local c = f:read("*all")
  f:close()
  return c
end

local function exists(path)
  local f = io.open(path, "rb")
  if f then f:close(); return true end
  return false
end

-- Cached synced lyrics text for a key, or nil.
function M.LoadLrc(key)
  if not key or key == "" then return nil end
  local path = DIR .. key .. ".lrc"
  local content = readFile(path)
  log.debug(string.format("[lyrics] LoadLrc key=%s path=%s content_len=%s", tostring(key), tostring(path), tostring(content and #content or "nil")))
  return content
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

-- Per-song lyric timing offset in seconds (e.g. when the importer trimmed leading silence).
function M.LoadOffset(key)
  if not key or key == "" then return 0 end
  return tonumber(readFile(DIR .. key .. ".offset")) or 0
end

-- Save the per-song offset in binary mode
function M.SaveOffset(key, val)
  if not key or key == "" then return end
  local f = io.open(DIR .. key .. ".offset", "wb")
  if f then f:write(tostring(val)); f:close() end
end

-- QueueRequest removed: superseded by _catalog.jsonl manifest (see docs/IMPORTER_LRC_SPEC.md)

-- Snapshot EVERY catalog song's current key + metadata in ONE bulk write per sweep, so
-- dadtool's re-map can match current keys to orphaned <oldkey>.lrc after a game update
-- re-versions songs. Overwrites each sweep (a full snapshot, never a per-session append).
function M.WriteCatalog(entries)
  if type(entries) ~= "table" then return end
  local out = {}
  for _, info in ipairs(entries) do
    if info and info.key and info.key ~= "" then
      local ok, line = pcall(json.encode, {
        key = info.key, artist = info.artist or "", title = info.title or "",
        durationSec = info.durationSec or 0, isImported = info.isImported and true or false,
        songName = info.songName or "",
      })
      if ok then out[#out + 1] = line end
    end
  end
  local f = io.open(CATALOG, "wb")
  if not f then log.debug("[lyrics] cannot write catalog manifest: " .. CATALOG); return end
  f:write(table.concat(out, "\n"))
  if #out > 0 then f:write("\n") end
  f:close()
  log.debug(string.format("[lyrics] wrote catalog manifest: %d songs", #out))
end

return M
