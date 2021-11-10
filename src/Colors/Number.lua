--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Utils = root.Utils
local round = require(Utils.Round)

---

local Number = {}

Number.fromRGB = function(r: number, g: number, b: number): number
    r, g, b = round(r * 255), round(g * 255), round(b * 255)

    return (r * (256^2)) + (g * 256) + b
end

Number.toRGB = t.wrap(function(color: number): (number, number, number)
    local r: number, g: number, b: number = bit32.rshift(color, 16), bit32.band(bit32.rshift(color, 8), 255), bit32.band(color, 255)

    return
        r / 255,
        g / 255,
        b / 255
end, t.intersection(t.integer, t.numberConstrained(0, 256^3 - 1)))

return Number