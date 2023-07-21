--!strict

local root = script.Parent

local ColorTypes = require(root.ColorTypes)
local Types = require(root.Types)
local WebColors = require(root.WebColors)

local Blend = require(root.Blend)
local DeltaE = require(root.DeltaE)
local Utils = require(root.Utils)

---

-- These functions are used by the library
assert(ColorTypes.Lab.fromXYZ)
assert(ColorTypes.Lab.toXYZ)
assert(ColorTypes.LChab.fromLab)
assert(ColorTypes.LChab.toLab)

-- Used for Color.random
local rng: Random = Random.new()

-- These color types expect RGB components in the range [0, 1]
local clampedColorTypes: {[Types.ColorType]: true} = {
    BrickColor = true,
    CMYK = true,
    Color3 = true,
    Hex = true,
    HSB = true,
    HSL = true,
    HSV = true,
    HWB = true,
    Number = true,
    RGB = true,
    Temperature = true,
}

-- These color types have a hue component that needs to be handled differently when mixing
local hueComponentIndices: {[Types.ColorType]: number} = {
    HSB = 1,
    HSL = 1,
    HSV = 1,
    HWB = 1,
    LCh = 3,
    LChab = 3,
    LChuv = 3,
}

---

local Color = {}
local colorMetatable = { __index = Color }

--[[
    Creates a new Color with normalised RGB components
]]
Color.new = function(r: number, g: number, b: number)
    return table.freeze(setmetatable({
        R = r,
        G = g,
        B = b,
    }, colorMetatable))
end

export type Color = typeof(Color.new(0, 0, 0))

colorMetatable.__eq = function(color1: Color, color2: Color): boolean
    local r1: number, g1: number, b1: number = color1.R, color1.G, color1.B
    local r2: number, g2: number, b2: number = color2.R, color2.G, color2.B

    return (r1 == r2) and (g1 == g2) and (b1 == b2)
end

colorMetatable.__tostring = function(color: Color): string
    local components: {number} = {color.R, color.G, color.B}

    return table.concat(components, ", ")
end

colorMetatable.__add = function(color1: Color, color2: Color): Color
    local r1: number, g1: number, b1: number = color1.R, color1.G, color1.B
    local r2: number, g2: number, b2: number = color2.R, color2.G, color2.B

    return Color.new(r1 + r2, g1 + g2, b1 + b2)
end

colorMetatable.__sub = function(color1: Color, color2: Color): Color
    local r1: number, g1: number, b1: number = color1.R, color1.G, color1.B
    local r2: number, g2: number, b2: number = color2.R, color2.G, color2.B

    return Color.new(r1 - r2, g1 - g2, b1 - b2)
end

colorMetatable.__mul = function(a: Color | number, b: Color | number): Color
    if ((typeof(a) == "number") and (typeof(b) ~= "number")) then
        -- number, Color
        local r: number, g: number, bR: number = b.R, b.G, b.B

        return Color.new(r * a, g * a, bR * a)
    elseif ((typeof(a) ~= "number") and (typeof(b) == "number")) then
        -- Color, number
        local r: number, g: number, bR: number = a.R, a.G, a.B

        return Color.new(r * b, g * b, bR * b)
    elseif ((typeof(a) ~= "number") and (typeof(b) ~= "number")) then
        -- Color, Color
        local r1: number, g1: number, b1: number = a.R, a.G, a.B
        local r2: number, g2: number, b2: number = b.R, b.G, b.B

        return Color.new(r1 * r2, g1 * g2, b1 * b2)
    end

    error("cannot multiply types")
end

colorMetatable.__div = function(a: Color | number, b: Color | number): Color
    if ((typeof(a) == "number") and (typeof(b) ~= "number")) then
        -- number, Color
        local r: number, g: number, bR: number = b.R, b.G, b.B

        return Color.new(r / a, g / a, bR / a)
    elseif ((typeof(a) ~= "number") and (typeof(b) == "number")) then
        -- Color, number
        local r: number, g: number, bR: number = a.R, a.G, a.B

        return Color.new(r / b, g / b, bR / b)
    elseif ((typeof(a) ~= "number") and (typeof(b) ~= "number")) then
        -- Color, Color
        local r1: number, g1: number, b1: number = a.R, a.G, a.B
        local r2: number, g2: number, b2: number = b.R, b.G, b.B

        return Color.new(r1 / r2, g1 / g2, b1 / b2)
    end

    error("cannot divide types")
end

table.freeze(colorMetatable)

---

--[[
    Checks if a value can be used as a Color in the API
]]
Color.isAColor = function(value: any): (boolean, string?)
    if (typeof(value) ~= "table") then
        return false, "not a table"
    end

    return
        (typeof(value.R) == "number") and
        (typeof(value.G) == "number") and
        (typeof(value.B) == "number")
end

--[[
    Creates a Color with all components being 0
]]
Color.black = function(): Color
    return Color.new(0, 0, 0)
end

--[[
    Creates a Color with all components being 1
]]
Color.white = function(): Color
    return Color.new(1, 1, 1)
end

--[[
    Creates a Color with components (1, 0, 0)
]]
Color.red = function(): Color
    return Color.new(1, 0, 0)
end

--[[
    Creates a Color with components (0, 1, 0)
]]
Color.green = function(): Color
    return Color.new(0, 1, 0)
end

--[[
    Creates a Color with components (0, 0, 1)
]]
Color.blue = function(): Color
    return Color.new(0, 0, 1)
end

--[[
    Creates a Color with components (0, 1, 1)
]]
Color.cyan = function(): Color
    return Color.new(0, 1, 1)
end

--[[
    Creates a Color with components (1, 0, 1)
]]
Color.magenta = function(): Color
    return Color.new(1, 0, 1)
end

--[[
    Creates a Color with components (1, 1, 0)
]]
Color.yellow = function(): Color
    return Color.new(1, 1, 0)
end

--[[
    Creates a Color with random components
]]
Color.random = function(): Color
    return Color.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

--[[
    Creates a Color with all components being the same number

    @param scale? The amount of grey, with 0 being black and 1 being white; default is 0.5
]]
Color.gray = function(optionalScale: number?): Color
    local scale: number = optionalScale or 0.5

    return Color.new(scale, scale, scale)
end

--[[
    Creates a Color from one of the color keywords
    specified in CSS Color Module Level 3
]]
Color.named = function(name: string): Color
    local hex: string = WebColors[string.lower(name)]
    assert(hex, "invalid name")

    return Color.new(ColorTypes.Hex.toRGB(hex))
end

--[[
    Creates a Color from one of several color types
]]
Color.from = function(colorType: Types.ColorType, ...: any): Color
    local colorInterface: Types.ColorInterface? = ColorTypes[colorType]
    assert(colorInterface, "unknown color interface")

    local r: number, g: number, b: number = colorInterface.toRGB(...)
    assert(r and g and b, "invalid components")

    return Color.new(r, g, b)
end

--[[
    Returns the components of a Color as a tuple

    @param color
    @param clamped? Whether or not to return clamped components
]]
Color.components = function(color: Color, clamped: boolean?): (number, number, number)
    if (clamped) then
        return math.clamp(color.R, 0, 1), math.clamp(color.G, 0, 1), math.clamp(color.B, 0, 1)
    else
        return color.R, color.G, color.B
    end
end

--[[
    Checks if a Color's components are unclamped
]]
Color.isUnclamped = function(color: Color): boolean
    local r: number, g: number, b: number = Color.components(color)

    return
        (r < 0) or (r > 1) or
        (g < 0) or (g > 1) or
        (b < 0) or (b > 1)
end

--[[
    **DEPRECATED**

    Alias for `Color.isUnclamped`
]]
Color.isUnclipped = Color.isUnclamped

--[[
    Returns if the components of two Colors are within a certain distance of each other

    @param refColor
    @param testColor
    @param clamped? Whether to compare clamped components
    @param epsilon? Default 0.0000001 (1e-7)
]]
Color.fuzzyEq = function(refColor: Color, testColor: Color, optionalEpsilon: number?, clamped: boolean?): boolean
    local epsilon: number = optionalEpsilon or 1e-7
    local r1: number, g1: number, b1: number = Color.components(refColor, clamped)
    local r2: number, g2: number, b2: number = Color.components(testColor, clamped)

    return
        (math.abs(r2 - r1) <= epsilon) and
        (math.abs(g2 - g1) <= epsilon) and
        (math.abs(b2 - b1) <= epsilon)
end

--[[
    Returns if the unclamped components of two Colors are equal
]]
Color.clampedEq = function(refColor: Color, testColor: Color): boolean
    return Color.fuzzyEq(refColor, testColor, 0, true)
end

--[[
    Converts the Color into a different color type
]]
Color.to = function(color: Color, colorType: Types.ColorType): ...any
    local colorInterface: Types.ColorInterface? = ColorTypes[colorType]
    assert(colorInterface, "unknown color interface")

    local clampComponents: boolean? = clampedColorTypes[colorType]
    return colorInterface.fromRGB(Color.components(color, clampComponents))
end

--[[
    Returns a Color with inverted components
]]
Color.invert = function(color: Color): Color
    return Color.new(1 - color.R, 1 - color.G, 1 - color.B)
end

--[[
    Returns a Color that is a mix between two other Colors

    @param startColor
    @param endColor
    @param ratio How mixed the two colors are between 0 and 1, with 0 being the start color, 1 being the end color, and 0.5 being an equal mix
    @param colorType? The color type to mix with
    @param hueAdjustment? The hue adjustment method when mixing with color types that have a hue component
]]
Color.mix = function(startColor: Color, endColor: Color, ratio: number, optionalColorType: Types.MixableColorType?, optionalHueAdjustment: Types.HueAdjustment?): Color
    local colorType: Types.MixableColorType = optionalColorType or "RGB"
    assert(ColorTypes[colorType], "invalid interpolation " .. colorType)

    local startColorComponents: {number}
    local endColorComponents: {number}
    local mixedColorComponents: {number} = {}

    if (colorType == "RGB") then
        startColorComponents, endColorComponents = { Color.components(startColor) }, { Color.components(endColor) }
    else
        startColorComponents, endColorComponents = { Color.to(startColor, colorType) }, { Color.to(endColor, colorType) }
    end

    for i = 1, #startColorComponents do
        if (i == hueComponentIndices[colorType]) then
            mixedColorComponents[i] = Utils.HueLerp(startColorComponents[i], endColorComponents[i], ratio, optionalHueAdjustment)
        else
            mixedColorComponents[i] = Utils.Lerp(startColorComponents[i], endColorComponents[i], ratio)
        end
    end

    return if (colorType == "RGB") then
        Color.new(table.unpack(mixedColorComponents))
    else Color.from(colorType, table.unpack(mixedColorComponents))
end

--[[
    Returns a Color that is a composite blend between of two Colors

    @param backgroundColor The color in the background
    @param foregroundColor The color in the foreground
    @param blendMode The method of blending
]]
Color.blend = function(backgroundColor: Color, foregroundColor: Color, blendMode: Types.BlendMode): Color
    local backgroundColorComponents: {number} = { Color.components(backgroundColor, true) }
    local foregroundColorComponents: {number} = { Color.components(foregroundColor, true) }

    return Color.new(Blend(backgroundColorComponents, foregroundColorComponents, blendMode))
end

--[[
    Returns the DeltaE of two Colors

    @param refColor The Color being compared to
    @param testColor The Color being compared
    @param kL Weight factor, default 1
    @param kC Weight factor, default 1
    @param kH Weight factor, default 1
]]
Color.deltaE = function(refColor: Color, testColor: Color, kL: number?, kC: number?, kH: number?): number
    local refColorComponents: {number} = { Color.to(refColor, "Lab") }
    local testColorComponents: {number} = { Color.to(testColor, "Lab") }

    return DeltaE(refColorComponents, testColorComponents, kL, kC, kH)
end

-- WCAG definition of relative luminance
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
-- Errata: https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187
--[[
    Returns the relative luminance of a Color between 0 and 1
]]
Color.luminance = function(color: Color): number
    local rgb: {number} = { Color.components(color, true) }

    return
        (0.2126 * Utils.GammaCorrection.toLinear(rgb[1])) +
        (0.7152 * Utils.GammaCorrection.toLinear(rgb[2])) +
        (0.0722 * Utils.GammaCorrection.toLinear(rgb[3]))
end

-- WCAG 2 contrast ratio
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
--[[
    Returns the contrast ratio between two Colors

    @return The constrast ratio, between 1 and 21
]]
Color.contrast = function(refColor: Color, testColor: Color): number
    local refColorLuminance: number = Color.luminance(refColor)
    local testColorLuminance: number = Color.luminance(testColor)

    return if (refColorLuminance > testColorLuminance) then
        ((refColorLuminance + 0.05) / (testColorLuminance + 0.05))
    else ((testColorLuminance + 0.05) / (refColorLuminance + 0.05))
end

--[[
    Returns the Color with the highest constrast ratio with the reference Color

    @param refColor The Color being compared to
    @param ... The Colors being compared
    @return The best-contrasting Color
    @return The contrast ratio of said Color
]]
Color.bestContrastingColor = function(refColor: Color, ...: Color): (Color, number)
    local options: {Color} = {...}
    assert(#options >= 2, "no colors to compare")

    table.sort(options, function(option1, option2)
        local option1ContrastRatio = Color.contrast(refColor, option1)
        local option2ContrastRatio = Color.contrast(refColor, option2)

        return (option1ContrastRatio > option2ContrastRatio)
    end)

    local bestColor: Color = options[1]
    return bestColor, Color.contrast(refColor, bestColor)
end

--[[
    Returns a brightened Color using L*a*b*

    @param color
    @param amount? The amount to brighten, default 1 unit (1 unit = 18 L\*)
]]
Color.brighten = function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, a: number, b: number = ColorTypes.Lab.fromXYZ(Color.to(color, "XYZ"))
    l = l + (amount * 0.18)

    return Color.from("XYZ", ColorTypes.Lab.toXYZ(l, a, b))
end

--[[
    Returns a darkened Color using L*a*b*\
    Equivalent to `Color.brighten(Color, -amount)`

    @param color
    @param amount? The amount to darken, default 1 unit (1 unit = 18 L\*)
]]
Color.darken = function(color: Color, amount: number?): Color
    return Color.brighten(color, -(amount or 1))
end

--[[
    Returns a more-saturated Color using L\*C\*h

    @param color
    @param amount? The amount to saturate, default 1 unit (1 unit = 18 C\*)
]]
Color.saturate = function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, c: number, h: number = ColorTypes.LChab.fromLab(ColorTypes.Lab.fromXYZ(Color.to(color, "XYZ")))
    c = c + (amount * 0.18)
    c = (c < 0) and 0 or c

    return Color.from("XYZ", ColorTypes.Lab.toXYZ(ColorTypes.LChab.toLab(l, c, h)))
end

--[[
    Returns a desaturated Color using L\*C\*h\
    Equivalent to `Color.saturate(color, -amount)`

    @param color
    @param amount? The amount to saturate, default 1 unit (1 unit = 18 C\*)
]]
Color.desaturate = function(color: Color, amount: number?): Color
    return Color.saturate(color, -(amount or 1))
end

--[[
    Returns a list of Colors that are harmonies of another

    @param color
    @param harmony The color harmony
    @param analogyAngle? The angle in degrees to separate hues when using analogous harmonies
    @return An array of Colors, sorted by absolute hue distance from the original Color
]]
Color.harmonies = function(color: Color, harmony: Types.Harmony, optionalAnalogyAngle: number?): {Color}
    local h: number, s: number, b: number = Color.to(color, "HSB")
    local analogyAngle: number = optionalAnalogyAngle or math.deg(2 * math.pi / 12)
    local harmonies: {Color} = {}

    if (harmony == "Complementary") then
        table.insert(harmonies, Color.from("HSB", h + math.deg(math.pi), s, b))
    elseif (harmony == "Triadic") then
        local harmonyAngle: number = math.deg(2 * math.pi) / 3

        for i = 1, 2 do
            table.insert(harmonies, Color.from("HSB", h + (i * harmonyAngle), s, b))
        end
    elseif (harmony == "Square") then
        local harmonyAngle: number = math.deg(2 * math.pi) / 4

        for i = 1, 3 do
            table.insert(harmonies, Color.from("HSB", h + (i * harmonyAngle), s, b))
        end
    elseif (harmony == "Analogous") then
        table.insert(harmonies, Color.from("HSB", h - analogyAngle, s, b))
        table.insert(harmonies, Color.from("HSB", h + analogyAngle, s, b))
    elseif (harmony == "SplitComplementary") then
        local complementaryAngle: number = h + math.deg(math.pi)

        table.insert(harmonies, Color.from("HSB", complementaryAngle - analogyAngle, s, b))
        table.insert(harmonies, Color.from("HSB", complementaryAngle + analogyAngle, s, b))
    elseif (harmony == "Tetradic") then
        local complementaryAngle: number = h + math.deg(math.pi)

        table.insert(harmonies, Color.from("HSB", h + analogyAngle, s, b))
        table.insert(harmonies, Color.from("HSB", complementaryAngle, s, b))
        table.insert(harmonies, Color.from("HSB", complementaryAngle + analogyAngle, s, b))
    else
        error("invalid harmony")
    end

    return harmonies
end

---

local fromAlternative = function(colorType: Types.ColorType): (...any) -> Color
    assert(ColorTypes[colorType], "invalid color type")

    return function(...: any): Color
        return Color.from(colorType, ...)
    end
end

local toAlternative = function(colorType: Types.ColorType): (color: Color) -> ...any
    assert(ColorTypes[colorType], "invalid color type")

    return function(color: Color): ...any
        return Color.to(color, colorType)
    end
end

--[[
    Creates a Color from a BrickColor
]]
Color.fromBrickColor = fromAlternative("BrickColor")::(brickColor: BrickColor) -> Color

--[[
    Converts a Color to a BrickColor
]]
Color.toBrickColor = toAlternative("BrickColor")::(color: Color) -> BrickColor

--[[
    Creates a Color from CMYK components in [0, 1]
]]
Color.fromCMYK = fromAlternative("CMYK")::(c: number, m: number, y: number, k: number) -> Color

--[[
    Converts a Color to CMYK components in [0, 1]
]]
Color.toCMYK = toAlternative("CMYK")::(color: Color) -> (number, number, number, number)

--[[
    Creates a Color from a Color3
]]
Color.fromColor3 = fromAlternative("Color3")::(color3: Color3) -> Color

--[[
    Converts a Color to a Color3
]]
Color.toColor3 = toAlternative("Color3")::(color: Color) -> Color3

--[[
    Creates a Color from a hex string
    - The string may have a leading #
    - The string may be a short hex (e.g. #abc)
]]
Color.fromHex = fromAlternative("Hex")::(hex: string) -> Color

--[[
    Converts a Color to a hex string
]]
Color.toHex = toAlternative("Hex")::(color: Color) -> string

--[[
    Creates a Color from HSB components

    @param h The hue in degrees
    @param s The saturation between 0 and 1
    @param b The brightness between 0 and 1
]]
Color.fromHSB = fromAlternative("HSB")::(h: number, s: number, b: number) -> Color

--[[
    Converts a Color to HSB components

    @return The hue in degrees between 0 and 360 (or NaN)
    @return The saturation between 0 and 1
    @return The brightness between 0 and 1
]]
Color.toHSB = toAlternative("HSB")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from HSL components

    @param h The hue in degrees
    @param s The saturation between 0 and 1
    @param l The lightness between 0 and 1
]]
Color.fromHSL = fromAlternative("HSL")::(h: number, s: number, l: number) -> Color

--[[
    Converts a Color to HSL components

    @return The hue in degrees between 0 and 360 (or NaN)
    @return The saturation between 0 and 1
    @return The lightness between 0 and 1
]]
Color.toHSL = toAlternative("HSL")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from HWB components

    @param h The hue in degrees
    @param w The whiteness between 0 and 1
    @param b The blackness between 0 and 1
]]
Color.fromHWB = fromAlternative("HWB")::(h: number, w: number, b: number) -> Color

--[[
    Converts a Color to HWB components

    @return The hue in degrees between 0 and 360 (or NaN)
    @return The whiteness between 0 and 1
    @return The blackness between 0 and 1
]]
Color.toHWB = toAlternative("HWB")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from L\*a\*b\* components

    @param l The lightness between 0 and 1
    @param a The green-magenta component typically between -1.28 and 1.27, with negative values toward green and positive values toward magenta
    @param b The blue-yellow component typically between -1.28 and 1.27, with negative values toward blue and positive values toward yellow
]]
Color.fromLab = fromAlternative("Lab")::(l: number, a: number, b: number) -> Color

--[[
    Converts a Color to L\*a\*b\* components

    @return The lightness between 0 and 1
    @return The green-magenta component typically between -1.28 and 1.27, with negative values toward green and positive values toward magenta
    @return The blue-yellow component typically between -1.28 and 1.27, with negative values toward blue and positive values toward yellow
]]
Color.toLab = toAlternative("Lab")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from cylindrical L\*a\*b\* components

    @param l The lightness between 0 and 1
    @param c The chroma typically between 0 and 1.5
    @param h The hue in degrees
]]
Color.fromLChab = fromAlternative("LChab")::(l: number, c: number, h: number) -> Color

--[[
    Converts a Color to cylindrical L\*a\*b\* components

    @return The lightness between 0 and 1
    @return The chroma typically between 0 and 1.5
    @return The hue in degrees
]]
Color.toLChab = toAlternative("LChab")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from cylindrical L\*u\*v\* components

    @param l The lightness between 0 and 1
    @param c The chroma typically between 0 and 1.5
    @param h The hue in degrees
]]
Color.fromLChuv = fromAlternative("LChuv")::(l: number, c: number, h: number) -> Color

--[[
    Converts a Color to cylindrical L\*u\*v\* components

    @return The lightness between 0 and 1
    @return The chroma typically between 0 and 1.5
    @return The hue in degrees
]]
Color.toLChuv = toAlternative("LChuv")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from L\*u\*v\* components

    @param l The lightness between 0 and 1
    @param u The green-magenta component typically between -1 and 1, with negative values toward green and positive values toward magenta
    @param v The blue-yellow component typically between -1 and 1, with negative values toward blue and positive values toward yellow
]]
Color.fromLuv = fromAlternative("Luv")::(l: number, u: number, v: number) -> Color

--[[
    Converts a Color to L\*u\*v\* components

    @param The lightness between 0 and 1
    @param The green-magenta component typically between -1 and 1, with negative values toward green and positive values toward magenta
    @param The blue-yellow component typically between -1 and 1, with negative values toward blue and positive values toward yellow
]]
Color.toLuv = toAlternative("Luv")::(color: Color) -> (number, number, number)

--[[
    Create a Color from an integer

    @param n The number between 0 and 256^3-1
]]
Color.fromNumber = fromAlternative("Number")::(n: number) -> Color

--[[
    Converts a Color to an integer

    @return The number between 0 and 256^3-1
]]
Color.toNumber = toAlternative("Number")::(color: Color) -> number

--[[
    Creates a Color from RGB components in the range [0, 255]
]]
Color.fromRGB = fromAlternative("RGB")::(r: number, g: number, b: number) -> Color

--[[
    Converts a Color to RGB components in the range [0, 255]
]]
Color.toRGB = toAlternative("RGB")::(color: Color) -> (number, number, number)

--[[
    Creates a Color from a blackbody temperature\
    Works best between 1000K and 40000K

    @param temperature The temperature in Kelvin
]]
Color.fromTemperature = fromAlternative("Temperature")::(temperature: number) -> Color

--[[
    Converts a Color to a blackbody temperature

    @return The temperature in Kelvin
]]
Color.toTemperature = toAlternative("Temperature")::(color: Color) -> number

--[[
    Creates a Color from XYZ tristimulus values typically between 0 and 1
]]
Color.fromXYZ = fromAlternative("XYZ")::(x: number, y: number, z: number) -> Color

--[[
    Converts a Color to XYZ tristimulus values typically between 0 and 1
]]
Color.toXYZ = toAlternative("XYZ")::(color: Color) -> (number, number, number)

--[[
    Alias for `Color.fromHSB`
]]
Color.fromHSV = Color.fromHSB::(h: number, s: number, v: number) -> Color

--[[
    Alias for `Color.toHSB`
]]
Color.toHSV = Color.toHSB

--[[
    Alias for `Color.fromLChab`
]]
Color.fromLCh = Color.fromLChab

--[[
    Alias for `Color.toLChab`
]]
Color.toLCh = Color.toLChab

return table.freeze(Color)