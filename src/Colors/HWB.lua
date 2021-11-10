--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local HSB = require(Colors.HSB)

---

-- Equations: https://en.wikipedia.org/wiki/HWB_color_model

local HWB = {}

HWB.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    local h: number, s: number, br: number = HSB.fromRGB(r, g, b)

    return h, (1 - s) * br, (1 - br)
end

HWB.toRGB = t.wrap(function(h: number, w: number, b: number): (number, number, number)
    local sum: number = w + b

    if (sum > 1) then
        w, b = w / sum, b / sum
    end

    local br: number = 1 - b
    local s: number = (b ~= 1) and (1 - (w / br)) or 0

    return HSB.toRGB(h % 360, s, br)
end, t.tuple(t.union(t.number, t.nan), t.number, t.number))

return HWB