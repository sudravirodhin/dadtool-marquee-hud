local M = {}

local UEHelpers = require("UEHelpers")

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
	-- bottomleft = { anchor = { 0, 1 }, align = { 0, 1 }, pos = { 10, -10 } },
	bottomleft = { anchor = { 0, 0.9 }, align = { 0, 0.9 }, pos = { 9 , -8 } },
	-- bottomright = { anchor = { 1, 1 }, align = { 1, 1 }, pos = { -10, -10 } },
	bottomright = { anchor = { 1, 0.85 }, align = { 1, 0.85 }, pos = { -9, -8 } },

	-- only for testing
	upper_left = { anchor = { 0, 0.25 }, align = { 0, 0.25 }, pos = { 10, 7.5 } },
	topmidleft_test = { anchor = { 0.25, 0 }, align = { 0.25, 0 }, pos = { 7, 10 } },
	midbottomleft_test = { anchor = { 0, 0.9 }, align = { 0, 0.9 }, pos = { 9 , -8 } },
	midbottomright_test = { anchor = { 1, 0.85 }, align = { 1, 0.85 }, pos = { -9, -8 } },
}

M.KTextLib = UEHelpers.GetKismetTextLibrary()

function M.FLinearColor(R, G, B, A)
	return { R = R, G = G, B = B, A = A }
end
function M.FSlateColor(R, G, B, A)
	return { SpecifiedColor = M.FLinearColor(R, G, B, A), ColorUseRule = 0 }
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

return M
