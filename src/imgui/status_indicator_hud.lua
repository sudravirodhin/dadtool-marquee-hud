local M = {}
local umg_factory = require("utils.umg_factory")
local hud_utils = require("utils.hud_utils")
local cfg = require("config")

M.statusIndicatorWidget = nil
M.statusIndicatorValue = nil

function M.Create()
	local hud = umg_factory.CreateHUD("ModStatusHUD")
	if not hud then
		return
	end

	local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "ModStatusCanvas")
	local vBox = umg_factory.CreateVerticalBox(canvas, "StatusVBox")

	local hBox = umg_factory.CreateHorizontalBox(vBox, "StatusHBox")
	vBox:AddChild(hBox)

	umg_factory.CreateTextBlock(hBox, "StatusLabel", {
		size = 9,
		text = "♪ Marquee ",
		color = hud_utils.FSlateColor(1, 1, 1, 0.45),
	})

	M.statusIndicatorValue = umg_factory.CreateTextBlock(hBox, "StatusValue", {
		size = 9,
		text = "ON",
		color = hud_utils.FSlateColor(0.4, 1, 0.6, 0.7),
	})

	umg_factory.CreateTextBlock(vBox, "StatusVersion", {
		size = 7,
		text = string.format("v%s  /  UE4SS %s", cfg.MARQUEE_VERSION or "?", cfg.UE4SS_VERSION or "?"),
		color = hud_utils.FSlateColor(1, 1, 1, 0.3),
	})

	M.statusLevel = umg_factory.CreateTextBlock(vBox, "StatusLevel", {
		size = 10,
		text = "",
		color = hud_utils.FSlateColor(1, 1, 1, 0.9),
	})

	-- hub-only hint (this badge only shows in The Encore / DiveBar) pointing at the F6 stats panel
	umg_factory.CreateTextBlock(vBox, "StatsHint", {
		size = 8,
		text = "press F6 for stats",
		color = hud_utils.FSlateColor(0.55, 0.85, 1, 0.6),
	})

	local border = umg_factory.CreateBorder(canvas, "StatusBorder", {
		content = vBox,
		padding = { Left = 8, Top = 2, Right = 8, Bottom = 2 },
		brushColor = hud_utils.FLinearColor(0, 0, 0, 0.22),
	})

	umg_factory.ApplyAlignment(canvas, border, "bottomright")

	hud.Visibility = hud_utils.Visibility.HITTESTINVISIBLE
	hud:AddToViewport(999)
	M.statusIndicatorWidget = hud
end

function M.SetVisibility(v)
	if not M.statusIndicatorWidget or not M.statusIndicatorWidget:IsValid() then return end
	pcall(function() M.statusIndicatorWidget:SetVisibility(v) end)
end

-- Remove the badge from the viewport entirely (used when leaving the hub world).
function M.Destroy()
	if M.statusIndicatorWidget then
		pcall(function()
			if M.statusIndicatorWidget:IsValid() then M.statusIndicatorWidget:RemoveFromParent() end
		end)
	end
	M.statusIndicatorWidget = nil
	M.statusIndicatorValue = nil
	M.statusLevel = nil
end

-- show the current level + title, colored by tier
function M.SetLevel(text, rgb)
	if not M.statusLevel or not M.statusLevel:IsValid() then return end
	pcall(function()
		M.statusLevel:SetText(umg_factory.ToFText(text or ""))
		if rgb then M.statusLevel:SetColorAndOpacity(hud_utils.FSlateColor(rgb[1], rgb[2], rgb[3], 0.95)) end
	end)
end

function M.SetStatus(isOn)
	if not M.statusIndicatorValue or not M.statusIndicatorValue:IsValid() then
		return
	end
	pcall(function()
		if isOn then
			M.statusIndicatorValue:SetText(umg_factory.ToFText("ON"))
			M.statusIndicatorValue:SetColorAndOpacity(hud_utils.FSlateColor(0.4, 1, 0.6, 0.7))
		else
			M.statusIndicatorValue:SetText(umg_factory.ToFText("OFF"))
			M.statusIndicatorValue:SetColorAndOpacity(hud_utils.FSlateColor(1, 0.4, 0.4, 0.7))
		end
	end)
end

function M.IsValid()
	local isValid = M.statusIndicatorWidget and M.statusIndicatorWidget:IsValid()
	if isValid then
		local ok, inView = pcall(function()
			return M.statusIndicatorWidget:IsInViewport()
		end)
		if ok and not inView then
			return false
		end
	end
	return isValid
end

return M
