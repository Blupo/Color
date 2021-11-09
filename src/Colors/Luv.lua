--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local XYZ = require(Colors.XYZ)

---

--[[
    Equations
        XYZ -> L*u*v*: http://www.brucelindbloom.com/Eqn_XYZ_to_Luv.html
        L*u*v* -> XYZ: http://www.brucelindbloom.com/Eqn_Luv_to_XYZ.html
]]

local constants = XYZ.Constants
local Xr, Yr, Zr = constants.Xr, constants.Yr, constants.Zr
local k, e = constants.k, constants.e

local ur = (4 * Xr) / (Xr + (15 * Yr) + (3 * Zr))
local vr = (9 * Yr) / (Xr + (15 * Yr) + (3 * Zr))

---

local Luv = {}

Luv.fromXYZ = function(x: number, y: number, z: number): (number, number, number)
    if ((x == 0) and (y == 0) and (z == 0)) then
        return 0, 0, 0
    else
        x, y, z = x * 100, y * 100, z * 100

        local up = (4 * x) / (x + (15 * y) + (3 * z))
        local vp = (9 * y) / (x + (15 * y) + (3 * z))

        local yr = y / Yr

        local l = (yr > e) and ((116 * yr^(1/3)) - 16) or (k * yr)
        local u = 13 * l * (up - ur)
        local v = 13 * l * (vp - vr)

        return
            l / 100,
            u / 100,
            v / 100
    end
end

Luv.toXYZ = function(l: number, u: number, v: number): (number, number, number)
    if (l == 0) then
        return 0, 0, 0
    end

    l, u, v = l * 100, u * 100, v * 100

    local x, z
    local y = (l > (k * e)) and ((l + 16) / 116)^3 or (l / k)
    
    local a = (((52 * l) / (u + (13 * l * ur))) - 1) / 3
    local b = -5 * y
    local d = y * ((39 * l) / (v + (13 * l * vr)) - 5)

    x = (d - b) / (a + (1/3))
    z = (x * a) + b

    return x, y, z
end

Luv.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    return Luv.fromXYZ(XYZ.fromRGB(r, g, b))
end

Luv.toRGB = t.wrap(function(l: number, u: number, v: number): (number, number, number)
    return XYZ.toRGB(Luv.toXYZ(l, u, v))
end, t.tuple(t.number, t.number, t.number))

return Luv