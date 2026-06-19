--[[ in_game_progress_hud.lua — the live in-game panel.
  Shows the game's OWN signals, polled (no hooks): Combo · Score · Sync% · ×Mult.
  Sync% is the rhythm gauge (MusicSyncMeter / max) — the DaD-native "how perfect am I". --]]
local M = {}
local cfg = require("config")
local hud_utils = require("utils.hud_utils")
local umg_factory = require("utils.umg_factory")
local combat_stats = require("combat.combat_stats")

M.progressWidget = nil
M.borderWidget = nil
M.controls = {}

function M.Create()
	local hud = umg_factory.CreateHUD("InGameProgressHUD")
	if not hud then return end

	local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "InGameProgressCanvas")
	local border = umg_factory.CreateBorder(canvas, "InGameProgressBorder")
	M.borderWidget = border
	local vBox = umg_factory.CreateVerticalBox(border, "StatsVerticalBox")

	local function row(label, key, valColor)
		local hBox = umg_factory.CreateHorizontalBox(vBox, "HBox_" .. key)
		umg_factory.CreateTextBlock(hBox, "Lbl_" .. key, {
			size = 11, text = label, skew = 0.176,
			shadowOffset = { X = 0.2, Y = 0.2 }, shadowColor = hud_utils.FLinearColor(0, 0, 0, 1),
		})
		M.controls[key] = umg_factory.CreateTextBlock(hBox, "Val_" .. key, {
			size = 11, text = "—", color = valColor or hud_utils.FSlateColor(1, 1, 1, 0.9),
		})
	end

	-- Setup HUD elements aligned to 6-character labels for perfect spacing
	row("BPM   ", "bpm")
	row("Sync  ", "sync", hud_utils.SyncColor(1))
	row("Streak", "streak")
	row("PB    ", "pb")
	row("Delta ", "pb_delta")
	row("Hype  ", "hype")

	umg_factory.ApplyAlignment(canvas, border, cfg.HUD_MAIN_ALLIGNMENT or "topright",
		{ X = cfg.HUD_POS_X or -25, Y = cfg.HUD_POS_Y or 95 })

	hud.Visibility = hud_utils.Visibility.HIDDEN
	M._cachedVisibility = hud_utils.Visibility.HIDDEN
	hud:AddToViewport(999)
	M.progressWidget = hud
end

function M.Update(state, snap)
	if not M.progressWidget or not M.progressWidget:IsValid() then return end
	if not M.controls then return end
	snap = snap or {}

	local function set(key, text, color)
		local c = M.controls[key]
		if c and c:IsValid() then
			pcall(function()
				c:SetText(umg_factory.ToFText(text))
				if color then c:SetColorAndOpacity(color) end
			end)
		end
	end

	local frac = combat_stats.SyncFraction(snap)

	-- 1. Song BPM (Tempo)
	if state and type(state.Bpm) == "number" and state.Bpm > 0 then
		set("bpm", string.format("%d", math.floor(state.Bpm + 0.5)))
	else
		set("bpm", "—", hud_utils.FSlateColor(1, 1, 1, 0.5))
	end

	-- 2. Live sync %
	if frac then
		set("sync", string.format("%d%%", math.floor(frac * 100 + 0.5)), hud_utils.SyncColor(frac))
	else
		set("sync", "—")
	end

	-- 3. Perfect Streak (Sync Streak)
	if state and type(state.SyncStreak) == "number" and type(state.SyncStreakMax) == "number" then
		local current = state.SyncStreak
		local max = state.SyncStreakMax
		local color = (current > 0 and current == max) and hud_utils.FSlateColor(0.1, 1, 0.1, 0.9) or hud_utils.FSlateColor(1, 1, 1, 0.9)
		set("streak", string.format("%d / %d", current, max), color)
	else
		set("streak", "—", hud_utils.FSlateColor(1, 1, 1, 0.5))
	end

	-- 4. PB to beat
	if state and state.CachedPB and state.CachedPB.highScore and state.CachedPB.highScore > 0 then
		set("pb", hud_utils.Abbrev(state.CachedPB.highScore))
	else
		set("pb", "—")
	end

	-- 5. Live PB Delta (ghost tracker)
	if state and type(state.PbDelta) == "number" then
		local d = state.PbDelta
		local prefix = d >= 0 and "+" or ""
		local color = d >= 0 and hud_utils.FSlateColor(0.1, 1, 0.1, 0.9) or hud_utils.FSlateColor(1, 0.2, 0.2, 0.9)
		set("pb_delta", string.format("%s%s", prefix, hud_utils.Commafy(math.floor(d + 0.5))), color)
	else
		set("pb_delta", "—", hud_utils.FSlateColor(1, 1, 1, 0.5))
	end

	-- 6. Hype status and flare-up indicator
	if state and state.HypeStatus then
		local is_on_fire = (state.HypeStatus == "ON FIRE")
		local color = is_on_fire and hud_utils.FSlateColor(1, 0.5, 0, 1) or hud_utils.FSlateColor(1, 1, 1, 0.5)
		set("hype", state.HypeStatus, color)

		-- Flare up the border brush color
		if M.borderWidget and M.borderWidget:IsValid() then
			pcall(function()
				if is_on_fire then
					-- Glowing orange/gold background
					M.borderWidget:SetBrushColor(hud_utils.FLinearColor(1, 0.5, 0, 0.6))
				else
					-- Standard semi-transparent black background
					M.borderWidget:SetBrushColor(hud_utils.FLinearColor(0, 0, 0, 0.2))
				end
			end)
		end
	else
		set("hype", "—", hud_utils.FSlateColor(1, 1, 1, 0.5))
	end
end

-- Remove the stats panel from the viewport entirely (used when leaving gameplay).
function M.Destroy()
	if M.progressWidget then
		pcall(function()
			if M.progressWidget:IsValid() then M.progressWidget:RemoveFromParent() end
		end)
	end
	M.progressWidget = nil
	M.borderWidget = nil
	M.controls = {}
	M._cachedVisibility = nil
end

function M.SetVisibility(visibility)
	if not M.progressWidget or not M.progressWidget:IsValid() then return end
	if M._cachedVisibility == visibility then return end
	pcall(function() M.progressWidget:SetVisibility(visibility) end)
	M._cachedVisibility = visibility
end

function M.Toggle()
	if not M.progressWidget or not M.progressWidget:IsValid() then return false end
	local current = M._cachedVisibility or hud_utils.Visibility.HIDDEN
	local nextVisibility = (
		current == hud_utils.Visibility.HITTESTINVISIBLE and hud_utils.Visibility.HIDDEN
		or hud_utils.Visibility.HITTESTINVISIBLE
	)
	M.SetVisibility(nextVisibility)
	return nextVisibility == hud_utils.Visibility.HITTESTINVISIBLE
end

function M.IsValid()
	local isValid = M.progressWidget and M.progressWidget:IsValid()
	if isValid then
		local ok, inView = pcall(function() return M.progressWidget:IsInViewport() end)
		if ok and not inView then return false end
	end
	return isValid
end

return M
