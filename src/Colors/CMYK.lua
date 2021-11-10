--!strict

local root = script.Parent.Parent
local t = require(root.t)

---

local CMYK = {}

CMYK.fromRGB = function(r: number, g: number, b: number): (number, number, number, number)
    local c: number = 1 - r
    local m: number = 1 - g
    local y: number = 1 - b
    local k: number = math.min(c, m, y)

    c = (k < 1) and ((c - k) / (1 - k)) or 0
    m = (k < 1) and ((m - k) / (1 - k)) or 0
    y = (k < 1) and ((y - k) / (1 - k)) or 0

    return c, m, y, k
end

CMYK.toRGB = t.wrap(function(c: number, m: number, y: number, k: number): (number, number, number)
    return
        (1 - c) * (1 - k),
        (1 - m) * (1 - k),
        (1 - y) * (1 - k)
end, t.tuple(t.number, t.number, t.number, t.number))

return CMYK