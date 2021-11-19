--!strict

local root = script.Parent
local t = require(root.t)

local Colors = root.Colors
local Lab = require(Colors.Lab)
local LChab = require(Colors.LChab)

local Utils = root.Utils
local deltaE = require(Utils.DeltaE)
local blend = require(Utils.Blend)
local GammaCorrection = require(Utils.GammaCorrection)

local Interpolators = root.Interpolators

---

type dictionary<T> = {[string]: T}
type Interpolator = ({number}, {number}, number, string?) -> ...any

type ColorModule = {
    fromRGB: (number, number, number) -> ...any,
    toRGB: (...any) -> (number, number, number),

    -- Lab/Luv
    fromXYZ: ((number, number, number) -> ...any)?,
    toXYZ: ((...any) -> (number, number, number))?,

    -- LChab
    fromLab: ((number, number, number) -> ...any)?,
    toLab: ((...any) -> (number, number, number))?,

    -- LChuv
    fromLuv: ((number, number, number) -> ...any)?,
    toLuv: ((...any) -> (number, number, number))?,

    -- XYZ
    Constants: dictionary<number>?
}

local colorTypes: dictionary<ColorModule> = {
    BrickColor = require(Colors.BrickColor),
    CMYK = require(Colors.CMYK),
    Color3 = require(Colors.Color3),
    Hex = require(Colors.Hex),
    HSB = require(Colors.HSB),
    HSL = require(Colors.HSL),
    HWB = require(Colors.HWB),
    Lab = Lab,
    LChab = LChab,
    LChuv = require(Colors.LChuv),
    Luv = require(Colors.Luv),
    Number = require(Colors.Number),
    RGB = require(Colors.RGB),
    Temperature = require(Colors.Temperature),
    XYZ = require(Colors.XYZ),
}

local interpolators: dictionary<Interpolator> = {
    CMYK = require(Interpolators.CMYK),
    HSB = require(Interpolators.HSB),
    HSL = require(Interpolators.HSL),
    HWB = require(Interpolators.HWB),
    Lab = require(Interpolators.Lab),
    LChab = require(Interpolators.LChab),
    LChuv = require(Interpolators.LChuv),
    Luv = require(Interpolators.Luv),
    lRGB = require(Interpolators.lRGB),
    RGB = require(Interpolators.RGB),
    XYZ = require(Interpolators.XYZ),
}

local clippedColorTypes: dictionary<boolean> = {
    BrickColor = true,
    CMYK = true,
    Color3 = true,
    Hex = true,
    HSB = true,
    HSL = true,
    HWB = true,
    Number = true,
    RGB = true,
    Temperature = true,
}

colorTypes.HSV = colorTypes.HSB
colorTypes.LCh = colorTypes.LChab

interpolators.HSV = interpolators.HSB
interpolators.LCh = interpolators.LChab

clippedColorTypes.HSV = clippedColorTypes.HSB

---

local Color = {}

local colorMetatable = table.freeze({
    __index = Color,

    __eq = function(color1, color2): boolean
        return (color1.R == color2.R) and (color1.G == color2.G) and (color1.B == color2.B)
    end,

    __tostring = function(color): string
        return tostring(color.R) .. ", " .. tostring(color.G) .. ", " .. tostring(color.B)
    end,
})

Color.new = t.wrap(function(r: number, g: number, b: number)
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
end, t.tuple(t.number, t.number, t.number))

---

export type Color = typeof(Color.new(0, 0, 0))

Color.random = function(): Color
    return Color.new(math.random(), math.random(), math.random())
end

Color.gray = function(scale: number): Color
    return Color.new(scale, scale, scale)
end

Color.from = function(colorType: string, ...: any): Color
    local colorTypeModule: ColorModule? = colorTypes[colorType]
    assert(colorTypeModule, "invalid color type")

    local r: number, g: number, b: number = colorTypeModule.toRGB(...)
    assert(r and g and b, "invalid components")

    return Color.new(r, g, b)
end

Color.isAColor = function(color: any): boolean
    if (type(color) ~= "table") then return false end
    if (not table.isfrozen(color)) then return false end

    for key in pairs(Color) do
        if (type(color[key]) ~= "function") then
            return false
        end
    end

    return true
end

Color.isClipped = function(color: Color): boolean
    return (color.__r ~= color.R) or (color.__g ~= color.G) or (color.__b ~= color.B)
end

Color.unclippedEq = function(refColor: Color, testColor: Color): boolean
    return (refColor.__r == testColor.__r) and (refColor.__g == testColor.__g) and (refColor.__b == testColor.__b)
end

Color.components = function(color: Color, unclipped: boolean?): (number, number, number)
    if (unclipped) then
        return color.__r, color.__g, color.__b
    else
        return color.R, color.G, color.B
    end
end

Color.deltaE = function(refColor: Color, testColor: Color, kL: number?, kC: number?, kH: number?): number
    local refColorComponents: {number} = { Color.to(refColor, "Lab") }
    local testColorComponents: {number} = { Color.to(testColor, "Lab") }

    return deltaE(refColorComponents, testColorComponents, kL, kC, kH)
end

Color.to = function(color: Color, colorType: string): ...any
    local colorTypeModule: ColorModule? = colorTypes[colorType]
    assert(colorTypeModule, "invalid color type")

    local clip: boolean = clippedColorTypes[colorType]

    return colorTypeModule.fromRGB(
        color[clip and "R" or "__r"],
        color[clip and "G" or "__g"],
        color[clip and "B" or "__b"]
    )
end

Color.invert = function(color: Color): Color
    return Color.new(1 - color.__r, 1 - color.__g, 1 - color.__b)
end

Color.mix = function(startColor: Color, endColor: Color, ratio: number, optionalMode: string?, optionalHueAdjustment: string?): Color
    local mode: string = optionalMode or "RGB"

    local interpolator: Interpolator? = interpolators[mode]
    assert(interpolator, "invalid interpolator")

    local startColorComponents: {number}, endColorComponents: {number}

    if ((mode == "RGB") or (mode == "lRGB")) then
        startColorComponents, endColorComponents = { startColor:components() }, { endColor:components() }

        return Color.new(interpolator(startColorComponents, endColorComponents, ratio, optionalHueAdjustment))
    else
        startColorComponents, endColorComponents = { startColor:to(mode) }, { endColor:to(mode) }

        return Color.from(mode, interpolator(startColorComponents, endColorComponents, ratio, optionalHueAdjustment))
    end
end

Color.blend = function(baseColor: Color, topColor: Color, mode: string): Color
    local baseColorComponents: {number} = { baseColor:components() }
    local topColorComponents: {number} = { topColor:components() }

    return Color.new(blend(baseColorComponents, topColorComponents, mode))
end

-- WCAG definition of relative luminance
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
-- Errata: https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187
Color.luminance = function(color: Color): number
    local rgb: {number} = { color:components() }

    return
        (0.2126 * GammaCorrection.toLinear(rgb[1])) +
        (0.7152 * GammaCorrection.toLinear(rgb[2])) +
        (0.0722 * GammaCorrection.toLinear(rgb[3]))
end

-- WCAG definition of contrast ratio
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
Color.contrast = function(refColor: Color, testColor: Color): number
    local refColorLuminance: number = Color.luminance(refColor)
    local testColorLuminance: number = Color.luminance(testColor)

    return (refColorLuminance > testColorLuminance) and
        ((refColorLuminance + 0.05) / (testColorLuminance + 0.05))
    or ((testColorLuminance + 0.05) / (refColorLuminance + 0.05))
end

Color.bestContrastingColor = function(refColor: Color, ...: Color): (Color, number)
    local options: {Color} = {...}
    assert(#options >= 1, "no colors to compare")

    if (#options >= 2) then
        table.sort(options, function(option1, option2)
            local option1ContrastRatio = Color.contrast(refColor, option1)
            local option2ContrastRatio = Color.contrast(refColor, option2)

            return (option1ContrastRatio > option2ContrastRatio)
        end)
    end

    local bestColor: Color = options[1]
    return bestColor, Color.contrast(refColor, bestColor)
end

Color.brighten = function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, a: number, b: number = Lab.fromXYZ(Color.to(color, "XYZ"))
    l = l + (amount * 18 / 100)

    return Color.from("XYZ", Lab.toXYZ(l, a, b))
end

Color.darken = function(color: Color, amount: number?): Color
    return Color.brighten(color, -(amount or 1))
end

Color.saturate = function(color: Color, optionalAmount: number?): Color
    local amount: number = optionalAmount or 1

    local l: number, c: number, h: number = LChab.fromLab(Lab.fromXYZ(Color.to(color, "XYZ")))
    c = c + (amount * 18 / 100)
    c = (c < 0) and 0 or c

    return Color.from("XYZ", Lab.toXYZ(LChab.toLab(l, c, h)))
end

Color.desaturate = function(color: Color, amount: number?): Color
    return Color.saturate(color, -(amount or 1))
end

Color.harmonies = function(color: Color, harmony: string, optionalAnalogyAngle: number?): {Color}
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

local fromAlternative = function(colorType: string): (...any) -> Color
    local colorTypeModule: ColorModule? = colorTypes[colorType]
    assert(colorTypeModule, "invalid color type")

    return function(...: any): Color
        return Color.from(colorType, ...)
    end
end

local toAlternative = function(colorType: string): (color: Color) -> ...any
    local colorTypeModule: ColorModule? = colorTypes[colorType]
    assert(colorTypeModule, "invalid color type")

    return function(color: Color): ...any
        return Color.to(color, colorType)
    end
end

Color.fromBrickColor, Color.toBrickColor = fromAlternative("BrickColor"), toAlternative("BrickColor")
Color.fromCMYK, Color.toCMYK = fromAlternative("CMYK"), toAlternative("CMYK")
Color.fromColor3, Color.toColor3 = fromAlternative("Color3"), toAlternative("Color3")
Color.fromHex, Color.toHex = fromAlternative("Hex"), toAlternative("Hex")
Color.fromHSB, Color.toHSB = fromAlternative("HSB"), toAlternative("HSB")
Color.fromHSL, Color.toHSL = fromAlternative("HSL"), toAlternative("HSL")
Color.fromHWB, Color.toHWB = fromAlternative("HWB"), toAlternative("HWB")
Color.fromLab, Color.toLab = fromAlternative("Lab"), toAlternative("Lab")
Color.fromLChab, Color.toLChab = fromAlternative("LChab"), toAlternative("LChab")
Color.fromLChuv, Color.toLChuv = fromAlternative("LChuv"), toAlternative("LChuv")
Color.fromLuv, Color.toLuv = fromAlternative("Luv"), toAlternative("Luv")
Color.fromNumber, Color.toNumber = fromAlternative("Number"), toAlternative("Number")
Color.fromRGB, Color.toRGB = fromAlternative("RGB"), toAlternative("RGB")
Color.fromTemperature, Color.toTemperature = fromAlternative("Temperature"), toAlternative("Temperature")
Color.fromXYZ, Color.toXYZ = fromAlternative("XYZ"), toAlternative("XYZ")

Color.fromHSV, Color.toHSV = Color.fromHSB, Color.toHSB
Color.fromLCh, Color.toLCh = Color.fromLChab, Color.toLChab

return table.freeze(Color)