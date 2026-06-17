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

function M.Create()
	if M.hudWidget then return end

	local hud = umg_factory.CreateHUD("InputOverlayHUD")
	if not hud then return end

	local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "InputOverlayCanvas")
	local border = umg_factory.CreateBorder(canvas, "InputOverlayBorder", {
		brushColor = hud_utils.FLinearColor(0, 0, 0, 0.2),
		padding = { Left = 5, Top = 5, Right = 5, Bottom = 5 }
	})
	M.borderWidget = border

	-- Set border alignment/size to fit the visual design
	-- Total size: 190 wide, 55 high + padding = 200x65
	local slot = umg_factory.ApplyAlignment(canvas, border, cfg.INPUT_OVERLAY_ALIGNMENT or "bottomleft",
		{ X = cfg.INPUT_OVERLAY_POS_X or 15, Y = cfg.INPUT_OVERLAY_POS_Y or -110 })
	
	slot:SetSize({ X = 200, Y = 65 })
	slot:SetAutoSize(false)

	-- Inner Canvas to place all graphical elements absolutely
	local innerCanvasClass = StaticFindObject("/Script/UMG.CanvasPanel")
	local innerCanvas = StaticConstructObject(innerCanvasClass, border, FName("OverlayInnerCanvas"))
	border:SetContent(innerCanvas)

	-- Helper to place widgets on innerCanvas
	local function Place(widget, x, y, w, h)
		local s = innerCanvas:AddChildToCanvas(widget)
		s:SetPosition({ X = x, Y = y })
		s:SetSize({ X = w, Y = h })
		s:SetAutoSize(false)
		return s
	end

	-- Colors
	local COLOR_ACTIVE = hud_utils.FLinearColor(0.0, 0.9, 1.0, 0.9) -- Electric Cyan
	local COLOR_INACTIVE = hud_utils.FLinearColor(0.02, 0.02, 0.04, 0.6) -- Dark Slate
	local TEXT_COLOR_ACTIVE = hud_utils.FSlateColor(0.0, 1.0, 1.0, 1.0)
	local TEXT_COLOR_INACTIVE = hud_utils.FSlateColor(1.0, 1.0, 1.0, 0.25)

	-- Gamepad Colors
	local COLOR_GP_Y_INACTIVE = hud_utils.FLinearColor(0.8, 0.7, 0.0, 0.15)
	local COLOR_GP_X_INACTIVE = hud_utils.FLinearColor(0.1, 0.5, 1.0, 0.15)
	local COLOR_GP_B_INACTIVE = hud_utils.FLinearColor(0.9, 0.1, 0.1, 0.15)
	local COLOR_GP_A_INACTIVE = hud_utils.FLinearColor(0.1, 0.7, 0.1, 0.15)

	local COLOR_GP_X_ACTIVE = hud_utils.FLinearColor(0.0, 0.8, 1.0, 0.95)
	local COLOR_GP_A_ACTIVE = hud_utils.FLinearColor(0.1, 1.0, 0.1, 0.95)

	local TEXT_GP_INACTIVE = hud_utils.FSlateColor(1.0, 1.0, 1.0, 0.2)
	local TEXT_GP_ACTIVE = hud_utils.FSlateColor(1.0, 1.0, 1.0, 1.0)

	-- Helper to create styled keycap border + text centered
	local function CreateKey(name, label)
		local b = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName(name .. "_Border"))
		b:SetBrushColor(COLOR_INACTIVE)
		b:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
		b:SetHorizontalAlignment(1) -- Center
		b:SetVerticalAlignment(1) -- Center

		local t = nil
		if label and label ~= "" then
			t = umg_factory.CreateTextBlock(b, name .. "_Text", {
				size = 8,
				text = label,
				color = TEXT_COLOR_INACTIVE,
				outline = { size = 0 } -- No outline for clean flat look
			})
		end
		return b, t
	end

	-- 1. Keyboard Cluster (X=0 to X=68, Y=0 to Y=55)
	local wBorder, wText = CreateKey("KeyW", "W") Place(wBorder, 24, 0, 20, 17)
	local aBorder, aText = CreateKey("KeyA", "A") Place(aBorder, 0, 19, 20, 17)
	local sBorder, sText = CreateKey("KeyS", "S") Place(sBorder, 24, 19, 20, 17)
	local dBorder, dText = CreateKey("KeyD", "D") Place(dBorder, 48, 19, 20, 17)
	local spaceBorder, spaceText = CreateKey("KeySpace", "Space") Place(spaceBorder, 0, 38, 68, 14)

	-- 2. Mouse Graphic (X=80 to X=114, Y=0 to Y=55)
	-- Mouse Plate / Outline back
	local mouseBody = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_Body"))
	mouseBody:SetBrushColor(hud_utils.FLinearColor(0.02, 0.02, 0.04, 0.25))
	mouseBody:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(mouseBody, 80, 20, 34, 32)

	-- Left / Right Click buttons
	local lClickBorder = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_L"))
	lClickBorder:SetBrushColor(COLOR_INACTIVE)
	lClickBorder:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(lClickBorder, 80, 0, 16, 18)

	local rClickBorder = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_R"))
	rClickBorder:SetBrushColor(COLOR_INACTIVE)
	rClickBorder:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(rClickBorder, 98, 0, 16, 18)

	-- Scroll wheel
	local scrollWheel = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_Wheel"))
	scrollWheel:SetBrushColor(hud_utils.FLinearColor(1.0, 0.5, 0.0, 0.8)) -- Orange scroll wheel
	scrollWheel:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(scrollWheel, 96, 3, 2, 8)

	-- 3. Gamepad Cluster (X=130 to X=190, Y=0 to Y=55)
	-- Gamepad plate background
	local gpBody = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Gamepad_Body"))
	gpBody:SetBrushColor(hud_utils.FLinearColor(0.02, 0.02, 0.04, 0.25))
	gpBody:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(gpBody, 130, 0, 56, 52)

	-- Helper to create gamepad face buttons
	local function CreateGpBtn(name, label, color)
		local b = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName(name .. "_Border"))
		b:SetBrushColor(color)
		b:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
		b:SetHorizontalAlignment(1)
		b:SetVerticalAlignment(1)
		local t = umg_factory.CreateTextBlock(b, name .. "_Text", {
			size = 7,
			text = label,
			color = TEXT_GP_INACTIVE,
			outline = { size = 0 }
		})
		return b, t
	end

	local gpYBorder, gpYText = CreateGpBtn("GpY", "Y", COLOR_GP_Y_INACTIVE) Place(gpYBorder, 149, 0, 18, 17)
	local gpXBorder, gpXText = CreateGpBtn("GpX", "X", COLOR_GP_X_INACTIVE) Place(gpXBorder, 131, 17, 18, 17)
	local gpBBorder, gpBText = CreateGpBtn("GpB", "B", COLOR_GP_B_INACTIVE) Place(gpBBorder, 167, 17, 18, 17)
	local gpABorder, gpAText = CreateGpBtn("GpA", "A", COLOR_GP_A_INACTIVE) Place(gpABorder, 149, 34, 18, 17)

	-- Setup buttons array with cached FName instances
	M.buttons = {
		{ key = "W", fname = FName("W"), border = wBorder, text = wText, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "A", fname = FName("A"), border = aBorder, text = aText, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "S", fname = FName("S"), border = sBorder, text = sText, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "D", fname = FName("D"), border = dBorder, text = dText, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "SpaceBar", fname = FName("SpaceBar"), border = spaceBorder, text = spaceText, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "LeftMouseButton", fname = FName("LeftMouseButton"), border = lClickBorder, text = nil, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE },
		{ key = "RightMouseButton", fname = FName("RightMouseButton"), border = rClickBorder, text = nil, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE },
		{ key = "Gamepad_FaceButton_Bottom", fname = FName("Gamepad_FaceButton_Bottom"), border = gpABorder, text = gpAText, activeColor = COLOR_GP_A_ACTIVE, inactiveColor = COLOR_GP_A_INACTIVE, activeTextColor = TEXT_GP_ACTIVE, inactiveTextColor = TEXT_GP_INACTIVE },
		{ key = "Gamepad_FaceButton_Left", fname = FName("Gamepad_FaceButton_Left"), border = gpXBorder, text = gpXText, activeColor = COLOR_GP_X_ACTIVE, inactiveColor = COLOR_GP_X_INACTIVE, activeTextColor = TEXT_GP_ACTIVE, inactiveTextColor = TEXT_GP_INACTIVE },
	}

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
			isDown = pc:IsInputKeyDown(b.fname)
		end)

		if isDown then
			b.border:SetBrushColor(b.activeColor)
			if b.text then b.text:SetColorAndOpacity(b.activeTextColor) end
		else
			b.border:SetBrushColor(b.inactiveColor)
			if b.text then b.text:SetColorAndOpacity(b.inactiveTextColor) end
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
