--!strict

local root = script.Parent.Parent

local Interpolators = root.Interpolators
local hue = require(Interpolators.Hue)

local Utils = root.Utils
local lerp = require(Utils.Lerp)

---

return function(lch1: {number}, lch2: {number}, t: number, hueAdjustment: string?): (number, number, number)
    return
        lerp(lch1[1], lch2[1], t),
        lerp(lch1[2], lch2[2], t),
        hue(lch1[3], lch2[3], t, hueAdjustment)
end