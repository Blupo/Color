--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local HSB = require(Colors.HSB)

---

-- Equations: https://en.wikipedia.org/wiki/HSL_and_HSV#Interconversion

local HSL = {}

HSL.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    local h: number, s: number, br: number = HSB.fromRGB(r, g, b)

    local l: number = br * (1 - (s / 2))
    local sL: number

    if ((l == 1) or (l == 0)) then
        sL = 0
    else
        sL = (br - l) / math.min(l, 1 - l)
    end

    return h, sL, l
end

HSL.toRGB = t.wrap(function(h: number, s: number, l: number): (number, number, number)
    local b: number = l + (s * math.min(l, 1 - l))
    local sV: number

    if (b == 0) then
        sV = 0
    else
        sV = 2 * (1 - (l / b))
    end

    return HSB.toRGB(h % 360, sV, b)
end, t.tuple(t.union(t.number, t.nan), t.number, t.number))

return HSL