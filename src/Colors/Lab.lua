--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local XYZ = require(Colors.XYZ)

---

--[[
    Equations
        XYZ -> L*a*b*: http://www.brucelindbloom.com/Eqn_XYZ_to_Lab.html
        L*a*b* -> XYZ: http://www.brucelindbloom.com/Eqn_Lab_to_XYZ.html
]]

local XYZ_CONSTANTS: {[string]: number} = XYZ.Constants
local Xr: number = XYZ_CONSTANTS.Xr
local Yr: number = XYZ_CONSTANTS.Yr
local Zr: number = XYZ_CONSTANTS.Zr
local k: number = XYZ_CONSTANTS.k
local e: number = XYZ_CONSTANTS.e

local transform = function(n: number): number
    return (n > e) and n^(1/3) or (((k * n) + 16) / 116)
end

---

local Lab = {}

Lab.fromXYZ = function(x: number, y: number, z: number): (number, number, number)
    x, y, z = x * 100, y * 100, z * 100

    local l: number = (116 * transform(y / Yr)) - 16
    local a: number = 500 * (transform(x / Xr) - transform(y / Yr))
    local b: number = 200 * (transform(y / Yr) - transform(z / Zr))

    return
        l / 100,
        a / 100,
        b / 100
end

Lab.toXYZ = function(l: number, a: number, b: number): (number, number, number)
    l, a, b = l * 100, a * 100, b * 100

    local fy: number = (l + 16) / 116
    local fx: number = (a / 500) + fy
    local fz: number = fy - (b / 200)

    local xr: number = ((fx^3) > e) and fx^3 or (((116 * fx) - 16) / k)
    local yr: number = (l > (k * e)) and fy^3 or (l / k)
    local zr: number = ((fz^3) > e) and fz^3 or (((116 * fz) - 16) / k)

    local x: number = xr * Xr
    local y: number = yr * Yr
    local z: number = zr * Zr

    return
        x / 100,
        y / 100,
        z / 100
end

Lab.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    return Lab.fromXYZ(XYZ.fromRGB(r, g, b))
end

Lab.toRGB = t.wrap(function(l: number, a: number, b: number): (number, number, number)
    return XYZ.toRGB(Lab.toXYZ(l, a, b))
end, t.tuple(t.number, t.number, t.number))

return Lab