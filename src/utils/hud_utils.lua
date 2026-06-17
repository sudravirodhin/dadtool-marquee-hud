local M = {}

M.Visibility = {
	VISIBLE = 0,
	COLLAPSED = 1,
	HIDDEN = 2,
	HITTESTINVISIBLE = 3,
	SELFHITTESTINVISIBLE = 4,
	ALL = 5,
}

M.Alignments = {
	center = { anchor = { 0.5, 0.5 }, align = { 0.5, 0.5 }, pos = { 0, 0 } },
	top = { anchor = { 0.5, 0.0 }, align = { 0.5, 0.0 }, pos = { 0, 0 } },
	top_center_right = { anchor = { 0.5, 0.0 }, align = { 0.5, 0.0 }, pos = { 60, 20 } },
	bottom = { anchor = { 0.5, 1 }, align = { 0.5, 1 }, pos = { 0, -10 } },
	topleft = { anchor = { 0, 0 }, align = { 0, 0 }, pos = { 10, 10 } },
	topright = { anchor = { 1, 0 }, align = { 1, 0 }, pos = { -10, 10 } },
	-- bottomleft/bottomright offset from 1.0 to stay above the game's native bottom-edge UI
	bottomleft = { anchor = { 0, 0.9 }, align = { 0, 0.9 }, pos = { 9 , -8 } },
	bottomright = { anchor = { 1, 0.85 }, align = { 1, 0.85 }, pos = { -9, -8 } },
}

function M.FLinearColor(R, G, B, A)
	return { R = R, G = G, B = B, A = A }
end
function M.FSlateColor(R, G, B, A)
	return { SpecifiedColor = M.FLinearColor(R, G, B, A), ColorUseRule = 0 }
end

-- Pretty-print with commas: 1234567 -> "1,234,567"
function M.Commafy(n)
	n = math.floor(tonumber(n) or 0)
	local s = tostring(n):reverse():gsub("(%d%d%d)", "%1,"):reverse()
	return (s:gsub("^,", ""))
end

-- 5-tier sync color: electric-purple (nailing it) -> red (dropping)
function M.SyncColor(frac)
	frac = frac or 0
	if frac >= 0.95 then return M.FSlateColor(0.69, 0.15, 1, 1)
	elseif frac >= 0.85 then return M.FSlateColor(1, 1, 0, 1)
	elseif frac >= 0.6 then return M.FSlateColor(0, 1, 0.5, 1)
	elseif frac >= 0.3 then return M.FSlateColor(1, 0.6, 0, 1)
	else return M.FSlateColor(1, 0.4, 0.4, 1) end
end

-- Compact large-number formatting (idle/incremental-game style) so values never overflow
-- the panel as they grow: 588 -> "588", 17886 -> "17.9K", 4.8e6 -> "4.8M", then B/T/Qa…,
-- and scientific ("1.23e40") beyond the suffix table.
local NUM_SUFFIX = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "De" }
function M.Abbrev(n)
	n = tonumber(n) or 0
	local sign = (n < 0) and "-" or ""
	n = math.abs(n)
	if n < 1000 then return sign .. string.format("%d", math.floor(n + 0.5)) end
	local tier = math.floor(math.log(n) / math.log(1000))
	if tier >= 1 and tier < #NUM_SUFFIX then
		return sign .. string.format("%.1f%s", n / (1000 ^ tier), NUM_SUFFIX[tier + 1])
	end
	return sign .. string.format("%.2e", n)   -- absurdly large -> scientific
end

function M.is_indexable(obj)
	if not obj then return false end
	local t = type(obj)
	if t == "table" then return true end
	if t == "userdata" then
		local ok, res = pcall(function() return obj:IsValid() end)
		return ok and res == true
	end
	return false
end

-- Safely retrieves and unwraps the first element of a TArray without direct indexing,
-- preventing native out-of-bounds crashes in UE4SS.
function M.GetFirstTArrayElement(arr)
	if not arr or not M.is_indexable(arr) then return nil end
	local first = nil
	pcall(function()
		arr:ForEach(function(_, elem)
			if first == nil then
				first = elem
			end
		end)
	end)
	if first ~= nil then
		pcall(function()
			if M.is_indexable(first) and first.get then
				first = first:get()
			end
		end)
	end
	return first
end

return M
