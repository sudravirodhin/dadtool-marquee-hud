local M = {}

local json = require("utils.json")
local log = require("utils.log")

-- History file path
local SAVE_PATH = "./ue4ss/Mods/Marquee/Scripts/data/performance_history.json"
local TMP_PATH = SAVE_PATH .. ".tmp"
local BAK_PATH = SAVE_PATH .. ".bak"   -- last-good copy; recovers PBs if the main file ever corrupts

local function _dmp_tbl(o)
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then k = '"' .. k .. '"' end
			s = s .. '[' .. k .. '] = ' .. _dmp_tbl(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

--- centralizes and sanitizes Primary Key (PK) generation
local function _getCleanPrimaryKey(session)
	if session.SongUniqueID and session.SongUniqueID ~= 0
		and session.SongUniqueID ~= "" and session.SongUniqueID ~= "0" then
		return tostring(session.SongUniqueID)
	end

	if session.SongName and session.SongName ~= ""
		and session.SongName == "No Song" then
		return nil
	end

	if session.AssetPath and session.AssetPath ~= "" then
		-- capture only what comes after the last dot
		-- e.g. "/Game/Pagoda/Maps/Song_Disco.Song_Disco" -> "Song_Disco"
		local clean = session.AssetPath:match("([^.]+)$")
		if clean and clean ~= "" then
			return clean
		end
		return session.AssetPath
	end

	-- PK must be AssetPath or SongUniqueID for consistency; SongName is too volatile.
	return nil
end

-- Read + decode a history file, or nil if missing / empty / corrupt.
local function _tryLoad(path)
	local f = io.open(path, "r")
	if not f then return nil end
	local content = f:read("*all")
	f:close()
	if not content or content == "" then return nil end
	local ok, data = pcall(json.decode, content)
	if not ok or type(data) ~= "table" then return nil end
	return data
end

---@return table
function M.LoadHistory()
	local data = _tryLoad(SAVE_PATH)
	if data then return data end
	-- primary unreadable (missing / empty / corrupt) -> recover from .bak before wiping
	local bak = _tryLoad(BAK_PATH)
	if bak then
		log.info("[history] primary history unreadable — RECOVERED from .bak")
		return bak
	end
	log.debug("No readable history (and no usable backup). Starting fresh.")
	return {}
end

---@param data table
function M.SaveHistory(data)
	local ok, content = pcall(json.encode, data)
	if not ok then
		log.error("Error encoding JSON history.")
		return
	end

	-- 1. ATOMIC WRITE: write to a temp file first
	local f = io.open(TMP_PATH, "w")
	if not f then
		log.error("Could not open temporary history file for writing.")
		return
	end
	log.debug("Writing Data to TMP: " .. _dmp_tbl(data))
	f:write(content)
	f:close()

	-- 2. SAFE SWAP (Windows blocks os.rename onto an existing file): remove then rename.
	os.remove(SAVE_PATH)
	local success, err = os.rename(TMP_PATH, SAVE_PATH)
	if success then
		log.debug("History saved atomically successfully.")
		-- mirror the good content to a backup so a future corrupt/interrupted main write can recover
		local fb = io.open(BAK_PATH, "w")
		if fb then fb:write(content); fb:close() end
	else
		log.error("Atomic swap failed: " .. tostring(err) .. ". Executing fallback write.")
		local f_fallback = io.open(SAVE_PATH, "w")
		if f_fallback then
			f_fallback:write(content)
			f_fallback:close()
		end
	end
end

--- Fetch the Personal Best without updating it
---@param session table The global state snapshot
---@return table|nil The PB data or nil if not found
function M.GetPB(session)
	local pk = _getCleanPrimaryKey(session)
	if not pk or pk == "" then
		return nil
	end
	local history = M.LoadHistory()
	return history[pk]
end

--- Core logic to update Personal Best
---@param session table The global state snapshot (__SessionAggAccuracy)
---@return boolean, table Returns whether it's a new record (isNewPB) and the updated PB data
function M.UpdateBestRun(session)
	log.debug("Updating best run for song: " .. (session.SongName or "Unknown"))

	local pk = _getCleanPrimaryKey(session)
	log.debug("Determined PK for history: " .. tostring(pk))

	if not pk or pk == "" then
		log.error("Could not determine a valid PK for history. Aborting update.")
		return false, nil
	end

	local history = M.LoadHistory()
	local hist_count = 0
	for _ in pairs(history) do
		hist_count = hist_count + 1
	end
	log.debug("Current history entries: " .. tostring(hist_count))

	local pb = history[pk]
		or {
			songName = session.SongName,
			songID = session.SongUniqueID or session.SongID or "Unknown",
			highScore = 0,
			bestCombo = 0,
			bestSync = 0,
			playCount = 0,
		}
	log.debug("Local Personal Best: " .. _dmp_tbl(pb))

	-- Increment the play counter
	pb.playCount = pb.playCount + 1

	-- Business Rule: update stats only if the current Score beats the stored high score
	local isNewPB = false
	local currentScore = session.TotalScore or 0
	if currentScore > pb.highScore or (pb.highScore == 0 and currentScore > 0) then
		isNewPB = true
		pb.highScore = currentScore
		pb.bestCombo = session.MaxCombo or pb.bestCombo
		pb.bestSync = session.FinalAvgSync or pb.bestSync
	end

	history[pk] = pb
	M.SaveHistory(history)

	return isNewPB, pb
end

return M
