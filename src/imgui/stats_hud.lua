--[[ stats_hud.lua — the Career Stats panel (toggled with F6 from the hub).
  Pure read + aggregate of data Marquee already logs: performance_history.json
  (per-song highScore + playCount) and the leveling profile. No new tracking. --]]
local M = {}

local umg_factory = require("utils.umg_factory")
local hud_utils = require("utils.hud_utils")
local history_handler = require("handlers.history_handler")
local leveling = nil
do local ok, m = pcall(require, "leveling.leveling"); if ok then leveling = m end end

M.widget = nil

-- keep long "Artist - Title" names from blowing out the panel width
local function clip(s, n)
  s = tostring(s or "")
  if #s > n then return s:sub(1, n - 1) .. "…" end
  return s
end

local function isRealSong(name)
  return name and name ~= "" and name ~= "No Song" and name ~= "Unknown"
end

-- Roll up the history into totals, most-played, and top scores.
local function aggregate()
  local out = { totalPlays = 0, uniqueTracks = 0, favorites = {}, topScores = {} }
  local hist = {}
  pcall(function() hist = history_handler.LoadHistory() or {} end)

  local list = {}
  for pk, pb in pairs(hist) do
    if type(pb) == "table" then
      local name = pb.songName or pk
      if isRealSong(name) then
        local e = { name = name, score = tonumber(pb.highScore) or 0, plays = tonumber(pb.playCount) or 0 }
        out.totalPlays = out.totalPlays + e.plays
        out.uniqueTracks = out.uniqueTracks + 1
        list[#list + 1] = e
      end
    end
  end

  -- separate copies so the two sorts don't fight over one list
  local fav, top = {}, {}
  for _, e in ipairs(list) do fav[#fav + 1] = e end
  for _, e in ipairs(list) do top[#top + 1] = e end
  table.sort(fav, function(a, b) return a.plays > b.plays end)
  table.sort(top, function(a, b) return a.score > b.score end)
  for i = 1, math.min(#fav, 5) do out.favorites[i] = fav[i] end
  for i = 1, math.min(#top, 5) do out.topScores[i] = top[i] end
  return out
end

local function section(box, title)
  umg_factory.CreateTextBlock(box, "Sp_" .. title, { size = 8, text = " " })
  umg_factory.CreateTextBlock(box, "T_" .. title, {
    size = 11, text = title, color = hud_utils.FSlateColor(0, 1, 1, 0.55),
  })
end

function M.Show()
  if M.widget and M.widget:IsValid() then pcall(function() M.widget:RemoveFromParent() end) end

  local hud = umg_factory.CreateHUD("CareerStatsHUD")
  if not hud then return end
  local canvas = umg_factory.CreateCanvas(hud.WidgetTree, "StatsCanvas")
  local border = umg_factory.CreateBorder(canvas, "StatsBorder", {
    brushColor = hud_utils.FLinearColor(0, 0, 0, 0.6),
    padding = { Left = 64, Top = 26, Right = 64, Bottom = 26 },
  })
  local vBox = umg_factory.CreateVerticalBox(border, "StatsVBox")

  local s = aggregate()

  umg_factory.CreateTextBlock(vBox, "Title", {
    size = 28, text = "CAREER STATS", color = hud_utils.FSlateColor(1, 1, 1, 1),
    fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
  })

  -- level row (from the leveling profile)
  if leveling then
    local p = nil
    pcall(function() p = leveling.Get() end)
    if p then
      local rgb = leveling.LevelColor(p.level)
      umg_factory.CreateTextBlock(vBox, "Level", {
        size = 18, text = string.format("Lv%d  %s", p.level, leveling.Title(p.level)),
        color = hud_utils.FSlateColor(rgb[1], rgb[2], rgb[3], 1),
        fontPath = "/Game/Pagoda/UI/Fonts/Primary_Font.Primary_Font",
      })
      umg_factory.CreateTextBlock(vBox, "XP", {
        size = 12, text = string.format("%s XP", hud_utils.Abbrev(p.xp)),
        color = hud_utils.FSlateColor(1, 1, 1, 0.7),
      })
    end
  end

  umg_factory.CreateTextBlock(vBox, "Totals", {
    size = 13, text = string.format("%d tracks  ·  %d total plays", s.uniqueTracks, s.totalPlays),
    color = hud_utils.FSlateColor(1, 1, 1, 0.8),
  })

  section(vBox, "MOST PLAYED")
  if #s.favorites == 0 then
    umg_factory.CreateTextBlock(vBox, "FavNone", { size = 10, text = "  (no plays logged yet)", color = hud_utils.FSlateColor(1, 1, 1, 0.4) })
  else
    for i, e in ipairs(s.favorites) do
      local hBox = umg_factory.CreateHorizontalBox(vBox, "FavH" .. i)
      umg_factory.CreateTextBlock(hBox, "FavN" .. i, { size = 12, text = clip(e.name, 46) .. "  ", color = hud_utils.FSlateColor(1, 1, 1, 0.85) })
      umg_factory.CreateTextBlock(hBox, "FavP" .. i, { size = 12, text = string.format("×%d", e.plays), color = hud_utils.FSlateColor(1, 0.82, 0.15, 0.9) })
    end
  end

  section(vBox, "TOP SCORES")
  if #s.topScores == 0 then
    umg_factory.CreateTextBlock(vBox, "TopNone", { size = 10, text = "  (no scores logged yet)", color = hud_utils.FSlateColor(1, 1, 1, 0.4) })
  else
    for i, e in ipairs(s.topScores) do
      local hBox = umg_factory.CreateHorizontalBox(vBox, "TopH" .. i)
      umg_factory.CreateTextBlock(hBox, "TopN" .. i, { size = 12, text = clip(e.name, 42) .. "  ", color = hud_utils.FSlateColor(1, 1, 1, 0.85) })
      umg_factory.CreateTextBlock(hBox, "TopS" .. i, { size = 12, text = hud_utils.Abbrev(e.score), color = hud_utils.FSlateColor(0.4, 1, 0.6, 0.95) })
    end
  end

  umg_factory.CreateTextBlock(vBox, "Sp_close", { size = 12, text = " " })
  umg_factory.CreateTextBlock(vBox, "Close", { size = 9, text = "press F6 to close", color = hud_utils.FSlateColor(1, 1, 1, 0.4) })
  umg_factory.ApplyAlignment(canvas, border, "center", { X = 0, Y = 0 })

  hud.Visibility = hud_utils.Visibility.HITTESTINVISIBLE
  hud:AddToViewport(1001)
  M.widget = hud
end

function M.Hide()
  if M.widget then
    pcall(function() if M.widget:IsValid() then M.widget:RemoveFromParent() end end)
  end
  M.widget = nil
end

function M.IsShowing()
  if not M.widget then return false end
  local ok, valid = pcall(function() return M.widget:IsValid() end)
  return ok and valid == true
end

function M.Toggle()
  if M.IsShowing() then M.Hide() else M.Show() end
end

return M
