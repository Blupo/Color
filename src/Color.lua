--!strict

local root = script.Parent
local t = require(root.t)

local Colors = root.Colors
local Lab = require(Colors.Lab)
local LChab = require(Colors.LChab)

local Utils = root.Utils
local blend = require(Utils.Blend)

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
    HSV = require(Colors.HSB), -- Alias for HSB
    HSL = require(Colors.HSL),
    HWB = require(Colors.HWB),
    Lab = Lab,
    LChab = LChab,
    LCh = LChab, -- Alias for LChab
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
    HSV = require(Interpolators.HSB), -- Alias for HSB
    HSL = require(Interpolators.HSL),
    HWB = require(Interpolators.HWB),
    Lab = require(Interpolators.Lab),
    LChab = require(Interpolators.LChab),
    LCh = require(Interpolators.LChab), -- Alias for LChab
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
    HSV = true,
    HSL = true,
    HWB = true,
    Number = true,
    RGB = true,
    Temperature = true,
}

---

local Color = {}

local colorMetatable = table.freeze({
    __index = Color,

    __eq = function(color1, color2): boolean
        return (color1.R == color2.R) and (color1.G == color2.G) and (color1.B == color2.B)
    end,

    __tostring = function(color): string
        return tonumber(color.R) .. ", " .. tonumber(color.G) .. ", " .. tonumber(color.B)
    end,
})

Color.new = t.wrap(function(r: number, g: number, b: number)
    local clippedR: number, clippedG: number, clippedB: number = math.clamp(r, 0, 1), math.clamp(g, 0, 1), math.clamp(b, 0, 1)

    return table.freeze(setmetatable({
        __r = r,
        __g = g,
        __b = b,

        R = clippedR,
        G = clippedG,
        B = clippedB,
    }, colorMetatable))
end, t.tuple(t.number, t.number, t.number))

Color.random = function(): Color
    return Color.new(math.random(), math.random(), math.random())
end

Color.from = function(colorType: string, ...: any): Color
    local colorTypeModule = colorTypes[colorType]
    assert(colorTypeModule, "invalid color type")

    local r, g, b = colorTypeModule.toRGB(...)
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

Color.components = function(color: Color): (number, number, number)
    return color.R, color.G, color.B
end

Color.to = function(color: Color, colorType: string): ...any
    local colorTypeModule = colorTypes[colorType]
    assert(colorTypeModule, "invalid color type")

    local clip = clippedColorTypes[colorType]

    return colorTypeModule.fromRGB(
        color[clip and "R" or "__r"],
        color[clip and "G" or "__g"],
        color[clip and "B" or "__b"]
    )
end

Color.invert = function(color: Color): Color
    return Color.new(1 - color.__r, 1 - color.__g, 1 - color.__b)
end

Color.mix = function(startColor: Color, endColor: Color, ratio: number, mode: string?, hueAdjustment: string?): Color
    mode = mode or "RGB"

    local interpolator = interpolators[mode]
    assert(interpolator, "invalid interpolator")

    local startColorComponents, endColorComponents

    if ((mode == "RGB") or (mode == "lRGB")) then
        startColorComponents, endColorComponents = { startColor:components() }, { endColor:components() }

        return Color.new(interpolator(startColorComponents, endColorComponents, ratio, hueAdjustment))
    else
        startColorComponents, endColorComponents = { startColor:to(mode) }, { endColor:to(mode) }

        return Color.from(mode, interpolator(startColorComponents, endColorComponents, ratio, hueAdjustment))
    end
end

Color.blend = function(baseColor: Color, topColor: Color, mode: string): Color
    local baseColorComponents = { baseColor:components() }
    local topColorComponents = { topColor:components() }

    return Color.new(blend(baseColorComponents, topColorComponents, mode))
end

-- WCAG definition of relative luminance
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef
Color.luminance = function(color: Color): number
    local r1, g1, b1 = color.R, color.G, color.B

    local r2 = (r1 <= 0.03928) and (r1 / 12.92) or (((r1 + 0.055) / 1.055) ^ 2.4)
    local g2 = (g1 <= 0.03928) and (g1 / 12.92) or (((g1 + 0.055) / 1.055) ^ 2.4)
    local b2 = (b1 <= 0.03928) and (b1 / 12.92) or (((b1 + 0.055) / 1.055) ^ 2.4)

    return (0.2126 * r2) + (0.7152 * g2) + (0.0722 * b2)
end

-- WCAG definition of contrast ratio
-- https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef
Color.contrast = function(refColor: Color, testColor: Color): number
    local refColorLuminance, testColorLuminance = Color.luminance(refColor), Color.luminance(testColor)

    return (refColorLuminance > testColorLuminance) and
        ((refColorLuminance + 0.05) / (testColorLuminance + 0.05))
    or ((testColorLuminance + 0.05) / (refColorLuminance + 0.05))
end

Color.bestContrastingColor = function(refColor: Color, ...: Color): (Color, number)
    local options = {...}
    assert(#options >= 1, "no colors to compare")

    if (#options >= 2) then
        table.sort(options, function(option1, option2)
            local option1ContrastRatio = Color.contrast(refColor, option1)
            local option2ContrastRatio = Color.contrast(refColor, option2)

            return (option1ContrastRatio > option2ContrastRatio)
        end)
    end

    local bestColor = options[1]
    return bestColor, Color.contrast(refColor, bestColor)
end

Color.brighten = function(color: Color, amount: number?): Color
    amount = amount or 1

    local l, a, b = Lab.fromXYZ(Color.to(color, "XYZ"))
    l = l + (amount * 18 / 100)

    return Color.from("XYZ", Lab.toXYZ(l, a, b))
end

Color.darken = function(color: Color, amount: number?): Color
    return Color.brighten(color, -(amount or 1))
end

Color.saturate = function(color: Color, amount: number?): Color
    amount = amount or 1

    local l, c, h = LChab.fromLab(Lab.fromXYZ(Color.to(color, "XYZ")))
    c = c + (amount * 18 / 100)
    c = (c < 0) and 0 or c

    return Color.from("XYZ", Lab.toXYZ(LChab.toLab(l, c, h)))
end

Color.desaturate = function(color: Color, amount: number?): Color
    return Color.saturate(color, -(amount or 1))
end

---

export type Color = typeof(Color.new(0, 0, 0))

return table.freeze(Color)