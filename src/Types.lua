--!strict

local Types = {}

export type SeparableBlendMode = "Normal" | "Multiply" | "Screen" | "ColorDodge" | "ColorBurn" | "SoftLight" | "Difference" | "Exclusion" | "Darken" | "Lighten" | "HardLight" | "Overlay"
export type NonSeparableBlendMode = "Hue" | "Saturation" | "Color" | "Luminosity"
export type BlendMode = SeparableBlendMode | NonSeparableBlendMode

export type MixableColorType = "CMYK" | "HSB" | "HSL" | "HSV" | "HWB" | "LCh" | "LChab" | "LChuv" | "Lab" | "Luv" | "RGB" | "xyY" | "XYZ"
export type NonMixableColorType = "BrickColor" | "Color3" | "Hex" | "Number"| "Temperature"
export type ColorType = MixableColorType | NonMixableColorType

export type HueAdjustment = "Shorter" | "Longer" | "Increasing" | "Decreasing" | "Raw" | "Specified"
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

return Types