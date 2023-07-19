--!strict
-- Equations: https://www.w3.org/TR/2015/CR-compositing-1-20150113/#blendingseparable

local root = script.Parent
local Types = require(root.Types)

---

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

local blendingFunctions: {[Types.BlendMode]: (number, number) -> number} = {
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

return function(backgroundColorComponents: {number}, foregroundColorComponents: {number}, blendMode: Types.BlendMode): (number, number, number)
    local blendingFunction: ((number, number) -> number)? = blendingFunctions[blendMode]
    assert(blendingFunction, "invalid blend mode")

    local blend: {number} = {}

    for i = 1, 3 do
        blend[i] = blendingFunction(backgroundColorComponents[i], foregroundColorComponents[i])
    end

    return table.unpack(blend)
end