--[[ lyrics_engine.lua — holds the active song's parsed lines and resolves the
  current line from a playback time. Pure Lua.

  Uses an advancing cursor (amortized O(1) per tick) and re-seeks if time jumps
  backwards (song restart / seek). The game's GetTimelinePosition freezes on pause
  and resets toward 0 on restart, both of which this handles. --]]
local M = {}

local lines, count, cursor = {}, 0, 0

function M.Load(parsed)
  lines = (parsed and parsed.lines) or {}
  count = #lines
  cursor = 0
end

function M.Clear()
  lines, count, cursor = {}, 0, 0
end

function M.HasLyrics()
  return count > 0
end

-- Returns currentText, nextText, currentIndex for the given time (seconds).
function M.At(tSec)
  if count == 0 then return nil, nil, 0 end
  tSec = tSec or 0

  -- backwards jump (restart/seek) -> re-seek from the start
  if cursor > 0 and lines[cursor] and lines[cursor].t > tSec then
    cursor = 0
  end
  -- advance while the next line has already started
  while cursor < count and lines[cursor + 1].t <= tSec do
    cursor = cursor + 1
  end

  local cur = (cursor >= 1) and lines[cursor].text or nil
  local nxt = (cursor < count) and lines[cursor + 1].text or nil
  return cur, nxt, cursor
end

return M
