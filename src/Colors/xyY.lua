--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local XYZ = require(Colors.XYZ)

---

local xw = 0.31271
local yw = 0.32902

---

--[[
    Equations
        XYZ -> xyY: http://www.brucelindbloom.com/Eqn_XYZ_to_xyY.html
        xyY -> XYZ: http://www.brucelindbloom.com/Eqn_xyY_to_XYZ.html
]]

local xyY = {}

xyY.fromXYZ = function(X: number, Y: number, Z: number): (number, number, number)
    if ((X == 0) and (Y == 0) and (Z == 0)) then
        return xw, yw, Y
    end

    return
        X / (X + Y + Z),
        Y / (X + Y + Z),
        Y
end

xyY.toXYZ = function(x: number, y: number, Y: number): (number, number, number)
    if (y == 0) then
        return 0, 0, 0
    end

    local X = (x * Y) / y
    local Z = (Y * (1 - x - y)) / y

    return X, Y, Z
end

xyY.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    return xyY.fromXYZ(XYZ.fromRGB(r, g, b))
end

xyY.toRGB = t.wrap(function(x: number, y: number, Y: number): (number, number, number)
    return XYZ.toRGB(xyY.toXYZ(x, y, Y))
end, t.tuple(t.number, t.number, t.number))

return xyY