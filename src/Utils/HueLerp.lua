--!strict

local Utils = script.Parent
local lerp = require(Utils.Lerp)

---

--[[
    h1 [0, 360)
    h2 [0, 360)
]]

return function(h1: number, h2: number, t: number, optionalAdjustment: string?): number
    local adjustment = optionalAdjustment or "Shorter"

    if ((h1 ~= h1) and (h2 == h2)) then
        h1 = h2
    elseif ((h1 == h1) and (h2 ~= h2)) then
        h2 = h1
    elseif ((h1 ~= h1) and (h2 ~= h2)) then
        h1, h2 = 0, 0
    end

    local delta: number = h2 - h1

    if (adjustment == "Shorter") then
        if (delta > 180) then
            h1 = h1 + 360
        elseif (delta < -180) then
            h2 = h2 + 360
        end
    elseif (adjustment == "Longer") then
        if ((0 < delta) and (delta < 180)) then
            h1 = h1 + 360
        elseif ((-180 < delta) and (delta < 0)) then
            h2 = h2 + 360
        end
    elseif (adjustment == "Increasing") then
        if (h2 < h1) then
            h2 = h2 + 360
        end
    elseif (adjustment == "Decreasing") then
        if (h1 < h2) then
            h1 = h1 + 360
        end
    elseif (adjustment == "Raw") then
        h1, h2 = h1, h2
    else
        error("invalid hue adjustment")
    end
    
    return lerp(h1, h2, t)
end