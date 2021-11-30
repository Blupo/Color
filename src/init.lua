--!strict

local Color = require(script.Color)
local Gradient = require(script.Gradient)

export type Color = Color.Color
export type Gradient = Gradient.Gradient
export type GradientKeypoint = Gradient.GradientKeypoint

---

return {
    Color = Color,
    Gradient = Gradient,
}