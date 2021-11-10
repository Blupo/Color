--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Utils = root.Utils
local GammaCorrection = require(Utils.GammaCorrection)

---

--[[
    D65 Tristimulus Values
        X = 95.04
        Y = 100
        Z = 108.88

    sRGB Chromaticity Coordinates
        r = (0.64, 0.33)
        g = (0.30, 0.60)
        b = (0.15, 0.06)

    Equations
        RGB <-> XYZ matrices: http://www.brucelindbloom.com/Eqn_RGB_XYZ_Matrix.html
        RGB -> XYZ: http://www.brucelindbloom.com/Eqn_RGB_to_XYZ.html
        XYZ -> RGB: http://www.brucelindbloom.com/Eqn_XYZ_to_RGB.html
]]

local sRGB_XYZ_MATRIX: {{number}} = {
    {962624/2334375, 3339089/9337500, 67391/373500},
    {165451/778125, 3339089/4668750, 67391/933750},
    {15041/778125, 3339089/28012500, 5323889/5602500}
}

local XYZ_sRGB_MATRIX: {{number}} = {
    {3750/1157, -23125/15041, -7500/15041},
    {-3236250/3339089, 6263750/3339089, 138750/3339089},
    {3750/67391, -13750/67391, 71250/67391}
}

local XYZ_CONSTANTS: {[string]: number} = {
    -- D65 tristimulus values
    Xr = 95.04,
    Yr = 100,
    Zr = 108.88,

    e = 216/24389,
    k = 24389/27,
}

---

local XYZ = {}
XYZ.Constants = XYZ_CONSTANTS

XYZ.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    r, g, b = GammaCorrection.toLinear(r), GammaCorrection.toLinear(g), GammaCorrection.toLinear(b)

    return
        (sRGB_XYZ_MATRIX[1][1] * r) + (sRGB_XYZ_MATRIX[1][2] * g) + (sRGB_XYZ_MATRIX[1][3] * b),
        (sRGB_XYZ_MATRIX[2][1] * r) + (sRGB_XYZ_MATRIX[2][2] * g) + (sRGB_XYZ_MATRIX[2][3] * b),
        (sRGB_XYZ_MATRIX[3][1] * r) + (sRGB_XYZ_MATRIX[3][2] * g) + (sRGB_XYZ_MATRIX[3][3] * b)
end

XYZ.toRGB = t.wrap(function(x: number, y: number, z: number): (number, number, number)
    local r: number = (XYZ_sRGB_MATRIX[1][1] * x) + (XYZ_sRGB_MATRIX[1][2] * y) + (XYZ_sRGB_MATRIX[1][3] * z)
    local g: number = (XYZ_sRGB_MATRIX[2][1] * x) + (XYZ_sRGB_MATRIX[2][2] * y) + (XYZ_sRGB_MATRIX[2][3] * z)
    local b: number = (XYZ_sRGB_MATRIX[3][1] * x) + (XYZ_sRGB_MATRIX[3][2] * y) + (XYZ_sRGB_MATRIX[3][3] * z)

    return
        GammaCorrection.toStandard(r),
        GammaCorrection.toStandard(g),
        GammaCorrection.toStandard(b)
end, t.tuple(t.number, t.number, t.number))

return XYZ