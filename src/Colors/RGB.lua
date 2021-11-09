--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Utils = root.Utils
local round = require(Utils.Round)

---

local RGB = {}

RGB.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    return
        round(r * 255),
        round(g * 255),
        round(b * 255)
end

RGB.toRGB = t.wrap(function(r: number, g: number, b: number): (number, number, number)
    return
        r / 255,
        g / 255,
        b / 255
end, t.tuple(t.number, t.number, t.number))

return RGB