--!strict

--[[
    Equations

        http://www.brucelindbloom.com/Eqn_RGB_to_XYZ.html
        http://www.brucelindbloom.com/Eqn_XYZ_to_RGB.html
]]

return {
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
    end,
}