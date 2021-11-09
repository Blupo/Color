--!strict

local root = script.Parent.Parent
local t = require(root.t)

---

local BrickColor_Global = BrickColor
local BrickColor = {}

BrickColor.fromRGB = function(r: number, g: number, b: number): BrickColor
    return BrickColor_Global.new(Color3.new(r, g, b))
end

BrickColor.toRGB = t.wrap(function(brickColor: BrickColor): (number, number, number)
    local color = brickColor.Color

    return color.R, color.G, color.B
end, t.BrickColor)

return BrickColor