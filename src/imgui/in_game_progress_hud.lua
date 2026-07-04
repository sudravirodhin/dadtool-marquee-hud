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
	M.Destroy()
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
	row("Fever ", "fever", hud_utils.SyncColor(1))
	row("Mult  ", "mult")
	row("Combo ", "combo")
	row("PB    ", "pb")
	row("Delta ", "pb_delta")

	umg_factory.ApplyAlignment(canvas, border, cfg.HUD_MAIN_ALLIGNMENT or "topright",
		{ X = cfg.HUD_POS_X or -25, Y = cfg.HUD_POS_Y or 95 })

	hud.Visibility = hud_utils.Visibility.HIDDEN
	M._cachedVisibility = hud_utils.Visibility.HIDDEN
	hud:AddToViewport(999)
	M.progressWidget = hud
end

local function call_set_text(textBlock, fText)
	textBlock:SetText(fText)
end

local function call_set_color(textBlock, color)
	textBlock:SetColorAndOpacity(color)
end

local function call_set_brush_color(border, color)
	border:SetBrushColor(color)
end

local function call_remove_from_parent(widget)
	widget:RemoveFromParent()
end

local function call_set_visibility(widget, vis)
	widget:SetVisibility(vis)
end

local function call_is_in_viewport(widget)
	return widget:IsInViewport()
end

local function set_widget_val(key, text, color)
	local c = M.controls[key]
	if c and c:IsValid() then
		local fText = umg_factory.ToFText(text)
		pcall(call_set_text, c, fText)
		if color then
			pcall(call_set_color, c, color)
		end
	end
end

function M.Update(state, snap)
	if not M.progressWidget or not M.progressWidget:IsValid() then return end
	if not M.controls then return end
	snap = snap or {}

	local frac = combat_stats.SyncFraction(snap)

	-- 1. Song BPM (Tempo)
	if state and type(state.Bpm) == "number" and state.Bpm > 0 then
		set_widget_val("bpm", string.format("%d", math.floor(state.Bpm + 0.5)))
	else
		set_widget_val("bpm", "—", hud_utils.FSlateColor(1, 1, 1, 0.5))
	end

	-- 2. Live Fever %
	if frac then
		set_widget_val("fever", string.format("%d%%", math.floor(frac * 100 + 0.5)), hud_utils.SyncColor(frac))
	else
		set_widget_val("fever", "—")
	end

	-- 3. Combo / Max Combo
	if state and type(state.Combo) == "number" and type(state.MaxCombo) == "number" then
		local current = state.Combo
		local max = state.MaxCombo
		local color = (current > 0 and current == max) and hud_utils.FSlateColor(0.1, 1, 0.1, 0.9) or hud_utils.FSlateColor(0.2, 0.9, 1, 0.9)
		set_widget_val("combo", string.format("%d (max %d)", current, max), color)
	else
		set_widget_val("combo", "—", hud_utils.FSlateColor(0.2, 0.9, 1, 0.5))
	end

	-- 4. Score Multiplier
	local multVal = (state and state.Multiplier) or (snap and snap.mult)
	if type(multVal) == "number" then
		set_widget_val("mult", string.format("x%.1f", multVal), hud_utils.FSlateColor(1, 0.85, 0.2, 0.9))
	else
		set_widget_val("mult", "—", hud_utils.FSlateColor(1, 0.85, 0.2, 0.5))
	end

	-- 5. PB to beat
	if state and state.CachedPB and state.CachedPB.highScore and state.CachedPB.highScore > 0 then
		set_widget_val("pb", hud_utils.Abbrev(state.CachedPB.highScore))
	else
		set_widget_val("pb", "—")
	end

	-- 6. Live PB Delta (ghost tracker)
	if state and type(state.PbDelta) == "number" then
		local d = state.PbDelta
		local prefix = d >= 0 and "+" or ""
		local color = d >= 0 and hud_utils.FSlateColor(0.1, 1, 0.1, 0.9) or hud_utils.FSlateColor(1, 0.2, 0.2, 0.9)
		set_widget_val("pb_delta", string.format("%s%s", prefix, hud_utils.Commafy(math.floor(d + 0.5))), color)
	else
		set_widget_val("pb_delta", "—", hud_utils.FSlateColor(1, 1, 1, 0.5))
	end
end

-- Remove the stats panel from the viewport entirely (used when leaving gameplay).
function M.Destroy()
	if M.progressWidget then
		pcall(call_remove_from_parent, M.progressWidget)
	end
	M.progressWidget = nil
	M.borderWidget = nil
	M.controls = {}
	M._cachedVisibility = nil
end

function M.SetVisibility(visibility)
	if not M.progressWidget or not M.progressWidget:IsValid() then return end
	if M._cachedVisibility == visibility then return end
	pcall(call_set_visibility, M.progressWidget, visibility)
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
		local ok, inView = pcall(call_is_in_viewport, M.progressWidget)
		if ok and not inView then return false end
	end
	return isValid
end

return M
