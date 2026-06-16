--[[ lrc.lua — minimal LRC (synced lyrics) parser. Pure Lua, no engine/UE deps.

  Parses standard LRC:
    [ar:Artist] [ti:Title] [offset:-200]      -> metadata tags
    [00:12.34] line of lyrics                  -> timed line (centiseconds optional)
    [00:12.34][00:48.10] repeated line         -> multiple stamps share one line
    [00:12.34] <00:12.5>word <00:13.0>level    -> enhanced/word stamps are stripped to line level

  Returns: { lines = { {t=<seconds>, text=<string>}, ... sorted by t }, tags = {ar=,ti=,offset=,...} }
--]]
local M = {}

local function toSeconds(mm, ss, frac)
  local m, s = tonumber(mm), tonumber(ss)
  if not m or not s then return nil end
  local f = (frac and frac ~= "") and (tonumber("0." .. frac) or 0) or 0
  return m * 60 + s + f
end

function M.parse(text)
  local lines, tags = {}, {}
  if type(text) ~= "string" then return { lines = lines, tags = tags } end

  for raw in (text .. "\n"):gmatch("(.-)\r?\n") do
    -- whole-line metadata tag, e.g. [ar:Foo] / [offset:-150]
    local tagKey, tagVal = raw:match("^%s*%[(%a+):([^%]]*)%]%s*$")
    if tagKey then
      tags[tagKey:lower()] = tagVal
    else
      -- strip & collect every [mm:ss(.ff)] stamp prefixing the line
      local stamps, rest = {}, raw
      while true do
        local mm, ss, frac, after = rest:match("^%s*%[(%d+):(%d+)%.?(%d*)%](.*)$")
        if not mm then break end
        local t = toSeconds(mm, ss, frac)
        if t then stamps[#stamps + 1] = t end
        rest = after
      end
      if #stamps > 0 then
        local content = rest:gsub("<%d+:%d+%.?%d*>", "")      -- drop enhanced word stamps
        content = content:gsub("^%s+", ""):gsub("%s+$", "")
        for _, t in ipairs(stamps) do
          lines[#lines + 1] = { t = t, text = content }
        end
      end
    end
  end

  -- [offset:ms] — positive shifts lyrics earlier (subtract from times)
  local offMs = tonumber(tags.offset or "0") or 0
  if offMs ~= 0 then
    local off = offMs / 1000.0
    for _, ln in ipairs(lines) do ln.t = ln.t - off end
  end

  table.sort(lines, function(a, b) return a.t < b.t end)
  return { lines = lines, tags = tags }
end

return M
