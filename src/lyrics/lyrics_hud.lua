--[[ lyrics_hud.lua — UMG karaoke view. Mirrors imgui/in_game_progress_hud.lua:
  Create() builds the widget once, Update(cur, next) sets the stored TextBlocks.
  A faint subtitle bar (Border) sits bottom-center; it hides during instrumental
  gaps (no current line). White text + outline/shadow for legibility over gameplay. --]]
local M = {}

local umg_factory = require("utils.umg_factory")
local hud_utils = require("utils.hud_utils")
local cfg = require("config")

M.widget = nil
M.curText = nil
M.nextText = nil
M._active = true
M._lastCur, M._lastNext = nil, nil
M._vis = nil   -- cached widget visibility — avoids widget:GetVisibility(), which throws on UE4SS v4.0.0

function M.Create()
  local hud = umg_factory.CreateHUD("LyricsHUD")
  if not hud then return end

  local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "LyricsCanvas")
  local border = umg_factory.CreateBorder(canvas, "LyricsBorder", {
    brushColor = hud_utils.FLinearColor(0, 0, 0, 0.28),
    padding = { Left = 18, Top = 6, Right = 18, Bottom = 6 },
  })
  local vBox = umg_factory.CreateVerticalBox(border, "LyricsVBox")

  local cur = umg_factory.CreateTextBlock(vBox, "Lyrics_Current", {
    size = cfg.LYRICS_FONT_SIZE or 20,
    text = "",
    color = hud_utils.FSlateColor(1, 1, 1, 1),
    shadowOffset = { X = 1.5, Y = 1.5 },
    shadowColor = hud_utils.FLinearColor(0, 0, 0, 1),
    outline = { size = 2, color = hud_utils.FLinearColor(0, 0, 0, 1) },
  })
  local nxt = umg_factory.CreateTextBlock(vBox, "Lyrics_Next", {
    size = cfg.LYRICS_NEXT_FONT_SIZE or 13,
    text = "",
    color = hud_utils.FSlateColor(1, 1, 1, 0.45),
    shadowOffset = { X = 1, Y = 1 },
    shadowColor = hud_utils.FLinearColor(0, 0, 0, 1),
    outline = { size = 1, color = hud_utils.FLinearColor(0, 0, 0, 1) },
  })
  -- center each line within the bar (ETextJustify::Center = 1)
  pcall(function() cur:SetJustification(1) end)
  pcall(function() nxt:SetJustification(1) end)

  M.curText, M.nextText = cur, nxt
  umg_factory.ApplyAlignment(canvas, border, cfg.LYRICS_ALIGNMENT or "bottom",
    { X = cfg.LYRICS_POS_X or 0, Y = cfg.LYRICS_POS_Y or -70 })

  hud.Visibility = hud_utils.Visibility.HIDDEN
  M._vis = hud_utils.Visibility.HIDDEN
  hud:AddToViewport(998)
  M.widget = hud
end

function M.SetVisibility(v)
  if not M.widget or not M.widget:IsValid() then return end
  -- Track visibility in Lua instead of calling widget:GetVisibility(). On UE4SS v4.0.0
  -- that getter throws, and being un-pcall'd it silently killed the whole lyrics Tick
  -- (the bar loaded its lines but never un-hid). Set via BOTH the method and the property
  -- — the property is what the other HUDs use and it renders correctly on v4.0.0.
  if M._vis == v then return end
  M._vis = v
  pcall(function() M.widget:SetVisibility(v) end)
  pcall(function() M.widget.Visibility = v end)
end

function M.Hide()
  M.SetVisibility(hud_utils.Visibility.HIDDEN)
end

-- Remove the karaoke bar from the viewport entirely (used between songs and when a
-- song has no lyrics) so nothing lingers/draws when there's nothing to show.
function M.Destroy()
  if M.widget then
    pcall(function()
      if M.widget:IsValid() then M.widget:RemoveFromParent() end
    end)
  end
  M.widget = nil
  M.curText = nil
  M.nextText = nil
  M._lastCur, M._lastNext = nil, nil
end

function M.SetActive(on)
  M._active = on and true or false
  if not M._active then M.Hide() end
end

function M.Update(currentText, nextText)
  if not M._active then return end
  if not M.widget or not M.widget:IsValid() then return end
  if not (M.curText and M.nextText) then return end

  local cur = currentText or ""
  -- nothing to show (intro / instrumental gap) -> just hide; no text churn
  if cur == "" then
    M.SetVisibility(hud_utils.Visibility.HIDDEN)
    return
  end

  local nxt = nextText or ""
  if cur ~= M._lastCur then
    pcall(function()
      if M.curText:IsValid() then   -- re-validate the instant before touching UMG
        M.curText:SetText(umg_factory.ToFText(cur))
        M.curText:SetVisibility(hud_utils.Visibility.VISIBLE)
      end
    end)
    M._lastCur = cur
  end
  if nxt ~= M._lastNext then
    pcall(function()
      if M.nextText:IsValid() then
        M.nextText:SetText(umg_factory.ToFText(nxt))
        -- collapse the preview row when empty so the bar doesn't grow a blank line
        M.nextText:SetVisibility((nxt ~= "") and hud_utils.Visibility.VISIBLE or hud_utils.Visibility.COLLAPSED)
      end
    end)
    M._lastNext = nxt
  end
  M.SetVisibility(hud_utils.Visibility.HITTESTINVISIBLE)
end

function M.SetOpacity(alpha)
  if not M.widget or not M.widget:IsValid() then return end
  pcall(function() M.widget:SetRenderOpacity(alpha) end)
end

-- Show a transient message on the bar (e.g. "lyrics not found"); the fade is driven
-- externally by the handler via SetOpacity().
function M.ShowNotice(text)
  if not M.widget or not M.widget:IsValid() then return end
  if not (M.curText and M.nextText) then return end
  M.SetOpacity(1)
  pcall(function() M.curText:SetText(umg_factory.ToFText(text or "")) end)
  pcall(function() M.curText:SetVisibility(hud_utils.Visibility.VISIBLE) end)
  pcall(function() M.nextText:SetText(umg_factory.ToFText("")) end)
  pcall(function() M.nextText:SetVisibility(hud_utils.Visibility.COLLAPSED) end)  -- single-line notice
  M._lastCur, M._lastNext = nil, nil
  M.SetVisibility(hud_utils.Visibility.HITTESTINVISIBLE)
end

function M.IsValid()
  local ok = M.widget and M.widget:IsValid()
  if ok then
    local okk, inView = pcall(function() return M.widget:IsInViewport() end)
    if okk and not inView then return false end
  end
  return ok
end

return M
