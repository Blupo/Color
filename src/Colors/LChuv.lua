--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local Luv = require(Colors.Luv)
local XYZ = require(Colors.XYZ)

---

--[[
    Equations
        L*u*v* -> L*C*h(uv): http://www.brucelindbloom.com/Eqn_Luv_to_LCH.html
        L*C*h(uv) -> L*u*v*: http://www.brucelindbloom.com/Eqn_LCH_to_Luv.html
]]

local LChuv = {}

LChuv.fromLuv = function(l: number, u: number, v: number): (number, number, number)
    u, v = u * 100, v * 100

    local c: number = math.sqrt(u^2 + v^2)
    local h: number = math.atan2(v, u)
    h = (h < 0) and (h + (2 * math.pi)) or h

    return l, c / 100, math.deg(h)
end

LChuv.toLuv = function(l: number, c: number, h: number): (number, number, number)
    h = math.rad(h % 360)

    local u: number = c * math.cos(h)
    local v: number = c * math.sin(h)

    return l, u, v
end

LChuv.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    return LChuv.fromLuv(Luv.fromXYZ(XYZ.fromRGB(r, g, b)))
end

LChuv.toRGB = t.wrap(function(l: number, c: number, h: number): (number, number, number)
    return XYZ.toRGB(Luv.toXYZ(LChuv.toLuv(l, c, h)))
end, t.tuple(t.number, t.number, t.number))

return LChuv