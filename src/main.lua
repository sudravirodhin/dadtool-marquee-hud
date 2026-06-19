print("[Marquee] ~>> BOOT: main.lua initiated")

local UEHelpers = require("UEHelpers")
local log = require("utils.log")
local cfg = require("config")
local history_handler = require("handlers.history_handler")
local hud_handler = require("handlers.hud_handler")
local combat_stats = require("combat.combat_stats")
local hud_utils = require("utils.hud_utils")
-- lyrics is additive: never let a lyrics bug break the tracker
local lyrics_handler = nil
do
	local ok, mod = pcall(require, "lyrics.lyrics_handler")
	if ok then lyrics_handler = mod else print("[Marquee] [lyrics] load failed: " .. tostring(mod)) end
end
-- career stats panel (F6) — additive, never let it break the tracker
local stats_hud = nil
do local ok, m = pcall(require, "imgui.stats_hud"); if ok then stats_hud = m end end

print(string.format("[Marquee] ~>> BOOT: Marquee v%s on UE4SS %s — all modules loaded",
	cfg.MARQUEE_VERSION or "?", cfg.UE4SS_VERSION or "?"))

local pcall, string_format = pcall, string.format
local HEARTBEAT_MS = 5000

--[[ ============ SESSION STATE ============
  Dead as Disco grades on Score + Combo + Sync Meter + Multiplier — NOT hit-accuracy.
  We POLL those signals from the game each HUD tick (see combat.combat_stats); nothing
  hooks the per-move ability dispatch — the game already tallies these, so we read them. The global keeps
  its historical name so existing references don't break; its contents are the new model. --]]
_G.__SessionAggAccuracy = _G.__SessionAggAccuracy or {
	-- live combat signals (filled by combat_stats.Poll/Accumulate)
	TotalScore = 0,
	Combo = 0,
	MaxCombo = 0,
	Multiplier = 1,
	-- sync ("rhythm perfection") accumulators
	SyncSamples = 0, SyncSum = 0, SyncPeak = 0, SyncStreak = 0, SyncStreakMax = 0,
	-- end-of-song snapshot
	MoveScores = nil, FinalAvgSync = nil, FinalPeakSync = nil, StarsAtEnd = nil,
	-- song identity / lyrics inputs
	SongName = "Unknown", AssetPath = "", SongUniqueID = "",
	CachedPB = nil,
	-- hud
	IsTrackerVisible = true,
	-- hook-registration flags (lifecycle + results only)
	__setup_hooks = false,
	__hb_hooks = false,
	__reg_hooks = { Lifecycle = false, Scores = false },
	__xpAwarded = false,
	__capturedFinal = false,
}

local function is_indexable(obj)
	if not obj then return false end
	local t = type(obj)
	if t == "table" then return true end
	if t == "userdata" then
		local ok, res = pcall(function() return obj:IsValid() end)
		return not ok or res == true
	end
	return false
end

--[[ ============ SONG IDENTITY (for lyrics + history key) ============ --]]
local _musicSubsys = nil
local function GetMusicSubsystem()
	if _musicSubsys then
		local ok, valid = pcall(function() return is_indexable(_musicSubsys) and _musicSubsys:IsValid() end)
		if ok and valid then return _musicSubsys end
	end
	local insts = FindAllOf("PagodaMusicSubsystem")
	_musicSubsys = (insts and insts[1]) or nil
	return _musicSubsys
end

local function CaptureSongMetadata()
	local state = _G.__SessionAggAccuracy
	pcall(function()
		local subsys = GetMusicSubsystem()
		if subsys and is_indexable(subsys) then
			local currentSong = subsys:GetCurrentSong()
			if currentSong and is_indexable(currentSong) and currentSong:IsValid() then
				local newUID = currentSong:GetImportedSongUniqueID()
				local newName = currentSong.SongName:ToString()
				-- Only update and log if the song unique ID or name has changed
				if newUID ~= state.SongUniqueID or newName ~= state.SongName then
					state.SongName = newName
					state.AssetPath = currentSong:GetFullName()
					state.SongUniqueID = newUID

					pcall(function() state.CachedPB = history_handler.GetPB(state) end)
					pcall(function() state.SongLengthSec = subsys:GetSongLengthSeconds() end)
					pcall(function() state.SongIsImported = currentSong.bImportedSong end)
					pcall(function()
						-- NEVER index a TArray directly: use GetFirstTArrayElement to safely retrieve
						-- and unwrap the element, avoiding out-of-bounds native crashes.
						local pb = currentSong.PerformedBy
						local first = hud_utils.GetFirstTArrayElement(pb)
						if first ~= nil then
							state.SongArtist = (type(first) == "userdata" and is_indexable(first) and first.ToString and first:ToString()) or tostring(first)
						end
					end)
					log.info(string_format("CURRENT SONG changed: %s | %s | %s",
						tostring(state.SongUniqueID), state.SongName, state.AssetPath))
				end
			end
		end
	end)
end
_G.CaptureSongMetadata = CaptureSongMetadata

--[[ ============ SONG LIFECYCLE ============ --]]
local function OnSongStart()
	local state = _G.__SessionAggAccuracy
	combat_stats.Reset(state)        -- clears per-song accumulators + stale handles
	state.__xpAwarded = false
	CaptureSongMetadata()
	pcall(function() lyrics_handler.OnSongStart(state) end)
	state.CachedPB = history_handler.GetPB(state)
	pcall(function() if stats_hud then stats_hud.Hide() end end)   -- close the stats overlay on song start
	hud_handler.SetState(hud_handler.States.IN_GAME, state)
	log.debug("Gameplay started — polling combat stats (no per-move hooks)")
end

local function OnResults()
	local state = _G.__SessionAggAccuracy
	combat_stats.CaptureFinal(state) -- final score/combo/sync + move breakdown + stars
	if (state.TotalScore or 0) > 0 then
		history_handler.UpdateBestRun(state)
		if cfg.LEVELING_ENABLED ~= false then
			pcall(function() require("leveling.leveling").AwardForRun(state) end)
		end
		log.info(string_format("Song ended: score=%d maxCombo=%d", state.TotalScore or 0, state.MaxCombo or 0))
	end
	hud_handler.SetState(hud_handler.States.RESULTS, state)
	pcall(function() lyrics_handler.OnSongEnd() end)
end

--[[ ============ HOOKS — lifecycle + results ONLY (no per-move combat hooks) ============ --]]
local GAME_PATHS = {
	HighScores       = "/Game/Pagoda/UI/Game/HighScores/WBP_HighScoresList.WBP_HighScoresList_C",
	PlayerController  = "/Game/Pagoda/Characters/Player/BP_PagodaPlayerController.BP_PagodaPlayerController_C",
	GameMode         = "/Game/Pagoda/Core/GameModes/BP_PagodaGameMode.BP_PagodaGameMode_C",
	LevelEnd         = "/Game/Pagoda/UI/Game/WBP_LevelEndScreen.WBP_LevelEndScreen_C",
}

local function RegisterLifecycleHooks()
	-- leaving a song -> back to the hub
	RegisterHook(GAME_PATHS.PlayerController .. ":ReceiveEndPlay", function()
		pcall(function() hud_handler.SetState(hud_handler.States.PRE_GAME, _G.__SessionAggAccuracy) end)
		pcall(function() lyrics_handler.OnSongEnd() end)
	end)
	-- gameplay start / retry (BP_PagodaGameMode covers all modes). Guard the self read.
	RegisterHook(GAME_PATHS.GameMode .. ":ResetPlayerAttributesForRespawn", function(wrappedSelf)
		pcall(function()
			local self = wrappedSelf and wrappedSelf:get()
			if not self then return end
			local inPlay = false
			pcall(function() inPlay = (self.InPlaythrough == true) end)
			if not inPlay then return end
			OnSongStart()
		end)
	end)
end

local function RegisterScoresHooks()
	RegisterHook(GAME_PATHS.LevelEnd .. ":Construct", function()
		pcall(OnResults)
		log.debug("Level end screen constructed — captured final stats")
	end)
	RegisterHook(GAME_PATHS.HighScores .. ":Construct", function()
		pcall(OnResults)
		log.debug("Results screen detected — captured final stats")
	end)
	RegisterHook(GAME_PATHS.LevelEnd .. ":Destruct", function()
		pcall(function() hud_handler.HideResultsUI() end)
	end)
end

local function SetupHooks()
	local rh = _G.__SessionAggAccuracy.__reg_hooks
	if not rh.Lifecycle then rh.Lifecycle = pcall(RegisterLifecycleHooks) end
	if not rh.Scores   then rh.Scores   = pcall(RegisterScoresHooks)   end
	return rh.Lifecycle and rh.Scores
end

--[[ ============ INIT LOOPS ============ --]]
-- rebuild the HUD on client restart / map change
LoopAsync(HEARTBEAT_MS, function()
	local state = _G.__SessionAggAccuracy
	if state.__hb_hooks then return true end
	local ok = pcall(function()
		RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
			ExecuteInGameThread(function() hud_handler.EnsureUI() end)
		end)
	end)
	if ok then state.__hb_hooks = true end
	return ok
end)

-- one-shot lifecycle/results hook registration
LoopAsync(HEARTBEAT_MS, function()
	local state = _G.__SessionAggAccuracy
	if state.__setup_hooks then return true end
	if SetupHooks() then
		state.__setup_hooks = true
		log.info("All hooks initialized (lifecycle + results only — no per-move hooks)")
		pcall(function() ExecuteInGameThread(function() hud_handler.EnsureUI() end) end)
		return true
	end
	return false
end)

-- Safe game-thread loop helper to prevent Lua VM multi-threading data races (ltable.c crashes).
-- Uses LoopInGameThreadWithDelay if supported, falling back to LoopAsync + ExecuteInGameThread.
local function StartGameThreadLoop(intervalMs, callback)
	if LoopInGameThreadWithDelay then
		LoopInGameThreadWithDelay(intervalMs, callback)
	else
		LoopAsync(intervalMs, function()
			ExecuteInGameThread(callback)
			return false
		end)
	end
end

-- HUD sync loop: hud_handler.Sync polls the game's combat signals + renders (IN_GAME only)
StartGameThreadLoop(cfg.HUD_UPDATE_INTERVAL_MS, function()
	hud_handler.Sync(_G.__SessionAggAccuracy)
end)

-- lyrics sync loop
StartGameThreadLoop(cfg.LYRICS_TICK_MS or 60, function()
	if lyrics_handler then pcall(lyrics_handler.Tick) end
end)


-- Once the song catalog is loaded, dump the FULL manifest (_catalog.jsonl: every in-game +
-- imported song's current key + meta) so dadtool always has the complete song list to generate
-- lyrics from. Runs once per game load (when the catalog is ready); no per-song queuing.
if cfg.LYRICS_DUMP_CATALOG ~= false then
	local tries = 0
	LoopAsync(8000, function()
		local state = _G.__SessionAggAccuracy
		if state.__dumpedCatalog then return true end
		tries = tries + 1
		local capped = tries >= 15            -- catalog never showed (~2 min) -> stop trying
		ExecuteInGameThread(function()
			if state.__dumpedCatalog then return end
			local n = nil
			pcall(function() if lyrics_handler then n = lyrics_handler.DumpCatalogManifest() end end)
			if type(n) == "number" or capped then state.__dumpedCatalog = true end
		end)
		return state.__dumpedCatalog
	end)
end

--[[ ============ KEYBINDS ============ --]]
RegisterKeyBind(Key.F2, function() if lyrics_handler then lyrics_handler.Toggle() end end)
-- live per-song lyric-sync nudge (saved per song): F9 later, F10 earlier, F11 reset
RegisterKeyBind(Key.F9,  function() if lyrics_handler then lyrics_handler.NudgeOffset(-(cfg.LYRICS_NUDGE_STEP or 0.1)) end end)
RegisterKeyBind(Key.F10, function() if lyrics_handler then lyrics_handler.NudgeOffset(cfg.LYRICS_NUDGE_STEP or 0.1) end end)
RegisterKeyBind(Key.F11, function() if lyrics_handler then lyrics_handler.ResetOffset() end end)
-- stats panel visibility
RegisterKeyBind(Key.F3, function()
	local s = _G.__SessionAggAccuracy
	s.IsTrackerVisible = not s.IsTrackerVisible
	hud_handler.UpdateModStatus(s)
end)




-- ============ F5: Debug Status Print ============
RegisterKeyBind(Key.F5, function()
	ExecuteInGameThread(function()
		local state = _G.__SessionAggAccuracy
		log.info("[DEBUG_F5] Current Mod Status:")
		log.info(string.format("  Song: %s (Artist: %s, Key: %s, Imported: %s)",
			tostring(state.SongName), tostring(state.SongArtist),
			tostring(state.SongUniqueID), tostring(state.SongIsImported)))
		log.info(string.format("  AssetPath: %s", tostring(state.AssetPath)))
		log.info(string.format("  SongLengthSec: %s", tostring(state.SongLengthSec)))
		
		-- Print CachedPB info
		if state.CachedPB then
			log.info(string.format("  CachedPB: name=%s, score=%s, combo=%s, sync=%s, count=%s",
				tostring(state.CachedPB.songName), tostring(state.CachedPB.highScore),
				tostring(state.CachedPB.bestCombo), tostring(state.CachedPB.bestSync),
				tostring(state.CachedPB.playCount)))
		else
			log.info("  CachedPB: nil")
		end

		log.info(string.format("  Current Score: %d, Streak: %d, Max Streak: %d",
			state.TotalScore or 0, state.SyncStreak or 0, state.SyncStreakMax or 0))
	end)
end)

-- ============ F6: Career Stats panel (toggle) ============
RegisterKeyBind(Key.F6, function()
	if stats_hud then ExecuteInGameThread(function() pcall(stats_hud.Toggle) end) end
end)
