--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local GammaCorrection = require(Utils.GammaCorrection)
local lerp = require(Utils.Lerp)

---

return function(rgb1: {number}, rgb2: {number}, t: number, _: string?): (number, number, number)
    for i = 1, #rgb1 do
        rgb1[i] = GammaCorrection.toLinear(rgb1[i])
    end

    for i = 1, #rgb2 do
        rgb2[i] = GammaCorrection.toLinear(rgb2[i])
    end

    return
        GammaCorrection.toStandard(lerp(rgb1[1], rgb2[1], t)),
        GammaCorrection.toStandard(lerp(rgb1[2], rgb2[2], t)),
        GammaCorrection.toStandard(lerp(rgb1[3], rgb2[3], t))
end