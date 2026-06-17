--[[ results_hud.lua — the Performance Report.
  Score-centric, sourced from the game's own signals (no accuracy, no rank letters):
  big Score, Max Combo, Sync (avg/peak), best perfect-streak, per-move score breakdown,
  Stars earned, and the leveling row. --]]
local M = {}
local umg_factory = require("utils.umg_factory")
local hud_utils = require("utils.hud_utils")
local log = require("utils.log")
local cfg = require("config")
local leveling = nil
do local ok, m = pcall(require, "leveling.leveling"); if ok then leveling = m end end

M.resultsWidget = nil



-- best-effort prettify of a raw CombatActionScores key (exact format confirmed in-game;
-- this strips enum scopes / GA_ wrappers and spaces camelCase so labels read cleanly).
local function prettyMove(raw)
	local s = tostring(raw or "")
	s = s:gsub("^.*::", "")            -- drop "ESomeEnum::" scope
	s = s:gsub("^.*%.", "")            -- dotted gameplay tag -> last segment
	s = s:gsub("^GA_", ""):gsub("_C$", "")
	s = s:gsub("(%l)(%u)", "%1 %2")    -- camelCase -> spaced
	s = s:gsub(" Attack$", ""):gsub("%s+$", "")
	if s == "" then s = tostring(raw) end
	return s
end



--[[ ============ RENDERERS ============ --]]
local function renderHeader(container, songName)
	umg_factory.CreateTextBlock(container, "ResultsTitle", {
		size = 30, text = "PERFORMANCE REPORT",
		color = hud_utils.FSlateColor(1, 1, 1, 1),
		fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
	})
	-- the game returns "No Song" for challenges / some modes — skip the ugly placeholder
	-- rather than printing it (the real title lives in challenge data, not the song object)
	if songName and songName ~= "" and songName ~= "No Song" then
		umg_factory.CreateTextBlock(container, "SongName", {
			size = 18, text = songName,
			color = hud_utils.FSlateColor(1, 1, 1, 0.8),
			fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
		})
	end
	umg_factory.CreateTextBlock(container, "Spacer_Header", { size = 15, text = " " })
end

local function renderLeftColumn(container, s)
	local box = umg_factory.CreateVerticalBox(container, "LeftVBox")

	umg_factory.CreateTextBlock(box, "ComboLine", {
		size = 16, text = string.format("Max Combo: %d", s.MaxCombo or 0),
		color = hud_utils.FSlateColor(1, 1, 1, 1),
	})

	local avg, peak = s.FinalAvgSync, s.FinalPeakSync
	umg_factory.CreateTextBlock(box, "SyncLine", {
		size = 14,
		text = string.format("Sync: %s avg  /  %s peak",
			avg and string.format("%d%%", math.floor(avg * 100 + 0.5)) or "—",
			peak and string.format("%d%%", math.floor(peak * 100 + 0.5)) or "—"),
		color = hud_utils.SyncColor(avg or 0),
	})

	if (s.SyncStreakMax or 0) > 0 then
		umg_factory.CreateTextBlock(box, "StreakLine", {
			size = 12, text = string.format("Best perfect streak: %d", s.SyncStreakMax),
			color = hud_utils.FSlateColor(0.69, 0.15, 1, 0.9),
		})
	end

	if (s.StarsEarned or 0) > 0 then
		umg_factory.CreateTextBlock(box, "StarsLine", {
			size = 14, text = string.format("Stars earned: %d", s.StarsEarned),
			color = hud_utils.FSlateColor(1, 0.85, 0.2, 1),
		})
	end

	umg_factory.CreateTextBlock(box, "Spacer_L", { size = 8, text = " " })
	umg_factory.CreateTextBlock(box, "BreakdownTitle", {
		size = 10, text = "SCORE SHARE:", color = hud_utils.FSlateColor(0, 1, 1, 0.5),
	})

	local moves = s.MoveScores or {}
	if #moves == 0 then
		umg_factory.CreateTextBlock(box, "NoMoves", {
			size = 10, text = "  (no move data this run)", color = hud_utils.FSlateColor(1, 1, 1, 0.4),
		})
	else
		-- each move as a SHARE of your scoring (% of the move-score total) — relative
		-- contribution reads cleaner than gorillion-digit raw points, and it's an exact
		-- ratio (no multiplier guesswork like deriving counts would need).
		local denom = 0
		for _, m in ipairs(moves) do denom = denom + (tonumber(m.score) or 0) end
		for i = 1, math.min(#moves, 8) do
			local mv = moves[i]
			local nm = mv.move
			local label = (type(nm) == "string" and nm ~= "" and not nm:find("Struct"))
				and prettyMove(nm) or ("Move " .. i)
			local pct = (denom > 0) and (mv.score / denom * 100) or 0
			local hBox = umg_factory.CreateHorizontalBox(box, "MoveHBox_" .. i)
			umg_factory.CreateTextBlock(hBox, "MoveName_" .. i, {
				size = 11, text = string.format("%s: ", label),
			})
			umg_factory.CreateTextBlock(hBox, "MoveScore_" .. i, {
				size = 11, color = hud_utils.FSlateColor(1, 1, 1, 0.7),
				text = string.format("%d%%  (%s)", math.floor(pct + 0.5), hud_utils.Abbrev(mv.score)),
			})
		end
	end
end

-- Right column = our UNIQUE value (the game already shows Score + Stars + Fans up top, so
-- a score here is redundant): the Marquee level/XP, the peak multiplier, and the personal-best flag.
local function renderRightColumn(container, s)
	local box = umg_factory.CreateVerticalBox(container, "RightVBox")

	local lv = s.Leveling
	if lv and leveling then
		if lv.leveledUp then
			umg_factory.CreateTextBlock(box, "LevelUpFlash", {
				size = 18, text = "LEVEL UP!",
				color = hud_utils.FSlateColor(1, 0.92, 0.3, 1),
				fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
				shadowOffset = { X = 2, Y = 2 }, shadowColor = hud_utils.FLinearColor(0, 0, 0, 1),
			})
		else
			umg_factory.CreateTextBlock(box, "LevelLabel", {
				size = 16, text = "LEVEL", color = hud_utils.FSlateColor(1, 1, 1, 0.5),
				fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
			})
		end
		local rgb = leveling.LevelColor(lv.level)
		umg_factory.CreateTextBlock(box, "LevelBig", {
			size = 52, text = string.format("Lv%d", lv.level),
			color = hud_utils.FSlateColor(rgb[1], rgb[2], rgb[3], 1),
			fontPath = "/Game/Pagoda/UI/Fonts/Visual_Font.Visual_Font",
			skewAmount = 0.1, shadowOffset = { X = 3, Y = 3 }, shadowColor = hud_utils.FLinearColor(0, 0, 0, 1),
		})
		umg_factory.CreateTextBlock(box, "LevelTitle", {
			size = 16, text = tostring(lv.title or ""),
			color = hud_utils.FSlateColor(rgb[1], rgb[2], rgb[3], 0.95),
			fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
		})
		umg_factory.CreateTextBlock(box, "LevelXP", {
			size = 12, text = string.format("%s XP   (+%s)",
				hud_utils.Abbrev(lv.totalXp), hud_utils.Abbrev(lv.xpGained)),
			color = hud_utils.FSlateColor(1, 1, 1, 0.8),
		})
		if lv.xpToNext and lv.nextTitle then
			umg_factory.CreateTextBlock(box, "LevelNext", {
				size = 11, text = string.format("Next: %s in %s XP", lv.nextTitle, hud_utils.Abbrev(lv.xpToNext)),
				color = hud_utils.FSlateColor(0, 1, 1, 0.55),
			})
		else
			umg_factory.CreateTextBlock(box, "LevelNext", {
				size = 11, text = "MAX LEVEL — keep dancing",
				color = hud_utils.FSlateColor(0.69, 0.15, 1, 0.9),
			})
		end
	end

	umg_factory.CreateTextBlock(box, "RightSpacer", { size = 8, text = " " })
	if (s.Multiplier or 0) > 1 then
		umg_factory.CreateTextBlock(box, "MultLine", {
			size = 12, text = string.format("peak multiplier  x%.2f", s.Multiplier),
			color = hud_utils.FSlateColor(1, 1, 1, 0.6),
		})
	end

	local pbScore = (s.CachedPB and s.CachedPB.highScore) or 0
	if (s.TotalScore or 0) > pbScore then
		local pbHBox = umg_factory.CreateHorizontalBox(box, "PBBadgeHBox")
		local pbText = umg_factory.CreateTextBlock(pbHBox, "NewPBText", {
			size = 13, text = " NEW HIGH SCORE! ",
			color = hud_utils.FSlateColor(1, 1, 1, 1), skew = 0.1,
			shadowOffset = { X = 1, Y = 1 }, shadowColor = hud_utils.FLinearColor(0, 0, 0, 1),
		})
		umg_factory.CreateBorder(pbHBox, "NewPBBorder", {
			content = pbText, brushColor = hud_utils.FLinearColor(0.69, 0.15, 1, 0.8),
			padding = { Left = 8, Top = 2, Right = 8, Bottom = 2 },
		})
	end
end



--[[ ============ CORE ============ --]]
function M.Show(summary)
	summary = summary or {}
	if M.resultsWidget and M.resultsWidget:IsValid() then
		pcall(function() M.resultsWidget:RemoveFromParent() end)
	end

	local hud = umg_factory.CreateHUD("ResultsHUD")
	if not hud then return end

	local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "ResultsCanvas")
	local mainVBox = umg_factory.CreateVerticalBox(canvas, "ResultsMainVBox")

	renderHeader(mainVBox, summary.SongName)

	local columnsHBox = umg_factory.CreateHorizontalBox(mainVBox, "ColumnsHBox")
	renderLeftColumn(columnsHBox, summary)
	umg_factory.CreateTextBlock(columnsHBox, "ColumnSpacer", { size = 40, text = "      " })
	renderRightColumn(columnsHBox, summary)

	local border = umg_factory.CreateBorder(canvas, "ResultsBorder", {
		content = mainVBox,
		brushColor = hud_utils.FLinearColor(0, 0, 0, 0.5),
		padding = { Left = 40, Top = 20, Right = 40, Bottom = 20 },
	})
	umg_factory.ApplyAlignment(canvas, border, cfg.RESULTS_ALIGNMENT or "center",
		{ X = cfg.RESULTS_POS_X or 0, Y = cfg.RESULTS_POS_Y or 40 })

	hud.Visibility = hud_utils.Visibility.HITTESTINVISIBLE
	hud:AddToViewport(1000)
	M.resultsWidget = hud
end

function M.Hide()
	-- tear the report down rather than just hiding it (one less live widget for 5.7)
	if M.resultsWidget then
		pcall(function()
			if M.resultsWidget:IsValid() then M.resultsWidget:RemoveFromParent() end
		end)
	end
	M.resultsWidget = nil
end

return M
