--!strict

local root = script.Parent
local Types = require(root.Types)

---

local Utils = {}

Utils.Lerp = function(a: number, b: number, t: number): number
    return ((1 - t) * a) + (t * b)
end

--[[
    Equations
        http://www.brucelindbloom.com/Eqn_RGB_to_XYZ.html
        http://www.brucelindbloom.com/Eqn_XYZ_to_RGB.html
]]
Utils.GammaCorrection = {
    toLinear = function(c: number): number
        if (c <= 0.04045) then
            return c / 12.92
        else
            return ((c + 0.055) / 1.055)^2.4
        end
    end,

    toStandard = function(c: number): number
        if (c <= 0.0031308) then
            return 12.92 * c
        else
            return (1.055 * c^(1 / 2.4)) - 0.055
        end
    end
}

Utils.HueLerp = function(h1: number, h2: number, t: number, optionalAdjustment: Types.HueAdjustment?): number
    local adjustment: Types.HueAdjustment = optionalAdjustment or "Shorter"

    if ((h1 ~= h1) and (h2 == h2)) then
        -- h1 is NaN
        h1 = h2
    elseif ((h1 == h1) and (h2 ~= h2)) then
        -- h2 is NaN
        h2 = h1
    elseif ((h1 ~= h1) and (h2 ~= h2)) then
        -- h1 and h2 are NaN
        h1, h2 = 0, 0
    end

    local delta: number = h2 - h1

    if (adjustment == "Shorter") then
        if (delta > 180) then
            h1 += 360
        elseif (delta < -180) then
            h2 += 360
        end
    elseif (adjustment == "Longer") then
        if ((0 < delta) and (delta < 180)) then
            h1 += 360
        elseif ((-180 < delta) and (delta < 0)) then
            h2 += 360
        end
    elseif (adjustment == "Increasing") then
        if (h2 < h1) then
            h2 += 360
        end
    elseif (adjustment == "Decreasing") then
        if (h1 < h2) then
            h1 += 360
        end
    elseif ((adjustment == "Raw") or (adjustment == "Specified")) then
        h1, h2 = h1, h2
    else
        error("invalid hue adjustment")
    end
    
    return Utils.Lerp(h1, h2, t)
end

Utils.Round = function(n: number, optionalE: number?): number
    local e: number = optionalE or 0

    return math.floor((n / 10^e) + 0.5) * 10^e
end

return Utils