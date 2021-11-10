--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Colors = root.Colors
local Number = require(Colors.Number)

local Utils = root.Utils
local round = require(Utils.Round)

---

local Hex = {}

Hex.fromRGB = function(r: number, g: number, b: number): string
    r, g, b = round(r * 255), round(g * 255), round(b * 255)

    return string.format("%02x%02x%02x", r, g, b)
end

Hex.toRGB = t.wrap(function(hex: string): (number, number, number)
    local hexContent: string? = string.match(hex, "#?(.+)")
    assert(hexContent, "hex string is empty")

    local hexLength: number = #hexContent
    assert((hexLength == 3) or (hexLength == 6), "invalid hex length")

    if (hexLength == 3) then
        local r: string?, g: string?, b: string? = string.match(hexContent, "(.)(.)(.)")
        assert(r and g and b, "unexpected empty string")

        hexContent = r .. r .. g .. g .. b .. b
    end

    local number: number? = tonumber(hexContent, 16)
    assert(number, "could not parse hex string")

    return Number.toRGB(number)
end, t.string)

return Hex