--!strict

local Color = require(script.Color)
local Gradient = require(script.Gradient)
local Types = require(script.Types)

export type BlendMode = Types.BlendMode
export type HueAdjustment = Types.HueAdjustment
export type ColorType = Types.ColorType
export type Harmony = Types.Harmony
export type Color = Color.Color

export type GradientKeypoint = Gradient.GradientKeypoint
export type Gradient = Gradient.Gradient

---

return {
    Color = Color,
    Gradient = Gradient,
}