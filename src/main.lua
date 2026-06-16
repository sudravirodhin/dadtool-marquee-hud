print("[Marquee] ~>> BOOT: main.lua initiated")

local UEHelpers = require("UEHelpers")
local log = require("utils.log")
local cfg = require("config")
local history_handler = require("handlers.history_handler")
local hud_handler = require("handlers.hud_handler")
local combat_stats = require("combat.combat_stats")
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
}

--[[ ============ SONG IDENTITY (for lyrics + history key) ============ --]]
local function CaptureSongMetadata()
	local state = _G.__SessionAggAccuracy
	pcall(function()
		local musicInsts = FindAllOf("PagodaMusicSubsystem")
		if musicInsts and #musicInsts > 0 then
			local currentSong = musicInsts[1]:GetCurrentSong()
			if currentSong and currentSong:IsValid() then
				state.SongName = currentSong.SongName:ToString()
				state.AssetPath = currentSong:GetFullName()
				state.SongUniqueID = currentSong:GetImportedSongUniqueID()
				pcall(function() state.SongLengthSec = musicInsts[1]:GetSongLengthSeconds() end)
				pcall(function() state.SongIsImported = currentSong.bImportedSong end)
				pcall(function()
					-- NEVER index a TArray without a length check: pb[1] on an empty
					-- PerformedBy (custom songs) is an out-of-bounds native crash.
					local pb = currentSong.PerformedBy
					local n = (pb and #pb) or 0
					if type(n) == "number" and n >= 1 then
						local first = pb[1]
						if first ~= nil then
							state.SongArtist = (type(first) == "userdata" and first.ToString and first:ToString()) or tostring(first)
						end
					end
				end)
				log.debug(string_format("CURRENT SONG: %s | %s | %s",
					tostring(state.SongUniqueID), state.SongName, state.AssetPath))
			end
		end
	end)
end

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

-- HUD sync loop: hud_handler.Sync polls the game's combat signals + renders (IN_GAME only)
LoopAsync(cfg.HUD_UPDATE_INTERVAL_MS, function()
	ExecuteInGameThread(function() hud_handler.Sync(_G.__SessionAggAccuracy) end)
	return false
end)

-- lyrics sync loop
LoopAsync(cfg.LYRICS_TICK_MS or 60, function()
	ExecuteInGameThread(function() if lyrics_handler then pcall(lyrics_handler.Tick) end end)
	return false
end)

-- One-time catalog lyrics sweep: once the song catalog is loaded, queue every song lacking
-- lyrics so dadtool (`dad lyrics --queue`) can fetch them all -- no need to play each one.
-- Gated to run ONCE (flag); QueueRequest also de-dups, so nothing re-appends per frame.
if cfg.LYRICS_QUEUE_ALL ~= false then
	local sweeps = 0
	LoopAsync(8000, function()
		local state = _G.__SessionAggAccuracy
		if state.__queuedAllSongs then return true end
		sweeps = sweeps + 1
		local capped = sweeps >= 15            -- catalog never showed (~2 min) -> stop trying
		ExecuteInGameThread(function()
			if state.__queuedAllSongs then return end
			local n = nil
			pcall(function() if lyrics_handler then n = lyrics_handler.QueueAllFromCatalog() end end)
			if type(n) == "number" or capped then state.__queuedAllSongs = true end
		end)
		return state.__queuedAllSongs
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
RegisterKeyBind(Key.F4, function()
	_G.__SessionAggAccuracy.IsTrackerVisible = true
	hud_handler.UpdateModStatus(_G.__SessionAggAccuracy)
end)
RegisterKeyBind(Key.F5, function()
	_G.__SessionAggAccuracy.IsTrackerVisible = false
	hud_handler.UpdateModStatus(_G.__SessionAggAccuracy)
end)

-- ============ F6: Career Stats panel (toggle) ============
RegisterKeyBind(Key.F6, function()
	if stats_hud then ExecuteInGameThread(function() pcall(stats_hud.Toggle) end) end
end)
