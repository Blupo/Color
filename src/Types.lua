--!strict

--[=[
    @class Enums
]=]

---

local Types = {}

--[=[
    @interface BlendMode
    @within Enums
    @field Normal "Normal"
    @field Multiply "Multiply"
    @field Screen "Screen"
    @field ColorDodge "ColorDodge"
    @field ColorBurn "ColorBurn"
    @field SoftLight "SoftLight"
    @field Difference "Difference"
    @field Exclusion "Exclusion"
    @field Darken "Darken"
    @field Lighten "Lighten"
    @field HardLight "HardLight"
    @field Overlay "Overlay"
    @field Hue "Hue"
    @field Saturation "Saturation"
    @field Color "Color"
    @field Luminosity "Luminosity"
]=]
export type SeparableBlendMode = "Normal" | "Multiply" | "Screen" | "ColorDodge" | "ColorBurn" | "SoftLight" | "Difference" | "Exclusion" | "Darken" | "Lighten" | "HardLight" | "Overlay"
export type NonSeparableBlendMode = "Hue" | "Saturation" | "Color" | "Luminosity"
export type BlendMode = SeparableBlendMode | NonSeparableBlendMode

--[=[
    @interface MixableColorType
    @within Enums
    @field CMYK "CMYK"
    @field HPLuv "HPLuv"
    @field HSB "HSB"
    @field HSL "HSL"
    @field HSLuv "HSLuv"
    @field HSV "HSV"
    @field HWB "HWB"
    @field LCh "LCh"
    @field LChab "LChab"
    @field LChuv "LChuv"
    @field Lab "Lab"
    @field Luv "Luv"
    @field Oklab "Oklab"
    @field RGB "RGB"
    @field xyY "xyY"
    @field XYZ "XYZ"
]=]

--[=[
    @interface ColorType
    @within Enums
    @field BrickColor "BrickColor"
    @field CMYK "CMYK"
    @field Color3 "Color3"
    @field HPLuv "HPLuv"
    @field HSB "HSB"
    @field HSL "HSL"
    @field HSLuv "HSLuv"
    @field HSV "HSV"
    @field HWB "HWB"
    @field Hex "Hex"
    @field LCh "LCh"
    @field LChab "LChab"
    @field LChuv "LChuv"
    @field Lab "Lab"
    @field Luv "Luv"
    @field Number "Number"
    @field Oklab "Oklab"
    @field RGB "RGB"
    @field Temperature "Temperature"
    @field xyY "xyY"
    @field XYZ "XYZ"
]=]
export type MixableColorType = "CMYK" | "HPLuv" | "HSB" | "HSL" | "HSLuv" | "HSV" | "HWB" | "LCh" | "LChab" | "LChuv" | "Lab" | "Luv" | "Oklab" | "RGB" | "xyY" | "XYZ"
export type NonMixableColorType = "BrickColor" | "Color3" | "Hex" | "Number" | "Temperature"
export type ColorType = MixableColorType | NonMixableColorType

--[=[
    @interface HueAdjustment
    @within Enums
    @field Shorter "Shorter"
    @field Longer "Longer"
    @field Increasing "Increasing"
    @field Decreasing "Decreasing"
    @field Raw "Raw"
    @field Specified "Specified"
]=]
export type HueAdjustment = "Shorter" | "Longer" | "Increasing" | "Decreasing" | "Raw" | "Specified"

--[=[
    @interface Harmony
    @within Enums
    @field Complementary "Complementary"
    @field Triadic "Triadic"
    @field Square "Square"
    @field Analogous "Analogous"
    @field SplitComplementary "SplitComplementary"
    @field Tetradic "Tetradic"
]=]
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