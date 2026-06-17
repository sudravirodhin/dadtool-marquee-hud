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

-- Pre-cached FName instances for analog/dpad/triggers to avoid heap allocations
M.fnameLeftX = nil
M.fnameLeftY = nil
M.fnameDPadUp = nil
M.fnameDPadDown = nil
M.fnameDPadLeft = nil
M.fnameDPadRight = nil

local lastUpdate = 0

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
	-- Total size: 190 wide, 70 high + padding = 200x80
	local slot = umg_factory.ApplyAlignment(canvas, border, cfg.INPUT_OVERLAY_ALIGNMENT or "bottomleft",
		{ X = cfg.INPUT_OVERLAY_POS_X or 15, Y = cfg.INPUT_OVERLAY_POS_Y or -110 })
	
	slot:SetSize({ X = 200, Y = 80 })
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

	-- Gamepad Colors (dim placeholders matching Xbox ABXY layout)
	local COLOR_GP_Y_INACTIVE = hud_utils.FLinearColor(0.8, 0.7, 0.0, 0.15)
	local COLOR_GP_X_INACTIVE = hud_utils.FLinearColor(0.1, 0.5, 1.0, 0.15)
	local COLOR_GP_B_INACTIVE = hud_utils.FLinearColor(0.9, 0.1, 0.1, 0.15)
	local COLOR_GP_A_INACTIVE = hud_utils.FLinearColor(0.1, 0.7, 0.1, 0.15)

	local COLOR_GP_Y_ACTIVE = hud_utils.FLinearColor(1.0, 0.85, 0.0, 0.95)
	local COLOR_GP_X_ACTIVE = hud_utils.FLinearColor(0.0, 0.7, 1.0, 0.95)
	local COLOR_GP_B_ACTIVE = hud_utils.FLinearColor(1.0, 0.15, 0.15, 0.95)
	local COLOR_GP_A_ACTIVE = hud_utils.FLinearColor(0.1, 0.9, 0.1, 0.95)

	local TEXT_GP_INACTIVE = hud_utils.FSlateColor(1.0, 1.0, 1.0, 0.2)
	local TEXT_GP_ACTIVE = hud_utils.FSlateColor(1.0, 1.0, 1.0, 1.0)

	-- Helper to create styled keycap border + text centered
	local function CreateKey(name, label, sizeVal)
		local b = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName(name .. "_Border"))
		b:SetBrushColor(COLOR_INACTIVE)
		b:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
		b:SetHorizontalAlignment(1) -- Center
		b:SetVerticalAlignment(1) -- Center

		local t = nil
		if label and label ~= "" then
			t = umg_factory.CreateTextBlock(b, name .. "_Text", {
				size = sizeVal or 8,
				text = label,
				color = TEXT_COLOR_INACTIVE,
				outline = { size = 0 } -- No outline for clean flat look
			})
		end
		return b, t
	end

	-- 1. Keyboard Cluster (X=0 to X=68, shifted down to center vertically in 80px box)
	local wBorder, wText = CreateKey("KeyW", "W") Place(wBorder, 24, 8, 20, 17)
	local aBorder, aText = CreateKey("KeyA", "A") Place(aBorder, 0, 27, 20, 17)
	local sBorder, sText = CreateKey("KeyS", "S") Place(sBorder, 24, 27, 20, 17)
	local dBorder, dText = CreateKey("KeyD", "D") Place(dBorder, 48, 27, 20, 17)
	local spaceBorder, spaceText = CreateKey("KeySpace", "Space") Place(spaceBorder, 0, 46, 68, 14)

	-- 2. Mouse Graphic (X=80 to X=114, shifted down to center vertically)
	-- Mouse Plate / Outline back
	local mouseBody = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_Body"))
	mouseBody:SetBrushColor(hud_utils.FLinearColor(0.02, 0.02, 0.04, 0.25))
	mouseBody:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(mouseBody, 80, 30, 34, 32)

	-- Left / Right Click buttons
	local lClickBorder = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_L"))
	lClickBorder:SetBrushColor(COLOR_INACTIVE)
	lClickBorder:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(lClickBorder, 80, 8, 16, 22)

	local rClickBorder = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_R"))
	rClickBorder:SetBrushColor(COLOR_INACTIVE)
	rClickBorder:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(rClickBorder, 98, 8, 16, 22)

	-- Scroll wheel
	local scrollWheel = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Mouse_Wheel"))
	scrollWheel:SetBrushColor(hud_utils.FLinearColor(1.0, 0.5, 0.0, 0.8)) -- Orange scroll wheel
	scrollWheel:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(scrollWheel, 96, 11, 2, 10)

	-- 3. Gamepad Cluster (X=130 to X=190, Y=0 to Y=74)
	-- Gamepad plate background
	local gpBody = StaticConstructObject(StaticFindObject("/Script/UMG.Border"), innerCanvas, FName("Gamepad_Body"))
	gpBody:SetBrushColor(hud_utils.FLinearColor(0.02, 0.02, 0.04, 0.25))
	gpBody:SetPadding({ Left = 0, Top = 0, Right = 0, Bottom = 0 })
	Place(gpBody, 130, 0, 56, 74)

	-- Bumpers / Triggers: L1/L2 and R1/R2
	local l1Border, l1Text = CreateKey("GpL1", "L1", 6) Place(l1Border, 130, 3, 26, 8)
	local l2Border, l2Text = CreateKey("GpL2", "L2", 6) Place(l2Border, 130, 12, 26, 8)
	local r1Border, r1Text = CreateKey("GpR1", "R1", 6) Place(r1Border, 160, 3, 26, 8)
	local r2Border, r2Text = CreateKey("GpR2", "R2", 6) Place(r2Border, 160, 12, 26, 8)

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

	-- Diamond Layout (symmetrical center (156, 47))
	local gpYBorder, gpYText = CreateGpBtn("GpY", "Y", COLOR_GP_Y_INACTIVE) Place(gpYBorder, 148, 23, 16, 16)
	local gpXBorder, gpXText = CreateGpBtn("GpX", "X", COLOR_GP_X_INACTIVE) Place(gpXBorder, 132, 39, 16, 16)
	local gpBBorder, gpBText = CreateGpBtn("GpB", "B", COLOR_GP_B_INACTIVE) Place(gpBBorder, 164, 39, 16, 16)
	local gpABorder, gpAText = CreateGpBtn("GpA", "A", COLOR_GP_A_INACTIVE) Place(gpABorder, 148, 55, 16, 16)

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
		{ key = "Gamepad_FaceButton_Top", fname = FName("Gamepad_FaceButton_Top"), border = gpYBorder, text = gpYText, activeColor = COLOR_GP_Y_ACTIVE, inactiveColor = COLOR_GP_Y_INACTIVE, activeTextColor = TEXT_GP_ACTIVE, inactiveTextColor = TEXT_GP_INACTIVE },
		{ key = "Gamepad_FaceButton_Right", fname = FName("Gamepad_FaceButton_Right"), border = gpBBorder, text = gpBText, activeColor = COLOR_GP_B_ACTIVE, inactiveColor = COLOR_GP_B_INACTIVE, activeTextColor = TEXT_GP_ACTIVE, inactiveTextColor = TEXT_GP_INACTIVE },
		{ key = "Gamepad_LeftShoulder", fname = FName("Gamepad_LeftShoulder"), border = l1Border, text = l1Text, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "Gamepad_RightShoulder", fname = FName("Gamepad_RightShoulder"), border = r1Border, text = r1Text, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "Gamepad_LeftTrigger", fname = FName("Gamepad_LeftTrigger"), border = l2Border, text = l2Text, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
		{ key = "Gamepad_RightTrigger", fname = FName("Gamepad_RightTrigger"), border = r2Border, text = r2Text, activeColor = COLOR_ACTIVE, inactiveColor = COLOR_INACTIVE, activeTextColor = TEXT_COLOR_ACTIVE, inactiveTextColor = TEXT_COLOR_INACTIVE },
	}

	-- Pre-cache input parameters to avoid high frequency allocations
	M.fnameLeftX = FName("Gamepad_LeftX")
	M.fnameLeftY = FName("Gamepad_LeftY")
	M.fnameDPadUp = FName("Gamepad_DPad_Up")
	M.fnameDPadDown = FName("Gamepad_DPad_Down")
	M.fnameDPadLeft = FName("Gamepad_DPad_Left")
	M.fnameDPadRight = FName("Gamepad_DPad_Right")

	hud.Visibility = hud_utils.Visibility.HIDDEN
	M._cachedVisibility = hud_utils.Visibility.HIDDEN
	hud:AddToViewport(999)
	M.hudWidget = hud
end

function M.Update(pc)
	local now = os.clock()
	if now - lastUpdate < 0.03 then return end -- throttle updates to ~33fps (30ms)
	lastUpdate = now

	if not M.hudWidget or not M.hudWidget:IsValid() then return end
	if not pc or not pc:IsValid() then return end

	-- 1. Query analog stick values
	local leftX = 0
	local leftY = 0
	local okX, valX = pcall(function() return pc:GetInputAnalogKeyState({ KeyName = M.fnameLeftX }) end)
	local okY, valY = pcall(function() return pc:GetInputAnalogKeyState({ KeyName = M.fnameLeftY }) end)
	if okX and valX then leftX = valX end
	if okY and valY then leftY = valY end

	-- Fallback check using GetInputAnalogStickState
	local stickX = 0
	local stickY = 0
	pcall(function()
		local sx, sy = pc:GetInputAnalogStickState(0) -- 0: LeftStick
		if sx and sy then
			stickX = sx
			stickY = sy
		end
	end)

	-- If GetInputAnalogKeyState returned zero but GetInputAnalogStickState got values, use them
	if leftX == 0 and leftY == 0 then
		leftX = stickX
		leftY = stickY
	end

	-- 2. Process all mapped buttons
	for _, b in ipairs(M.buttons) do
		local isDown = false
		pcall(function()
			isDown = pc:IsInputKeyDown({ KeyName = b.fname })
		end)

		-- Triggers: check analog state as fallback because they are axes
		if b.key == "Gamepad_LeftTrigger" then
			local trigVal = 0
			pcall(function() trigVal = pc:GetInputAnalogKeyState({ KeyName = b.fname }) end)
			local trigValAxis = 0
			pcall(function() trigValAxis = pc:GetInputAnalogKeyState({ KeyName = FName("Gamepad_LeftTriggerAxis") }) end)
			isDown = isDown or (trigVal > 0.15) or (trigValAxis > 0.15)
		elseif b.key == "Gamepad_RightTrigger" then
			local trigVal = 0
			pcall(function() trigVal = pc:GetInputAnalogKeyState({ KeyName = b.fname }) end)
			local trigValAxis = 0
			pcall(function() trigValAxis = pc:GetInputAnalogKeyState({ KeyName = FName("Gamepad_RightTriggerAxis") }) end)
			isDown = isDown or (trigVal > 0.15) or (trigValAxis > 0.15)
		end

		-- Composite mapping for WASD: highlight if Keyboard key is down,
		-- D-Pad direction is pressed, OR Joystick is tilted beyond deadzone (0.35)
		if b.key == "W" then
			local dpadUp = false
			pcall(function() dpadUp = pc:IsInputKeyDown({ KeyName = M.fnameDPadUp }) end)
			isDown = isDown or dpadUp or (leftY > 0.35)
		elseif b.key == "A" then
			local dpadLeft = false
			pcall(function() dpadLeft = pc:IsInputKeyDown({ KeyName = M.fnameDPadLeft }) end)
			isDown = isDown or dpadLeft or (leftX < -0.35)
		elseif b.key == "S" then
			local dpadDown = false
			pcall(function() dpadDown = pc:IsInputKeyDown({ KeyName = M.fnameDPadDown }) end)
			isDown = isDown or dpadDown or (leftY < -0.35)
		elseif b.key == "D" then
			local dpadRight = false
			pcall(function() dpadRight = pc:IsInputKeyDown({ KeyName = M.fnameDPadRight }) end)
			isDown = isDown or dpadRight or (leftX > 0.35)
		end

		if isDown then
			b.border:SetBrushColor(b.activeColor)
			if b.text then b.text:SetColorAndOpacity(b.activeTextColor) end
		else
			b.border:SetBrushColor(b.inactiveColor)
			if b.text then b.text:SetColorAndOpacity(b.inactiveTextColor) end
		end
	end

	-- 3. Throttled diagnostic logging of keys to help debug controller mapping discrepancies
	if not M.lastDiagTime then M.lastDiagTime = 0 end
	if now - M.lastDiagTime > 1.0 then
		M.lastDiagTime = now
		local pressedKeys = {}
		local candidates = {
			"W", "A", "S", "D", "SpaceBar", "LeftMouseButton", "RightMouseButton",
			"Gamepad_FaceButton_Bottom", "Gamepad_FaceButton_Left", "Gamepad_FaceButton_Top", "Gamepad_FaceButton_Right",
			"Gamepad_LeftShoulder", "Gamepad_RightShoulder", "Gamepad_LeftTrigger", "Gamepad_RightTrigger",
			"Gamepad_DPad_Up", "Gamepad_DPad_Down", "Gamepad_DPad_Left", "Gamepad_DPad_Right"
		}
		for _, name in ipairs(candidates) do
			local down = false
			pcall(function() down = pc:IsInputKeyDown({ KeyName = FName(name) }) end)
			if down then
				table.insert(pressedKeys, name)
			end
		end

		if #pressedKeys > 0 or leftX ~= 0 or leftY ~= 0 or stickX ~= 0 or stickY ~= 0 then
			print(string.format("[Marquee Input Diag] Down Keys: [%s] | LeftX: %.3f, LeftY: %.3f | StickX: %.3f, StickY: %.3f\n",
				table.concat(pressedKeys, ", "), leftX, leftY, stickX, stickY))
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
	M.fnameLeftX = nil
	M.fnameLeftY = nil
	M.fnameDPadUp = nil
	M.fnameDPadDown = nil
	M.fnameDPadLeft = nil
	M.fnameDPadRight = nil
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
