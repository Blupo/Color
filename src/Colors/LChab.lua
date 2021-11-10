--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local Lab = require(Colors.Lab)
local XYZ = require(Colors.XYZ)

---

--[[
    Equations
        L*a*b* -> L*C*h(ab): http://www.brucelindbloom.com/Eqn_Lab_to_LCH.html
        L*C*h(ab) -> L*a*b*: http://www.brucelindbloom.com/Eqn_LCH_to_Lab.html
]]

local LChab = {}

LChab.fromLab = function(l: number, a: number, b: number): (number, number, number)
    a, b = a * 100, b * 100

    local c: number = math.sqrt(a^2 + b^2)
    local h: number = math.atan2(b, a)
    h = (h < 0) and (h + (2 * math.pi)) or h

    return l, c / 100, math.deg(h)
end

LChab.toLab = function(l: number, c: number, h: number): (number, number, number)
    h = math.rad(h % 360)

    local a: number = c * math.cos(h)
    local b: number = c * math.sin(h)

    return l, a, b
end

LChab.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    return LChab.fromLab(Lab.fromXYZ(XYZ.fromRGB(r, g, b)))
end

LChab.toRGB = t.wrap(function(l: number, c: number, h: number): (number, number, number)
    return XYZ.toRGB(Lab.toXYZ(LChab.toLab(l, c, h)))
end, t.tuple(t.number, t.number, t.number))

return LChab