--!strict

local root = script.Parent.Parent
local t = require(root.t)

---

local Color3_Global = Color3
local Color3 = {}

Color3.fromRGB = function(r: number, g: number, b: number): Color3
    return Color3_Global.new(r, g, b)
end

Color3.toRGB = t.wrap(function(color: Color3): (number, number, number)
    return color.R, color.G, color.B
end, t.Color3)

return Color3