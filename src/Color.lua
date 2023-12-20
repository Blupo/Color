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
assert(ColorTypes.Lab.fromXYZ, "XYZ to CIELAB conversion missing")
assert(ColorTypes.Lab.toXYZ, "CIELAB to XYZ conversion missing")
assert(ColorTypes.LChab.fromLab, "CIELAB to CIELCh(ab) conversion missing")
assert(ColorTypes.LChab.toLab, "CIELCh(ab) to CIELAB conversion missing")

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

--[=[
    @class Color
]=]

--[=[
    The normalised red channel of the color. This is typically between 0 and 1, but is not guaranteed.

    @prop R number
    @within Color
    @readonly
]=]

--[=[
    The normalised green channel of the color. This is typically between 0 and 1, but is not guaranteed.

    @prop G number
    @within Color
    @readonly
]=]

--[=[
    The normalised blue channel of the color. This is typically between 0 and 1, but is not guaranteed.

    @prop B number
    @within Color
    @readonly
]=]

local Color = {}
local colorMetatable = { __index = Color }

--[=[
    Creates a new Color with normalised RGB components

    @function new
    @within Color
    @param r number
    @param g number
    @param b number
    @return Color
    @tag Constructor
]=]
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

--[=[
    Checks if a value is a Color

    @function isAColor
    @within Color
    @param value any
    @return boolean
    @return string?
]=]
Color.isAColor = function(value: any): (boolean, string?)
    if (typeof(value) ~= "table") then
        return false, "not a table"
    end

    return
        (typeof(value.R) == "number") and
        (typeof(value.G) == "number") and
        (typeof(value.B) == "number")
end

--[=[
    Creates a Color with all components being 0

    @function black
    @within Color
    @return Color
    @tag Constructor
]=]
Color.black = function(): Color
    return Color.new(0, 0, 0)
end

--[=[
    Creates a Color with all components being 1

    @function white
    @within Color
    @return Color
    @tag Constructor
]=]
Color.white = function(): Color
    return Color.new(1, 1, 1)
end

--[=[
    Creates a Color with components (1, 0, 0)

    @function red
    @within Color
    @return Color
    @tag Constructor
]=]
Color.red = function(): Color
    return Color.new(1, 0, 0)
end

--[=[
    Creates a Color with components (0, 1, 0)

    @function green
    @within Color
    @return Color
    @tag Constructor
]=]
Color.green = function(): Color
    return Color.new(0, 1, 0)
end

--[=[
    Creates a Color with components (0, 0, 1)

    @function blue
    @within Color
    @return Color
    @tag Constructor
]=]
Color.blue = function(): Color
    return Color.new(0, 0, 1)
end

--[=[
    Creates a Color with components (0, 1, 1)

    @function cyan
    @within Color
    @return Color
    @tag Constructor
]=]
Color.cyan = function(): Color
    return Color.new(0, 1, 1)
end

--[=[
    Creates a Color with components (1, 0, 1)

    @function magenta
    @within Color
    @return Color
    @tag Constructor
]=]
Color.magenta = function(): Color
    return Color.new(1, 0, 1)
end

--[=[
    Creates a Color with components (1, 1, 0)

    @function yellow
    @within Color
    @return Color
    @tag Constructor
]=]
Color.yellow = function(): Color
    return Color.new(1, 1, 0)
end

--[=[
    Creates a Color with random components

    @function random
    @within Color
    @return Color
    @tag Constructor
]=]
Color.random = function(): Color
    return Color.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

--[=[
    Creates a Color with all components being the same number

    @function gray
    @within Color
    @param scale number?
    @return Color
    @tag Constructor
]=]
Color.gray = function(optionalScale: number?): Color
    local scale: number = optionalScale or 0.5

    return Color.new(scale, scale, scale)
end

--[=[
    Creates a Color from one of the color keywords
    specified in [CSS Color Module Level 3](https://www.w3.org/TR/2021/REC-css-color-3-20210805/#svg-color).

    @function named
    @within Color
    @param name string
    @return Color
    @tag Constructor
]=]
Color.named = function(name: string): Color
    local hex: string = WebColors[string.lower(name)]
    assert(hex, "invalid name")

    return Color.new(ColorTypes.Hex.toRGB(hex))
end

--[=[
    Imports a Color from another color type. See the [ColorType enum](/api/Enums#ColorType) for the accepted types and
    [the documentation](/docs/color-types) for what arguments they accept.

    @function from
    @within Color
    @param colorType ColorType
    @param ... any
    @return Color
    @tag Import
]=]
Color.from = function(colorType: Types.ColorType, ...: any): Color
    local colorInterface: Types.ColorInterface? = ColorTypes[colorType]
    assert(colorInterface, "unknown color interface")

    local r: number, g: number, b: number = colorInterface.toRGB(...)
    assert(r and g and b, "invalid components")

    return Color.new(r, g, b)
end

--[=[
    Returns the RGB components of a Color as a tuple

    @function components
    @within Color
    @param color Color
    @param clamped boolean? -- Whether or not to return clamped components
    @return number
    @return number
    @return number
]=]
Color.components = function(color: Color, clamped: boolean?): (number, number, number)
    if (clamped) then
        return math.clamp(color.R, 0, 1), math.clamp(color.G, 0, 1), math.clamp(color.B, 0, 1)
    else
        return color.R, color.G, color.B
    end
end

--[=[
    Checks if one or more of a Color's components are outside the range [0, 1]

    @function isUnclamped
    @within Color
    @param color Color
    @return boolean
]=]
Color.isUnclamped = function(color: Color): boolean
    local r: number, g: number, b: number = Color.components(color)

    return
        (r < 0) or (r > 1) or
        (g < 0) or (g > 1) or
        (b < 0) or (b > 1)
end

--[=[
    Alias for [`Color.isUnclamped`](#isUnclamped)

    @deprecated 0.3.0
    @function isUnclipped
    @within Color
    @param color Color
    @return boolean
]=]
Color.isUnclipped = Color.isUnclamped

--[=[
    Returns if the components of two Colors are within a certain distance of each other

    @function fuzzyEq
    @within Color
    @param refColor Color
    @param testColor Color
    @param clamped boolean? -- Whether to compare clamped components
    @param epsilon number? -- The distance the components can be, default 0.0000001 (1e-7)
    @return boolean
]=]
Color.fuzzyEq = function(refColor: Color, testColor: Color, optionalEpsilon: number?, clamped: boolean?): boolean
    local epsilon: number = optionalEpsilon or 1e-7
    local r1: number, g1: number, b1: number = Color.components(refColor, clamped)
    local r2: number, g2: number, b2: number = Color.components(testColor, clamped)

    return
        (math.abs(r2 - r1) <= epsilon) and
        (math.abs(g2 - g1) <= epsilon) and
        (math.abs(b2 - b1) <= epsilon)
end

--[=[
    Returns if the clamped components of two Colors are equal

    @function clampedEq
    @within Color
    @param refColor Color
    @param testColor Color
    @return boolean
]=]
Color.clampedEq = function(refColor: Color, testColor: Color): boolean
    return Color.fuzzyEq(refColor, testColor, 0, true)
end

--[=[
    Exports the Color to a different color type. See the [ColorType enum](/api/Enums#ColorType) for the accepted types and
    [the documentation](/docs/color-types) for what values are returned.

    @function to
    @within Color
    @param color Color
    @param colorType ColorType
    @return ...any
    @tag Export
]=]
Color.to = function(color: Color, colorType: Types.ColorType): ...any
    local colorInterface: Types.ColorInterface? = ColorTypes[colorType]
    assert(colorInterface, "unknown color interface")

    local clampComponents: boolean? = clampedColorTypes[colorType]
    return colorInterface.fromRGB(Color.components(color, clampComponents))
end

--[=[
    Returns a Color with inverted components.
    This operation is only defined if the Color's components are clamped.

    @function invert
    @within Color
    @param color Color
    @return Color
]=]
Color.invert = function(color: Color): Color
    return Color.new(1 - color.R, 1 - color.G, 1 - color.B)
end

--[=[
    Returns a Color that is a mix between two other Colors

    @function mix
    @within Color
    @param startColor Color
    @param endColor Color
    @param ratio number -- How mixed the two colors are, between 0 and 1. 0 is the start color, 1 is the end color, and 0.5 is an equal mix of the two.
    @param colorType MixableColorType? -- The color type to mix with
    @param hueAdjustment HueAdjustment? -- The hue adjustment method when mixing with color types that have a hue component
    @return Color
]=]
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

--[=[
    Returns a Color that is a blend of two Colors

    @function blend
    @within Color
    @param backgroundColor Color -- The color in the background
    @param foregroundColor Color -- The color in the foreground (or the source color)
    @param blendMode BlendMode -- The blending method
    @return Color
]=]
Color.blend = function(backgroundColor: Color, foregroundColor: Color, blendMode: Types.BlendMode): Color
    local backgroundColorComponents: {number} = { Color.components(backgroundColor, true) }
    local foregroundColorComponents: {number} = { Color.components(foregroundColor, true) }

    return Color.new(Blend(backgroundColorComponents, foregroundColorComponents, blendMode))
end

--[=[
    Returns the Delta E of two Colors using [CIEDE2000](https://en.wikipedia.org/wiki/Color_difference#CIELAB_%CE%94E*)

    @function deltaE
    @within Color
    @param refColor Color
    @param testColor Color
    @param kL number? -- Weight factor, default 1
    @param kC number? -- Weight factor, default 1
    @param kH number? -- Weight factor, default 1
    @return number
]=]
Color.deltaE = function(refColor: Color, testColor: Color, kL: number?, kC: number?, kH: number?): number
    local refColorComponents: {number} = { Color.to(refColor, "Lab") }
    local testColorComponents: {number} = { Color.to(testColor, "Lab") }

    return DeltaE(refColorComponents, testColorComponents, kL, kC, kH)
end

-- WCAG definition of relative luminance
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
-- Errata: https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187
--[=[
    Returns the [relative luminance](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef) of a Color, between 0 and 1

    @function luminance
    @within Color
    @param color Color
    @return number
]=]
Color.luminance = function(color: Color): number
    local rgb: {number} = { Color.components(color, true) }

    return
        (0.2126 * Utils.GammaCorrection.toLinear(rgb[1])) +
        (0.7152 * Utils.GammaCorrection.toLinear(rgb[2])) +
        (0.0722 * Utils.GammaCorrection.toLinear(rgb[3]))
end

-- WCAG 2 contrast ratio
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
--[=[
    Returns the [contrast ratio](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef) between two Colors, between 1 and 21

    @function contrast
    @within Color
    @param refColor Color
    @param testColor Color
    @return number
]=]
Color.contrast = function(refColor: Color, testColor: Color): number
    local refColorLuminance: number = Color.luminance(refColor)
    local testColorLuminance: number = Color.luminance(testColor)

    return if (refColorLuminance > testColorLuminance) then
        ((refColorLuminance + 0.05) / (testColorLuminance + 0.05))
    else ((testColorLuminance + 0.05) / (refColorLuminance + 0.05))
end

--[=[
    Returns the Color with the highest [contrast ratio](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef) with the reference Color

    @function bestContrastingColor
    @within Color
    @param refColor Color
    @param ... Color
    @return Color
    @return number -- The constrast ratio of the best-contrasting Color
]=]
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

--[=[
    Returns a Color brightened using [CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space)

    @function brighten
    @within Color
    @param color Color
    @param amount number? -- The amount to brighten, default 1 unit (1 unit = 18 L\*)
    @return Color
]=]
Color.brighten = function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, a: number, b: number = ColorTypes.Lab.fromXYZ(Color.to(color, "XYZ"))
    l = l + (amount * 0.18)

    return Color.from("XYZ", ColorTypes.Lab.toXYZ(l, a, b))
end

--[=[
    Returns a Color darkened using [CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space)

    @function darken
    @within Color
    @param color Color
    @param amount number? -- The amount to darken, default 1 unit (1 unit = 18 L\*)
    @return Color
]=]
Color.darken = function(color: Color, amount: number?): Color
    return Color.brighten(color, -(amount or 1))
end

--[=[
    Returns a Color saturated using [CIELCh](https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model)

    @function saturate
    @within Color
    @param color Color
    @param amount number? -- The amount to saturate, default 1 unit (1 unit = 18 C\*)
    @return Color
]=]
Color.saturate = function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, c: number, h: number = ColorTypes.LChab.fromLab(ColorTypes.Lab.fromXYZ(Color.to(color, "XYZ")))
    c = c + (amount * 0.18)
    c = (c < 0) and 0 or c

    return Color.from("XYZ", ColorTypes.Lab.toXYZ(ColorTypes.LChab.toLab(l, c, h)))
end

--[=[
    Returns a Color desaturated using [CIELCh](https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model)

    @function desaturate
    @within Color
    @param color Color
    @param amount number? -- The amount to saturate, default 1 unit (1 unit = 18 C\*)
    @return Color
]=]
Color.desaturate = function(color: Color, amount: number?): Color
    return Color.saturate(color, -(amount or 1))
end

--[=[
    Returns a set of harmonic Colors

    @function harmonies
    @within Color
    @param color Color
    @param harmony Harmony -- The color harmony
    @param analogyAngle number? -- The angle in degrees to separate hues when using analogous harmonies
    @return {Color}
]=]
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

--[=[
    Imports a Color from a BrickColor

    @function fromBrickColor
    @within Color
    @param brickColor BrickColor
    @return Color
    @tag Import
]=]
Color.fromBrickColor = fromAlternative("BrickColor")::(brickColor: BrickColor) -> Color

--[=[
    Exports a Color to a BrickColor

    @function toBrickColor
    @within Color
    @param color Color
    @return BrickColor
    @tag Export
]=]
Color.toBrickColor = toAlternative("BrickColor")::(color: Color) -> BrickColor

--[=[
    Imports a Color from CMYK components, between 0 and 1

    @function fromCMYK
    @within Color
    @param c number
    @param m number
    @param y number
    @param k number
    @return Color
    @tag Import
]=]
Color.fromCMYK = fromAlternative("CMYK")::(c: number, m: number, y: number, k: number) -> Color

--[=[
    Exports a Color to CMYK components, between 0 and 1

    @function toCMYK
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toCMYK = toAlternative("CMYK")::(color: Color) -> (number, number, number, number)

--[=[
    Imports a Color from a Color3

    @function fromColor3
    @within Color
    @param color Color3
    @return Color
    @tag Import
]=]
Color.fromColor3 = fromAlternative("Color3")::(color3: Color3) -> Color

--[=[
    Exports a Color to a Color3

    @function toColor3
    @within Color
    @param color Color
    @return Color
    @tag Export
]=]
Color.toColor3 = toAlternative("Color3")::(color: Color) -> Color3

--[=[
    Imports a Color from a hex string

    @function fromHex
    @within Color
    @param hex string
    @return Color
    @tag Import
]=]
Color.fromHex = fromAlternative("Hex")::(hex: string) -> Color

--[=[
    Exports a Color to a hex string

    @function toHex
    @within Color
    @param color Color
    @return string
    @tag Export
]=]
Color.toHex = toAlternative("Hex")::(color: Color) -> string

--[=[
    Imports a Color from HSB components; check the [argument list](/docs/color-types#hsb-and-hsv)

    @function fromHSB
    @within Color
    @param h number
    @param s number
    @param b number
    @return Color
    @tag Import
]=]
Color.fromHSB = fromAlternative("HSB")::(h: number, s: number, b: number) -> Color

--[=[
    Exports a Color to HSB components; check the [return values](/docs/color-types#hsb-and-hsv)

    @function toHSB
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toHSB = toAlternative("HSB")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from HSL components; check the [argument list](/docs/color-types#hsl)

    @function fromHSL
    @within Color
    @param h number
    @param s number
    @param l number
    @return Color
    @tag Import
]=]
Color.fromHSL = fromAlternative("HSL")::(h: number, s: number, l: number) -> Color

--[=[
    Exports a Color to HSL components; check the [return values](/docs/color-types#hsl)

    @function toHSL
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toHSL = toAlternative("HSL")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from HWB components; check the [argument list](/docs/color-types#hwb)

    @function fromHWB
    @within Color
    @param h number
    @param w number
    @param b number
    @return Color
    @tag Import
]=]
Color.fromHWB = fromAlternative("HWB")::(h: number, w: number, b: number) -> Color

--[=[
    Exports a Color to HWB components; check the [return values](/docs/color-types#hwb)

    @function toHWB
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toHWB = toAlternative("HWB")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from [CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space) components; check the [argument list](/docs/color-types#lab)

    @function fromLab
    @within Color
    @param l number
    @param a number
    @param b number
    @return Color
    @tag Import
]=]
Color.fromLab = fromAlternative("Lab")::(l: number, a: number, b: number) -> Color

--[=[
    Exports a Color to [CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space) components; check the [return values](/docs/color-types#lab)

    @function toLab
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toLab = toAlternative("Lab")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from [cylindrical CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model) components; check the [argument list](/docs/color-types#lchab-and-lch)

    @function fromLChab
    @within Color
    @param l number
    @param c number
    @param h number
    @return Color
    @tag Import
]=]
Color.fromLChab = fromAlternative("LChab")::(l: number, c: number, h: number) -> Color

--[=[
    Exports a Color to [cylindrical CIELAB](https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model) components; check the [return values](/docs/color-types#lchab-and-lch)

    @function toLChab
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toLChab = toAlternative("LChab")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from [cylindrical CIELUV](https://en.wikipedia.org/wiki/CIELUV#Cylindrical_representation_(CIELCh)) components; check the [argument list](/docs/color-types#lchuv)

    @function fromLChuv
    @within Color
    @param l number
    @param c number
    @param h number
    @return Color
    @tag Import
]=]
Color.fromLChuv = fromAlternative("LChuv")::(l: number, c: number, h: number) -> Color

--[=[
    Exports a Color to [cylindrical CIELUV](https://en.wikipedia.org/wiki/CIELUV#Cylindrical_representation_(CIELCh)) components; check the [return values](/docs/color-types#lchuv)

    @function toLChuv
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toLChuv = toAlternative("LChuv")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from [CIELUV](https://en.wikipedia.org/wiki/CIELUV) components; check the [argument list](/docs/color-types#luv)

    @function fromLuv
    @within Color
    @param l number
    @param u number
    @param v number
    @return Color
    @tag Import
]=]
Color.fromLuv = fromAlternative("Luv")::(l: number, u: number, v: number) -> Color

--[=[
    Exports a Color to [CIELUV](https://en.wikipedia.org/wiki/CIELUV) components; check the [return values](/docs/color-types#luv)

    @function toLuv
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toLuv = toAlternative("Luv")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from an integer

    @function fromNumber
    @within Color
    @param n number -- An integer between 0 and 16777215
    @return Color
    @tag Import
]=]
Color.fromNumber = fromAlternative("Number")::(n: number) -> Color

--[=[
    Exports a Color to an integer

    @function toNumber
    @within Color
    @param color Color
    @return number -- An integer between 0 and 16777215
    @tag Export
]=]
Color.toNumber = toAlternative("Number")::(color: Color) -> number

--[=[
    Imports a Color from RGB components in the range [0, 255]

    @function fromRGB
    @within Color
    @param r number
    @param g number
    @param b number
    @return Color
    @tag Import
]=]
Color.fromRGB = fromAlternative("RGB")::(r: number, g: number, b: number) -> Color

--[=[
    Exports a Color to RGB components in the range [0, 255]

    @function toRGB
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toRGB = toAlternative("RGB")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from a blackbody temperature, works best between 1000K and 40000K

    @function fromTemperature
    @within Color
    @param temperature number -- The temperature in Kelvin
    @return Color
    @tag Import
]=]
Color.fromTemperature = fromAlternative("Temperature")::(temperature: number) -> Color

--[=[
    Exports a Color to a blackbody temperature

    @function toTemperature
    @within Color
    @param color Color
    @return number -- The temperature in Kelvin
    @tag Export
]=]
Color.toTemperature = toAlternative("Temperature")::(color: Color) -> number

--[=[
    Imports a Color from normalised XYZ tristimulus values; check the [argument list](/docs/color-types#xyz)

    @function fromXYZ
    @within Color
    @param x number
    @param y number
    @param z number
    @return Color
    @tag Import
]=]
Color.fromXYZ = fromAlternative("XYZ")::(x: number, y: number, z: number) -> Color

--[=[
    Exports a Color to normalised XYZ tristimulus values; check the [return values](/docs/color-types#xyz)

    @function toXYZ
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toXYZ = toAlternative("XYZ")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from normalised HPLuv components; check the [argument list](/docs/color-types#hpluv)

    @function fromHPLuv
    @within Color
    @param h number
    @param p number
    @param l number
    @return Color
    @tag Import
]=]
Color.fromHPLuv = fromAlternative("HPLuv")::(h: number, p: number, l: number) -> Color

--[=[
    Exports a Color to normalised HPLuv components; check the [return values](/docs/color-types#hpluv)

    @function toHPLuv
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toHPLuv = toAlternative("HPLuv")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from normalised HSLuv components; check the [argument list](/docs/color-types#hsluv)

    @function fromHSLuv
    @within Color
    @param h number
    @param s number
    @param l number
    @return Color
    @tag Import
]=]
Color.fromHSLuv = fromAlternative("HSLuv")::(h: number, s: number, l: number) -> Color

--[=[
    Exports a Color to normalised HSLuv components; check the [return values](/docs/color-types#hsluv)

    @function toHSLuv
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toHSLuv = toAlternative("HSLuv")::(color: Color) -> (number, number, number)

--[=[
    Imports a Color from Oklab components; check the [argument list](/docs/color-types#oklab)

    @function fromOklab
    @within Color
    @param l number
    @param a number
    @param b number
    @return Color
    @tag Import
]=]
Color.fromOklab = fromAlternative("Oklab")::(l: number, a: number, b: number) -> Color

--[=[
    Exports a Color to Oklab components; check the [return values](/docs/color-types#oklab)

    @function toOklab
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toOklab = toAlternative("Oklab")::(color: Color) -> (number, number, number)

-- Aliases

--[=[
    Alias for [`Color.fromHSB`](#fromHSB)

    @function fromHSV
    @within Color
    @param h number
    @param s number
    @param v number
    @return Color
    @tag Import
]=]
Color.fromHSV = Color.fromHSB::(h: number, s: number, v: number) -> Color

--[=[
    Alias for [`Color.toHSB`](#toHSB)

    @function toHSV
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toHSV = Color.toHSB

--[=[
    Alias for [`Color.fromLChab`](#fromLChab)

    @function fromLCh
    @within Color
    @param l number
    @param c number
    @param h number
    @return Color
    @tag Import
]=]
Color.fromLCh = Color.fromLChab

--[=[
    Alias for [`Color.toLChab`](#toLChab)

    @function toLCh
    @within Color
    @param color Color
    @return number
    @return number
    @return number
    @tag Export
]=]
Color.toLCh = Color.toLChab

---

return table.freeze(Color)