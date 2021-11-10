--!strict

local root = script.Parent.Parent

local Utils = root.Utils
local GammaCorrection = require(Utils.GammaCorrection)
local lerp = require(Utils.Lerp)

---

return function(rgb1: {number}, rgb2: {number}, t: number, _: string?): (number, number, number)
    local linearRGB1: {number} = {}
    local linearRGB2: {number} = {}

    for i = 1, 3 do
        linearRGB1[i] = GammaCorrection.toLinear(rgb1[i])
        linearRGB2[i] = GammaCorrection.toLinear(rgb2[i])
    end

    return
        GammaCorrection.toStandard(lerp(linearRGB1[1], linearRGB2[1], t)),
        GammaCorrection.toStandard(lerp(linearRGB1[2], linearRGB2[2], t)),
        GammaCorrection.toStandard(lerp(linearRGB1[3], linearRGB2[3], t))
end