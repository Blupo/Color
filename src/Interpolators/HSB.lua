--!strict

local root = script.Parent.Parent

local Interpolators = root.Interpolators
local hue = require(Interpolators.Hue)

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(hsb1: {number}, hsb2: {number}, t: number, hueAdjustment: string?): (number, number, number)
    return
        hue(hsb1[1], hsb2[1], t, hueAdjustment),
        lerp(hsb1[2], hsb2[2], t),
        lerp(hsb1[3], hsb2[3], t)
end