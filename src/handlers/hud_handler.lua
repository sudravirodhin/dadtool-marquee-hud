local M = {}

local UEHelpers = require("UEHelpers")
local cfg = require("config")
local combat_stats = require("combat.combat_stats")
local in_game_progress_hud = require("imgui.in_game_progress_hud")
local results_hud = require("imgui.results_hud")
-- (input_overlay_hud removed to restore stability)
local status_indicator_hud = require("imgui.status_indicator_hud")
local hud_utils = require("utils.hud_utils")
local log = require("utils.log")
local history_handler = require("handlers.history_handler")
local leveling = nil
do local ok, m = pcall(require, "leveling.leveling"); if ok then leveling = m end end

-- Enums for Mod State
M.States = {
	PRE_GAME = 1, -- Main Menu, Loading, Prep
	IN_GAME = 2, -- Countdown finished, actively playing
	RESULTS = 3, -- Song finished, HighScores screen visible
}

M.CurrentState = M.States.PRE_GAME

-- ---- hub-world detection ----------------------------------------------------
-- The "♪ Marquee" badge only belongs in the hub world (The Encore). We can't know
-- that map's asset name ahead of time, so match the live map's full path against
-- cfg.HUB_MAP_NAMES (substrings) and log it once per change so the real name can be
-- pinned. If detection itself fails we DON'T suppress the badge (graceful fallback).
local HUB_NAMES = cfg.HUB_MAP_NAMES or { "encore" }
local _lastMapId = nil

local function call_is_valid(o)
	return o:IsValid()
end

local function is_indexable(obj)
	if not obj then return false end
	local t = type(obj)
	if t == "table" then return true end
	if t == "userdata" then
		local ok, res = pcall(call_is_valid, obj)
		return not ok or res == true
	end
	return false
end

local function getMapId()
	local id
	pcall(function()
		local world = UEHelpers.GetWorld()
		if world and is_indexable(world) and world:IsValid() then id = world:GetFullName() end
	end)
	return id
end

function M.IsHubWorld()
	local id = getMapId()
	if id ~= _lastMapId then
		_lastMapId = id
		log.info("[hud] current map = " .. tostring(id))
	end
	if not id or id == "" then return true end   -- detection failed -> keep the badge
	local low = id:lower()
	for _, frag in ipairs(HUB_NAMES) do
		if low:find(frag, 1, true) then return true end
	end
	return false
end

-- Create-if-missing helpers: each widget exists ONLY while its state needs it.
local function ensureStats()
	if not in_game_progress_hud.IsValid() then in_game_progress_hud.Create() end
end

local function ensureBadge()
	if not status_indicator_hud.IsValid() then
		status_indicator_hud.Create()
		M.UpdateModStatus()
		M.RefreshLevel()
	end
end

local _musicSubsys = nil
local function isSongPaused()
	local ok, paused = pcall(function()
		if not _musicSubsys or not _musicSubsys:IsValid() then
			local insts = FindAllOf("PagodaMusicSubsystem")
			_musicSubsys = insts and insts[1]
		end
		return _musicSubsys and _musicSubsys:IsSongPaused() == true
	end)
	return ok and paused == true
end

function M.ClearCache()
	_musicSubsys = nil
end

--- Safety net (boot, ClientRestart, and each 400ms tick): recreate only the widget
--- the CURRENT state needs — in case a map load GC'd it — and nothing else, so no
--- widget lingers in a state that shouldn't draw it.
function M.EnsureUI()
	if M.CurrentState == M.States.IN_GAME then
		ensureStats()
	elseif M.CurrentState == M.States.PRE_GAME then
		if M.IsHubWorld() then ensureBadge() else status_indicator_hud.Destroy() end
	end
	-- RESULTS: the report is recreated on demand in results_hud.Show(); the badge and
	-- stats panel are intentionally absent there.
end

function M.HideResultsUI()
	results_hud.Hide()
end

--- Primary Router for State Changes. Each state owns exactly the widgets it needs
--- and tears down the rest, so nothing lingers or draws where it shouldn't.
---@param newState number One of M.States
function M.SetState(newState, sessionState)
	M.CurrentState = newState
	local liveState = sessionState or _G.__SessionAggAccuracy

	if newState == M.States.PRE_GAME then
		-- hub: stats panel + report gone; badge only in The Encore
		in_game_progress_hud.Destroy()
		results_hud.Hide()
		if M.IsHubWorld() then ensureBadge() else status_indicator_hud.Destroy() end
		M.RefreshLevel()

	elseif newState == M.States.IN_GAME then
		-- gameplay: badge + report gone; live stats panel up (if the tracker is on)
		status_indicator_hud.Destroy()
		results_hud.Hide()
		ensureStats()
		if liveState.IsTrackerVisible then
			in_game_progress_hud.SetVisibility(hud_utils.Visibility.HITTESTINVISIBLE)
		else
			in_game_progress_hud.SetVisibility(hud_utils.Visibility.HIDDEN)
		end

	elseif newState == M.States.RESULTS then
		-- results: only the report is drawn; hub badge + stats panel stay gone
		status_indicator_hud.Destroy()
		in_game_progress_hud.Destroy()
		if sessionState then
			results_hud.Show(sessionState)
		end
	end
end

--- Heartbeat sync for the 400ms loop
function M.Sync(sessionState)
	M.EnsureUI()

	-- The live stats panel is only on screen during gameplay; in menus and on the
	-- results screen it's hidden. Updating its text there is wasted work (every
	-- SetText is a reflected engine call), so skip it entirely unless we're actually
	-- playing. EnsureUI above still runs each tick so the badge/level survive map changes.
	if M.CurrentState ~= M.States.IN_GAME then
		return
	end

	-- Ensure we use the absolute latest global state
	local liveState = sessionState or _G.__SessionAggAccuracy

	-- Periodically refresh active song metadata dynamically during play (every 400ms tick)
	if _G.CaptureSongMetadata then
		pcall(_G.CaptureSongMetadata)
	end

	-- Poll the game's OWN combat signals (score/combo/sync/mult) and fold them into
	-- state — no per-move hooks. Then render the live snapshot.
	local snap = combat_stats.Poll()
	combat_stats.Accumulate(liveState, snap)
	in_game_progress_hud.Update(liveState, snap)

	-- hide stats while paused (they overlap the pause menu)
	if liveState.IsTrackerVisible and not isSongPaused() then
		in_game_progress_hud.SetVisibility(hud_utils.Visibility.HITTESTINVISIBLE)
	else
		in_game_progress_hud.SetVisibility(hud_utils.Visibility.HIDDEN)
	end

end

function M.UpdateModStatus(sessionState)
	-- Ensure we use the absolute latest global state
	local liveState = sessionState or _G.__SessionAggAccuracy

	status_indicator_hud.SetStatus(liveState.IsTrackerVisible)
end

function M.RefreshLevel()
	if not leveling then return end
	local ok, p = pcall(function() return leveling.Get() end)
	if ok and p then
		status_indicator_hud.SetLevel(
			string.format("Lv%d  %s", p.level, leveling.Title(p.level)),
			leveling.LevelColor(p.level))
	end
end


return M