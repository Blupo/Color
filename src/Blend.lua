--!strict
-- Equations: https://www.w3.org/TR/2015/CR-compositing-1-20150113/#blending

local root = script.Parent
local Types = require(root.Types)

---
-- Separable blending functions

local multiply = function(a: number, b: number): number
    return a * b
end

local screen = function(a: number, b: number): number
    return 1 - ((1 - a) * (1 - b))
end

local hardLight = function(a: number, b: number): number
    if (b <= 1/2) then
        return multiply(a, 2 * b)
    else
        return screen(a, (2 * b) - 1)
    end
end

local separableBlendingFunctions: {[Types.SeparableBlendMode]: (number, number) -> number} = {
    Darken = math.min,
    Lighten = math.max,
    Multiply = multiply,
    Screen = screen,
    HardLight = hardLight,

    Normal = function(_: number, b: number): number
        return b
    end,

    Difference = function(a: number, b: number): number
        return math.abs(a - b)
    end,

    Overlay = function(a: number, b: number): number
        return hardLight(b, a)
    end,
    
    Exclusion = function(a: number, b: number): number
        return a + b - (2 * a * b)
    end,

    ColorDodge = function(a: number, b: number): number
        if (a == 0) then
            return 0
        elseif (b == 1) then
            return 1
        else
            return math.min(1, a / (1 - b))
        end
    end,

    ColorBurn = function(a: number, b: number): number
        if (a == 1) then
            return 1
        elseif (b == 0) then
            return 0
        else
            return 1 - math.min(1, (1 - a) / b)
        end
    end,

    SoftLight = function(a: number, b: number): number
        if (b <= 0.5) then
            return a - ((1 - (2 * b)) * a * (1 - a))
        else
            local c: number

            if (a <= 0.25) then
                c = ((((16 * a) - 12) * a) + 4) * a
            else
                c = math.sqrt(a)
            end

            return a + ((2 * b) - 1) * (c - a)
        end
    end,
}

---
-- Non-separable blending functions

local luminosity = function(r: number, g: number, b: number): number
    return (0.3 * r) + (0.59 * g) + (0.11 * b)
end

local saturation = function(r: number, g: number, b: number): number
    return math.max(r, g, b) - math.min(r, g, b)
end

local clipColor = function(r: number, g: number, b: number): (number, number, number)
    local l: number = luminosity(r, g, b)
    local min: number = math.min(r, g, b)
    local max: number = math.max(r, g, b)

    if (min < 0) then
        r = l + ((r - l) * l / (l - min))
        g = l + ((g - l) * l / (l - min))
        b = l + ((b - l) * l / (l - min))
    end

    if (max > 1) then
        r = l + ((r - l) * (1 - l) / (max - l))
        g = l + ((g - l) * (1 - l) / (max - l))
        b = l + ((b - l) * (1 - l) / (max - l))
    end

    return r, g, b
end

local setLuminosity = function(r: number, g: number, b: number, l: number): (number, number, number)
    local d: number = l - luminosity(r, g, b)

    return clipColor(r + d, g + d, b + d)
end

local setSaturation = function(r: number, g: number, b: number, s: number): (number, number, number)
    local components: {number} = {r, g, b}
    local map: {number} = {1, 2, 3}

    table.sort(map, function(i1: number, i2: number): boolean
        return components[i1] > components[i2]
    end)

    local maxIndex, midIndex, minIndex = table.unpack(map)
    local max, mid, min = components[maxIndex], components[midIndex], components[minIndex]

    if (max > min) then
        components[midIndex] = (mid - min) * s / (max - min)
        components[maxIndex] = s
    else
        components[midIndex] = 0
        components[maxIndex] = 0
    end

    components[minIndex] = 0
    return table.unpack(components)
end

local nonSeparableBlendingFunctions: {[Types.NonSeparableBlendMode]: (number, number, number, number, number, number) -> (number, number, number)} = {
    Hue = function(rA: number, gA: number, bA: number, rB: number, gB: number, bB: number): (number, number, number)
        local r, g, b = setSaturation(rB, gB, bB, saturation(rA, gA, bA))
        local l = luminosity(rA, gA, bA)

        return setLuminosity(r, g, b, l)
    end,

    Saturation = function(rA: number, gA: number, bA: number, rB: number, gB: number, bB: number): (number, number, number)
        local r, g, b = setSaturation(rA, gA, bA, saturation(rB, gB, bB))
        local l = luminosity(rA, gA, bA)

        return setLuminosity(r, g, b, l)
    end,

    Color = function(rA: number, gA: number, bA: number, rB: number, gB: number, bB: number): (number, number, number)
        return setLuminosity(rB, gB, bB, luminosity(rA, gA, bA))
    end,

    Luminosity = function(rA: number, gA: number, bA: number, rB: number, gB: number, bB: number): (number, number, number)
        return setLuminosity(rA, gA, bA, luminosity(rB, gB, bB))
    end,
}

---

return function(backgroundColorComponents: {number}, foregroundColorComponents: {number}, blendMode: Types.BlendMode): (number, number, number)
    if ((blendMode == "Hue") or (blendMode == "Saturation") or (blendMode == "Color") or (blendMode == "Luminosity")) then
        local blendingFunction: ((number, number, number, number, number, number) -> (number, number, number))? = nonSeparableBlendingFunctions[blendMode]
        assert(blendingFunction, "invalid blend mode")

        local bkgR, bkgG, bkgB = table.unpack(backgroundColorComponents)
        local forR, forG, forB = table.unpack(foregroundColorComponents)

        return blendingFunction(bkgR, bkgG, bkgB, forR, forG, forB)
    else
        local blendingFunction: ((number, number) -> number)? = separableBlendingFunctions[blendMode]
        assert(blendingFunction, "invalid blend mode")

        local blend: {number} = {}

        for i = 1, 3 do
            blend[i] = blendingFunction(backgroundColorComponents[i], foregroundColorComponents[i])
        end

        return table.unpack(blend)
    end
end