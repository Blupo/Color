--!strict

local root = script.Parent.Parent

local Interpolators = root.Interpolators
local hue = require(Interpolators.Hue)

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(hwb1: {number}, hwb2: {number}, t: number, hueAdjustment: string?): (number, number, number)
    return
        hue(hwb1[1], hwb2[1], t, hueAdjustment),
        lerp(hwb1[2], hwb2[2], t),
        lerp(hwb1[3], hwb2[3], t)
end