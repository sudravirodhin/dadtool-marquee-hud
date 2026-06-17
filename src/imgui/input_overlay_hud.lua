--[[ input_overlay_hud.lua — graphical on-screen representation of real-time inputs.
  Displays a layout of movement, utility, and combat buttons, lighting them up
  interactively via live APlayerController input queries. --]]
local M = {}
local cfg = require("config")
local hud_utils = require("utils.hud_utils")
local umg_factory = require("utils.umg_factory")

M.hudWidget = nil
M.borderWidget = nil
M.buttons = {} -- stores key definitions and widget handles

-- Accent palette
local COLOR_ACTIVE = hud_utils.FLinearColor(0.0, 1.0, 1.0, 0.8) -- Cyan/electric glow
local COLOR_INACTIVE = hud_utils.FLinearColor(0.0, 0.0, 0.0, 0.45) -- Semi-transparent dark slate
local TEXT_COLOR_ACTIVE = hud_utils.FSlateColor(0.0, 1.0, 1.0, 1.0)
local TEXT_COLOR_INACTIVE = hud_utils.FSlateColor(1.0, 1.0, 1.0, 0.4)

function M.Create()
	if M.hudWidget then return end

	local hud = umg_factory.CreateHUD("InputOverlayHUD")
	if not hud then return end

	local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "InputOverlayCanvas")
	local border = umg_factory.CreateBorder(canvas, "InputOverlayBorder", {
		brushColor = hud_utils.FLinearColor(0, 0, 0, 0.05),
		padding = { Left = 8, Top = 8, Right = 8, Bottom = 8 }
	})
	M.borderWidget = border

	-- Main horizontal layout (left: keyboard keys, right: gamepad/mouse clicks)
	local mainHBox = umg_factory.CreateHorizontalBox(border, "InputOverlayMainHBox")

	-- Left column: Keyboard WASD + Space
	local kbVBox = umg_factory.CreateVerticalBox(mainHBox, "KbVBox")
	
	-- Row 1: W Key (horizontal box with side spacers for centering W over ASD)
	local wHBox = umg_factory.CreateHorizontalBox(kbVBox, "WHBox")
	umg_factory.CreateTextBlock(wHBox, "WSpacer1", { size = 10, text = "      " }) -- centering spacer
	local wBorder = umg_factory.CreateBorder(wHBox, "WBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 6, Top = 3, Right = 6, Bottom = 3 }
	})
	local wText = umg_factory.CreateTextBlock(wBorder, "WText", { size = 9, text = "W", color = TEXT_COLOR_INACTIVE })
	
	-- Row 2: A S D Keys
	local asdHBox = umg_factory.CreateHorizontalBox(kbVBox, "ASDHBox")
	local aBorder = umg_factory.CreateBorder(asdHBox, "ABorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 6, Top = 3, Right = 6, Bottom = 3 }
	})
	local aText = umg_factory.CreateTextBlock(aBorder, "AText", { size = 9, text = "A", color = TEXT_COLOR_INACTIVE })

	local sBorder = umg_factory.CreateBorder(asdHBox, "SBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 6, Top = 3, Right = 6, Bottom = 3 }
	})
	local sText = umg_factory.CreateTextBlock(sBorder, "SText", { size = 9, text = "S", color = TEXT_COLOR_INACTIVE })

	local dBorder = umg_factory.CreateBorder(asdHBox, "DBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 6, Top = 3, Right = 6, Bottom = 3 }
	})
	local dText = umg_factory.CreateTextBlock(dBorder, "DText", { size = 9, text = "D", color = TEXT_COLOR_INACTIVE })

	-- Row 3: SpaceBar
	local spaceBorder = umg_factory.CreateBorder(kbVBox, "SpaceBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 16, Top = 2, Right = 16, Bottom = 2 }
	})
	local spaceText = umg_factory.CreateTextBlock(spaceBorder, "SpaceText", { size = 9, text = "   Space   ", color = TEXT_COLOR_INACTIVE })

	-- Column separator
	umg_factory.CreateTextBlock(mainHBox, "ColumnSeparator", { size = 10, text = "   " })

	-- Right column: Mouse Clicks + Gamepad Face Buttons
	local rightVBox = umg_factory.CreateVerticalBox(mainHBox, "RightVBox")

	-- Mouse Click Row
	local mouseHBox = umg_factory.CreateHorizontalBox(rightVBox, "MouseHBox")
	local lClickBorder = umg_factory.CreateBorder(mouseHBox, "LClickBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 4, Top = 3, Right = 4, Bottom = 3 }
	})
	local lClickText = umg_factory.CreateTextBlock(lClickBorder, "LClickText", { size = 8, text = "L-Click", color = TEXT_COLOR_INACTIVE })

	local rClickBorder = umg_factory.CreateBorder(mouseHBox, "RClickBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 4, Top = 3, Right = 4, Bottom = 3 }
	})
	local rClickText = umg_factory.CreateTextBlock(rClickBorder, "RClickText", { size = 8, text = "R-Click", color = TEXT_COLOR_INACTIVE })

	-- Gamepad Action Row (A / X)
	local gpActionHBox = umg_factory.CreateHorizontalBox(rightVBox, "GpActionHBox")
	local gpABorder = umg_factory.CreateBorder(gpActionHBox, "GpABorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 6, Top = 3, Right = 6, Bottom = 3 }
	})
	local gpAText = umg_factory.CreateTextBlock(gpABorder, "GpAText", { size = 8, text = "GP-A", color = TEXT_COLOR_INACTIVE })

	local gpXBorder = umg_factory.CreateBorder(gpActionHBox, "GpXBorder", {
		brushColor = COLOR_INACTIVE,
		padding = { Left = 6, Top = 3, Right = 6, Bottom = 3 }
	})
	local gpXText = umg_factory.CreateTextBlock(gpXBorder, "GpXText", { size = 8, text = "GP-X", color = TEXT_COLOR_INACTIVE })

	M.buttons = {
		{ key = "W", border = wBorder, text = wText },
		{ key = "A", border = aBorder, text = aText },
		{ key = "S", border = sBorder, text = sText },
		{ key = "D", border = dBorder, text = dText },
		{ key = "SpaceBar", border = spaceBorder, text = spaceText },
		{ key = "LeftMouseButton", border = lClickBorder, text = lClickText },
		{ key = "RightMouseButton", border = rClickBorder, text = rClickText },
		{ key = "Gamepad_FaceButton_Bottom", border = gpABorder, text = gpAText },
		{ key = "Gamepad_FaceButton_Left", border = gpXBorder, text = gpXText },
	}

	-- Align layout (defaults to bottomleft, stacked neatly above stats panel)
	umg_factory.ApplyAlignment(canvas, border, cfg.INPUT_OVERLAY_ALIGNMENT or "bottomleft",
		{ X = cfg.INPUT_OVERLAY_POS_X or 15, Y = cfg.INPUT_OVERLAY_POS_Y or -110 })

	hud.Visibility = hud_utils.Visibility.HIDDEN
	M._cachedVisibility = hud_utils.Visibility.HIDDEN
	hud:AddToViewport(999)
	M.hudWidget = hud
end

function M.Update(pc)
	if not M.hudWidget or not M.hudWidget:IsValid() then return end
	if not pc or not pc:IsValid() then return end

	for _, b in ipairs(M.buttons) do
		local isDown = false
		pcall(function()
			isDown = pc:IsInputKeyDown({ KeyName = b.key })
		end)

		if isDown then
			b.border:SetBrushColor(COLOR_ACTIVE)
			b.text:SetColorAndOpacity(TEXT_COLOR_ACTIVE)
		else
			b.border:SetBrushColor(COLOR_INACTIVE)
			b.text:SetColorAndOpacity(TEXT_COLOR_INACTIVE)
		end
	end
end

function M.Destroy()
	if M.hudWidget then
		pcall(function()
			if M.hudWidget:IsValid() then M.hudWidget:RemoveFromParent() end
		end)
	end
	M.hudWidget = nil
	M.borderWidget = nil
	M.buttons = {}
	M._cachedVisibility = nil
end

function M.SetVisibility(visibility)
	if not M.hudWidget or not M.hudWidget:IsValid() then return end
	if M._cachedVisibility == visibility then return end
	pcall(function() M.hudWidget:SetVisibility(visibility) end)
	M._cachedVisibility = visibility
end

function M.IsValid()
	local isValid = M.hudWidget and M.hudWidget:IsValid()
	if isValid then
		local ok, inView = pcall(function() return M.hudWidget:IsInViewport() end)
		if ok and not inView then return false end
	end
	return isValid
end

return M
