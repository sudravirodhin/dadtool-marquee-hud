--[[ lyrics_resolver.lua — turn live song metadata (the session `state`) into:
       * a STABLE cache key (so renames never invalidate cached lyrics)
       * the artist / title / duration for the catalog manifest and lyrics lookup

  Key scheme mirrors history_handler so lyrics & PB history share one identity:
    custom/imported -> tostring(SongUniqueID);  built-in -> asset short-name after last '.'
--]]
local M = {}

-- *** SWAPPABLE *** Greg's custom importer names imported songs "Artist - Title"
-- for in-game sorting. This is NOT native and MAY CHANGE. If it does, change ONLY
-- this function (e.g. to read ID3 tags from state.SongAudioPath instead).
function M.ParseArtistTitle(songName)
  if type(songName) ~= "string" then return nil, songName end
  local artist, title = songName:match("^%s*(.-)%s*%-%s*(.+)$")
  if artist and artist ~= "" and title and title ~= "" then
    return artist, (title:gsub("%s+$", ""))
  end
  return nil, songName
end

local function isImported(state)
  if state.SongIsImported == true then return true end
  local uid = state.SongUniqueID
  return uid ~= nil and uid ~= 0 and uid ~= "0" and uid ~= ""
end

local function cleanKey(state)
  local uid = state.SongUniqueID
  if uid and uid ~= 0 and uid ~= "" and uid ~= "0" then
    local num = tonumber(uid)
    if num then
      return string.format("%.0f", num)
    end
    return tostring(uid)
  end
  if state.AssetPath and state.AssetPath ~= "" then
    local short = state.AssetPath:match("([^.]+)$")
    return (short and short ~= "") and short or state.AssetPath
  end
  return nil
end

-- Returns { key, artist, title, durationSec, isImported, songName } or nil.
function M.Resolve(state)
  if not state then return nil end
  local key = cleanKey(state)
  if not key then return nil end

  local imported = isImported(state)
  local artist, title
  if imported then
    artist, title = M.ParseArtistTitle(state.SongName)        -- custom: parse the name
  else
    artist = state.SongArtist                                  -- built-in: real PerformedBy[1]
    title = state.SongName
  end

  local dur = tonumber(state.SongLengthSec)
  return {
    key = key,
    artist = artist,
    title = title or state.SongName,
    durationSec = dur and math.floor(dur + 0.5) or nil,
    isImported = imported and true or false,
    songName = state.SongName,
  }
end

return M
