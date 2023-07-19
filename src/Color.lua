--!strict

local root = script.Parent

local ColorTypes = require(root.ColorTypes)
local t = require(root.t)
local Types = require(root.Types)
local WebColors = require(root.WebColors)

local Blend = require(root.Blend)
local DeltaE = require(root.DeltaE)
local Utils = require(root.Utils)

---

type ColorStruct = {
    __r: number,
    __g: number,
    __b: number,

    R: number,
    G: number,
    B: number,
}

---

-- These functions are used by the library
assert(ColorTypes.Lab.fromXYZ)
assert(ColorTypes.Lab.toXYZ)
assert(ColorTypes.LChab.fromLab)
assert(ColorTypes.LChab.toLab)

local disallowedColorInterpolations: {[Types.ColorType]: true} = {
    BrickColor = true,
    Color3 = true,
    Hex = true,
    Number = true,
    Temperature = true,
}

local clippedColorTypes: {[Types.ColorType]: true} = {
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

local hueComponentIndices: {[Types.ColorType]: number} = {
    HSB = 1,
    HSL = 1,
    HSV = 1,
    HWB = 1,
    LCh = 3,
    LChab = 3,
    LChuv = 3,
}

local ColorStruct = t.struct({
    __r = t.number,
    __g = t.number,
    __b = t.number,

    R = t.numberBetween(0, 1),
    G = t.numberBetween(0, 1),
    B = t.numberBetween(0, 1)
})

---

local Color = {}

local colorMetatable = {
    __index = Color,

    __eq = function(color1: ColorStruct, color2: ColorStruct): boolean
        local r1: number, g1: number, b1: number = rawget(color1, "R"), rawget(color1, "G"), rawget(color1, "B")
        local r2: number, g2: number, b2: number = rawget(color2, "R"), rawget(color2, "G"), rawget(color2, "B")
    
        return (r1 == r2) and (g1 == g2) and (b1 == b2)
    end,
    
    __tostring = function(color: ColorStruct): string
        local components: {number} = {rawget(color, "R"), rawget(color, "G"), rawget(color, "B")}
    
        return table.concat(components, ", ")
    end
}

local colorCheck = function(value: any): (boolean, string?)
    local isTable, tableError = t.table(value)

    if (not isTable) then
        return false, tableError
    end

    local metatable = getmetatable(value)

    if ((not metatable) or (metatable ~= colorMetatable)) then
        return false, "not a Color"
    end

    return true
end

--[[
    Creates a new Color with normalised RGB components
]]
Color.new = function(r: number, g: number, b: number)
    assert(t.tuple(t.number, t.number, t.number)(r, g, b))

    local clippedR: number = math.clamp(r, 0, 1)
    local clippedG: number = math.clamp(g, 0, 1)
    local clippedB: number = math.clamp(b, 0, 1)

    return table.freeze(setmetatable({
        __r = r,
        __g = g,
        __b = b,

        R = clippedR,
        G = clippedG,
        B = clippedB,
    }, colorMetatable))
end

export type Color = typeof(Color.new(0, 0, 0))

colorMetatable.__add = t.wrap(function(color1: ColorStruct, color2: ColorStruct): Color
    local r1: number, g1: number, b1: number = rawget(color1, "__r"), rawget(color1, "__g"), rawget(color1, "__b")
    local r2: number, g2: number, b2: number = rawget(color2, "__r"), rawget(color2, "__g"), rawget(color2, "__b")

    return Color.new(r1 + r2, g1 + g2, b1 + b2)
end, t.tuple(ColorStruct, ColorStruct))

colorMetatable.__sub = t.wrap(function(color1: ColorStruct, color2: ColorStruct): Color
    local r1: number, g1: number, b1: number = rawget(color1, "__r"), rawget(color1, "__g"), rawget(color1, "__b")
    local r2: number, g2: number, b2: number = rawget(color2, "__r"), rawget(color2, "__g"), rawget(color2, "__b")
    
    return Color.new(r1 - r2, g1 - g2, b1 - b2)
end, t.tuple(ColorStruct, ColorStruct))

colorMetatable.__mul = t.wrap(function(color1: ColorStruct | number, color2: ColorStruct | number): Color
    if ((typeof(color1) == "number") and (typeof(color2) ~= "number")) then
        -- number, Color
        local r: number, g: number, b: number = rawget(color2, "__r"), rawget(color2, "__g"), rawget(color2, "__b")
        
        return Color.new(r * color1, g * color1, b * color1)
    elseif ((typeof(color1) ~= "number") and (typeof(color2) == "number")) then
        -- Color, number
        local r: number, g: number, b: number = rawget(color1, "__r"), rawget(color1, "__g"), rawget(color1, "__b")
        
        return Color.new(r * color2, g * color2, b * color2)
    elseif ((typeof(color1) ~= "number") and (typeof(color2) ~= "number")) then
        -- Color, Color
        local r1: number, g1: number, b1: number = rawget(color1, "__r"), rawget(color1, "__g"), rawget(color1, "__b")
        local r2: number, g2: number, b2: number = rawget(color2, "__r"), rawget(color2, "__g"), rawget(color2, "__b")

        return Color.new(r1 * r2, g1 * g2, b1 * b2)
    end

    error("cannot multiply types")
end, t.tuple(t.union(ColorStruct, t.number), t.union(ColorStruct, t.number)))

colorMetatable.__div = t.wrap(function(color1: ColorStruct | number, color2: ColorStruct | number): Color
    if ((typeof(color1) == "number") and (typeof(color2) ~= "number")) then
        -- number, Color
        local r: number, g: number, b: number = rawget(color2, "__r"), rawget(color2, "__g"), rawget(color2, "__b")
        
        return Color.new(r / color1, g / color1, b / color1)
    elseif ((typeof(color1) ~= "number") and (typeof(color2) == "number")) then
        -- Color, number
        local r: number, g: number, b: number = rawget(color1, "__r"), rawget(color1, "__g"), rawget(color1, "__b")
        
        return Color.new(r / color2, g / color2, b / color2)
    elseif ((typeof(color1) ~= "number") and (typeof(color2) ~= "number")) then
        -- Color, Color
        local r1: number, g1: number, b1: number = rawget(color1, "__r"), rawget(color1, "__g"), rawget(color1, "__b")
        local r2: number, g2: number, b2: number = rawget(color2, "__r"), rawget(color2, "__g"), rawget(color2, "__b")

        return Color.new(r1 / r2, g1 / g2, b1 / b2)
    end

    error("cannot divide types")
end, t.tuple(t.union(ColorStruct, t.number), t.union(ColorStruct, t.number)))

table.freeze(colorMetatable)

---

--[[
    Creates a Color with all components being 0
]]
Color.zero = function(): Color
    return Color.new(0, 0, 0)
end

--[[
    Creates a Color with all components being 1
]]
Color.one = function(): Color
    return Color.new(1, 1, 1)
end

--[[
    Creates a Color with random components
]]
Color.random = function(): Color
    local rng = Random.new(os.time())

    return Color.new(rng:NextNumber(), rng:NextNumber(), rng:NextNumber())
end

--[[
    Creates a Color with all components being the same number

    @param scale The amount of grey, with 0 being black and 1 being white
]]
Color.gray = t.wrap(function(scale: number): Color
    return Color.new(scale, scale, scale)
end, t.numberBetween(0, 1))

--[[
    Creates a Color from one of the color keywords
    specified in CSS Color Module Level 3
]]
Color.named = t.wrap(function(name: string): Color
    local hex: string = WebColors[string.lower(name)]
    assert(hex, "invalid name")

    return Color.new(ColorTypes.Hex.toRGB(hex))
end, t.string)

--[[
    Creates a Color from one of several color types
]]
Color.from = t.wrap(function(colorType: Types.ColorType, ...: any): Color
    local colorInterface: Types.ColorInterface = ColorTypes[colorType]
    assert(colorInterface, "unknown color interface")

    local r: number, g: number, b: number = colorInterface.toRGB(...)
    assert(r and g and b, "invalid components")

    return Color.new(r, g, b)
end, Types.Runtime.ColorType)

--[[
    Checks if a value is a Color
]]
Color.isAColor = function(value: any): (boolean, string?)
    return colorCheck(value)
end

--[[
    Checks if a Color's components are clipped
]]
Color.isClipped = t.wrap(function(color: Color): boolean
    return (color.__r ~= color.R) or (color.__g ~= color.G) or (color.__b ~= color.B)
end, colorCheck)

--[[
    Compares the *unclipped* components of two Colors
]]
Color.unclippedEq = t.wrap(function(refColor: Color, testColor: Color): boolean
    return (refColor.__r == testColor.__r) and (refColor.__g == testColor.__g) and (refColor.__b == testColor.__b)
end, t.tuple(colorCheck, colorCheck))

--[[
    Returns the components of a Color as a tuple
]]
Color.components = t.wrap(function(color: Color, unclipped: boolean?): (number, number, number)
    if (unclipped) then
        return color.__r, color.__g, color.__b
    else
        return color.R, color.G, color.B
    end
end, t.tuple(colorCheck, t.optional(t.boolean)))

--[[
    Converts the Color into a different color type
]]
Color.to = t.wrap(function(color: Color, colorType: Types.ColorType): ...any
    local colorInterface: Types.ColorInterface? = ColorTypes[colorType]
    assert(colorInterface, "unknown color interface")

    local clipComponents: boolean? = clippedColorTypes[colorType]
    return colorInterface.fromRGB(Color.components(color, not clipComponents))
end, t.tuple(colorCheck, Types.Runtime.ColorType))

--[[
    Returns a Color with inverted components
]]
Color.invert = t.wrap(function(color: Color): Color
    return Color.new(1 - color.__r, 1 - color.__g, 1 - color.__b)
end, colorCheck)

--[[
    Returns a Color that is a mix between two other Colors

    @param startColor The beginning color
    @param endColor The ending color
    @param ratio How mixed the two colors are between 0 and 1, with 0 being the start color, 1 being the end color, and 0.5 being an equal mix
    @param colorType? The color type to mix with
    @param hueAdjustment? The hue adjustment method when mixing with color types that have a hue component
]]
Color.mix = t.wrap(function(startColor: Color, endColor: Color, ratio: number, optionalColorType: Types.ColorType?, optionalHueAdjustment: Types.HueAdjustment?): Color
    local colorType: Types.ColorType = optionalColorType or "RGB"
    assert(ColorTypes[colorType] and (not disallowedColorInterpolations[colorType]), "invalid interpolation " .. colorType)

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
end, t.tuple(colorCheck, colorCheck, t.numberBetween(0, 1), t.optional(Types.Runtime.ColorType), t.optional(Types.Runtime.HueAdjustment)))

--[[
    Returns a Color that is a composite blend between of two Colors

    @param backgroundColor The color in the background
    @param foregroundColor The color in the foreground
    @param blendMode The method of blending
]]
Color.blend = t.wrap(function(backgroundColor: Color, foregroundColor: Color, blendMode: Types.BlendMode): Color
    local backgroundColorComponents: {number} = { Color.components(backgroundColor) }
    local foregroundColorComponents: {number} = { Color.components(foregroundColor) }

    return Color.new(Blend(backgroundColorComponents, foregroundColorComponents, blendMode))
end, t.tuple(colorCheck, colorCheck, t.optional(Types.Runtime.BlendMode)))

--[[
    Returns the DeltaE of two Colors

    @param refColor The Color being compared to
    @param testColor The Color being compared
    @param kL Weight factor, default 1
    @param kC Weight factor, default 1
    @param kH Weight factor, default 1
]]
Color.deltaE = t.wrap(function(refColor: Color, testColor: Color, kL: number?, kC: number?, kH: number?): number
    local refColorComponents: {number} = { Color.to(refColor, "Lab") }
    local testColorComponents: {number} = { Color.to(testColor, "Lab") }

    return DeltaE(refColorComponents, testColorComponents, kL, kC, kH)
end, t.tuple(colorCheck, colorCheck, t.optional(t.numberPositive), t.optional(t.numberPositive), t.optional(t.numberPositive)))

-- WCAG definition of relative luminance
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
-- Errata: https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187
--[[
    Returns the relative luminance of a Color between 0 and 1
]]
Color.luminance = t.wrap(function(color: Color): number
    local rgb: {number} = { Color.components(color) }

    return
        (0.2126 * Utils.GammaCorrection.toLinear(rgb[1])) +
        (0.7152 * Utils.GammaCorrection.toLinear(rgb[2])) +
        (0.0722 * Utils.GammaCorrection.toLinear(rgb[3]))
end, colorCheck)

-- WCAG definition of contrast ratio
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
--[[
    Returns the contrast ratio between two Colors

    @return The constrast ratio, between 1 and 21
]]
Color.contrast = t.wrap(function(refColor: Color, testColor: Color): number
    local refColorLuminance: number = Color.luminance(refColor)
    local testColorLuminance: number = Color.luminance(testColor)

    return if (refColorLuminance > testColorLuminance) then
        ((refColorLuminance + 0.05) / (testColorLuminance + 0.05))
    else ((testColorLuminance + 0.05) / (refColorLuminance + 0.05))
end, t.tuple(colorCheck, colorCheck))

--[[
    Returns the Color with the highest constrast ratio with the reference Color

    @param refColor The Color being compared to
    @param ... The Colors being compared
    @return The best-contrasting Color
    @return The contrast ratio of said Color
]]
Color.bestContrastingColor = function(refColor: Color, ...: Color): (Color, number)
    local options: {Color} = {...}
    assert(t.array(colorCheck)(options))
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
Color.brighten = t.wrap(function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, a: number, b: number = ColorTypes.Lab.fromXYZ(Color.to(color, "XYZ"))
    l = l + (amount * 0.18)

    return Color.from("XYZ", ColorTypes.Lab.toXYZ(l, a, b))
end, t.tuple(colorCheck, t.optional(t.number)))

--[[
    Returns a darkened Color using L*a*b*\
    Equivalent to `Color.brighten(Color, -amount)`

    @param color
    @param amount? The amount to darken, default 1 unit (1 unit = 18 L\*)
]]
Color.darken = t.wrap(function(color: Color, amount: number?): Color
    return Color.brighten(color, -(amount or 1))
end, t.tuple(colorCheck, t.optional(t.number)))

--[[
    Returns a more-saturated Color using L\*C\*h

    @param color
    @param amount? The amount to saturate, default 1 unit (1 unit = 18 C\*)
]]
Color.saturate = t.wrap(function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, c: number, h: number = ColorTypes.LChab.fromLab(ColorTypes.Lab.fromXYZ(Color.to(color, "XYZ")))
    c = c + (amount * 0.18)
    c = (c < 0) and 0 or c

    return Color.from("XYZ", ColorTypes.Lab.toXYZ(ColorTypes.LChab.toLab(l, c, h)))
end, t.tuple(colorCheck, t.optional(t.number)))

--[[
    Returns a desaturated Color using L\*C\*h\
    Equivalent to `Color.saturate(color, -amount)`

    @param color
    @param amount? The amount to saturate, default 1 unit (1 unit = 18 C\*)
]]
Color.desaturate = t.wrap(function(color: Color, amount: number?): Color
    return Color.saturate(color, -(amount or 1))
end, t.tuple(colorCheck, t.optional(t.number)))

--[[
    Returns a list of Colors that are harmonies of another

    @param color
    @param harmony The color harmony
    @param analogyAngle? The angle in degrees to separate hues when using analogous harmonies
    @return An array of Colors, sorted by absolute hue distance from the original Color
]]
Color.harmonies = t.wrap(function(color: Color, harmony: Types.Harmony, optionalAnalogyAngle: number?): {Color}
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
    end

    return harmonies
end, t.tuple(colorCheck, Types.Runtime.Harmony, t.optional(t.numberPositive)))

---

local fromAlternative = function(colorType: Types.ColorType): (...any) -> Color
    assert(ColorTypes[colorType], "invalid color type")

    return function(...: any): Color
        return Color.from(colorType, ...)
    end
end

local toAlternative = function(colorType: Types.ColorType): (color: Color) -> ...any
    assert(ColorTypes[colorType], "invalid color type")

    return t.wrap(function(color: Color): ...any
        return Color.to(color, colorType)
    end, colorCheck)
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