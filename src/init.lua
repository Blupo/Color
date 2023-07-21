--!strict

local Color = require(script.Color)
local Gradient = require(script.Gradient)
local Types = require(script.Types)

export type BlendMode = Types.BlendMode
export type HueAdjustment = Types.HueAdjustment
export type Harmony = Types.Harmony

export type MixableColorType = Types.MixableColorType
export type ColorType = Types.ColorType

export type Color = Color.MetaColor
export type ColorParam = Color.Color

export type GradientKeypoint = Gradient.GradientKeypoint
export type Gradient = Gradient.MetaGradient
export type GradientParam = Gradient.Gradient

---

return {
    Color = Color,
    Gradient = Gradient,
}