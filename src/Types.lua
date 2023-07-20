--!strict

local root = script.Parent
local t = require(root.t)

---

local Types = {
    Runtime = {}::{[string]: (any) -> (boolean, string?)},
}

--      [[ Luau Types ]]

export type SeparableBlendMode = "Normal" | "Multiply" | "Screen" | "ColorDodge" | "ColorBurn" | "SoftLight" | "Difference" | "Exclusion" | "Darken" | "Lighten" | "HardLight" | "Overlay"
export type NonSeparableBlendMode = "Hue" | "Saturation" | "Color" | "Luminosity"
export type BlendMode = SeparableBlendMode | NonSeparableBlendMode

export type HueAdjustment = "Shorter" | "Longer" | "Increasing" | "Decreasing" | "Raw" | "Specified"
export type ColorType = "BrickColor" | "CMYK" | "Color3" | "HSB" | "HSL" | "HSV" | "HWB" | "Hex" | "LCh" | "LChab" | "LChuv" | "Lab" | "Luv" | "Number" | "RGB" | "Temperature" | "xyY" | "XYZ"
export type Harmony = "Complementary" | "Triadic" | "Square" | "Analogous" | "SplitComplementary" | "Tetradic"

export type RGBInterface = {
    fromRGB: (number, number, number) -> ...any,
    toRGB: (...any) -> (number, number, number)
}

export type XYZInterface = {
    fromXYZ: ((number, number, number) -> ...any)?,
    toXYZ: ((...any) -> (number, number, number))?
}

export type LabInterface = {
    fromLab: ((number, number, number) -> (number, number, number))?,
    toLab: ((number, number, number) -> (number, number, number))?,
}

export type LuvInterfacce = {
    fromLuv: ((number, number, number) -> (number, number, number))?,
    toLuv: ((number, number, number) -> (number, number, number))?,
}

export type ColorInterface = RGBInterface & XYZInterface & LabInterface & LuvInterfacce

--      [[ Runtime Types ]]

Types.Runtime.SeparableBlendMode = t.literals("Normal", "Multiply", "Screen", "ColorDodge", "ColorBurn", "SoftLight", "Difference", "Exclusion", "Darken", "Lighten", "HardLight", "Overlay")
Types.Runtime.NonSeparableBlendMode = t.literals("Hue", "Saturation", "Color", "Luminosity")
Types.Runtime.BlendMode = t.union(Types.Runtime.SeparableBlendMode, Types.Runtime.NonSeparableBlendMode)

Types.Runtime.HueAdjustment = t.literals("Shorter", "Longer", "Increasing", "Decreasing", "Raw", "Specified")
Types.Runtime.ColorType = t.literals("BrickColor", "CMYK", "Color3", "HSB", "HSL", "HSV", "HWB", "Hex", "LCh", "LChab", "LChuv", "Lab", "Luv", "Number", "RGB", "Temperature", "xyY", "XYZ")
Types.Runtime.Harmony = t.literals("Complementary", "Triadic", "Square", "Analogous", "SplitComplementary", "Tetradic")

return Types