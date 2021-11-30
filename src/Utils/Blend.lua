--!strict

-- Equations: https://www.w3.org/TR/2015/CR-compositing-1-20150113/#blendingseparable
local blendingFunctions: {[string]: (number, number) -> number} = {
    Normal = function(_: number, b: number): number
        return b
    end,

    Multiply = function(a: number, b: number): number
        return a * b
    end,

    Screen = function(a: number, b: number): number
        return 1 - ((1 - a) * (1 - b))
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

    Difference = function(a: number, b: number): number
        return math.abs(a - b)
    end,
    
    Exclusion = function(a: number, b: number): number
        return a + b - (2 * a * b)
    end,
    
    Darken = math.min,
    Lighten = math.max,
}

blendingFunctions.HardLight = function(a: number, b: number): number
    if (b <= 1/2) then
        return blendingFunctions.Multiply(a, 2 * b)
    else
        return blendingFunctions.Screen(a, (2 * b) - 1)
    end
end

blendingFunctions.Overlay = function(a: number, b: number): number
    return blendingFunctions.HardLight(b, a)
end

---

return function(backgroundColorComponents: {number}, foregroundColorComponents: {number}, blendMode: string): (number, number, number)
    local blendingFunction: ((number, number) -> number)? = blendingFunctions[blendMode]
    assert(blendingFunction, "invalid blend mode")

    local blend: {number} = {}

    for i = 1, 3 do
        blend[i] = blendingFunction(backgroundColorComponents[i], foregroundColorComponents[i])
    end

    return table.unpack(blend)
end