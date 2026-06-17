--[[ in_game_progress_hud.lua — the live in-game panel.
  Shows the game's OWN signals, polled (no hooks): Combo · Score · Sync% · ×Mult.
  Sync% is the rhythm gauge (MusicSyncMeter / max) — the DaD-native "how perfect am I". --]]
local M = {}
local cfg = require("config")
local hud_utils = require("utils.hud_utils")
local umg_factory = require("utils.umg_factory")
local combat_stats = require("combat.combat_stats")

M.progressWidget = nil
M.controls = {}



function M.Create()
	local hud = umg_factory.CreateHUD("InGameProgressHUD")
	if not hud then return end

	local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "InGameProgressCanvas")
	local vBox = umg_factory.CreateVerticalBox(canvas, "StatsVerticalBox")

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

	-- Only the two things the native HUD does NOT show: your PB to beat + a live sync %.
	row("PB    ", "pb")
	row("Sync  ", "sync", hud_utils.SyncColor(1))

	local border = umg_factory.CreateBorder(canvas, "InGameProgressBorder", { content = vBox })
	umg_factory.ApplyAlignment(canvas, border, cfg.HUD_MAIN_ALLIGNMENT or "topright",
		{ X = cfg.HUD_POS_X or -25, Y = cfg.HUD_POS_Y or 95 })

	hud.Visibility = hud_utils.Visibility.HIDDEN
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

	-- PB to beat (the native HUD never shows your personal best for a song)
	if state and state.CachedPB and state.CachedPB.highScore and state.CachedPB.highScore > 0 then
		set("pb", hud_utils.Abbrev(state.CachedPB.highScore))
	else
		set("pb", "—")
	end
	-- live sync % (the one rhythm number the game doesn't put on screen)
	if frac then
		set("sync", string.format("%d%%", math.floor(frac * 100 + 0.5)), hud_utils.SyncColor(frac))
	else
		set("sync", "—")
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
	M.controls = {}
end

function M.SetVisibility(visibility)
	if not M.progressWidget or not M.progressWidget:IsValid() then return end
	if M.progressWidget:GetVisibility() == visibility then return end
	pcall(function() M.progressWidget:SetVisibility(visibility) end)
end

function M.Toggle()
	if not M.progressWidget or not M.progressWidget:IsValid() then return false end
	local current = M.progressWidget:GetVisibility()
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
