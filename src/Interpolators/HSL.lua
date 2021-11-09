--!strict

local root = script.Parent.Parent

local Interpolators = root.Interpolators
local hue = require(Interpolators.Hue)

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(hsl1: {number}, hsl2: {number}, t: number, hueAdjustment: string?): (number, number, number)
    return
        hue(hsl1[1], hsl2[1], t, hueAdjustment),
        lerp(hsl1[2], hsl2[2], t),
        lerp(hsl1[3], hsl2[3], t)
end