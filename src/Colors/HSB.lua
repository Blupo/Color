--!strict

local root = script.Parent.Parent
local t = require(root.t)

---

-- Equations: https://doi.org/10.1145/965139.807361

local HSB = {}

HSB.fromRGB = function(r: number, g: number, b: number): (number, number, number)
    local br = math.max(r, g, b)
    local x = math.min(r, g, b)
    local s = (br ~= 0) and ((br - x) / br) or 0

    local h
    local rp = (br - r) / (br - x)
    local gp = (br - g) / (br - x)
    local bp = (br - b) / (br - x)

    if (r == br) then
        h = (g == x) and (5 + bp) or (1 - gp)
    elseif (g == br) then
        h = (b == x) and (1 + rp) or (3 - bp)
    else
        h = (r == x) and (3 + gp) or (5 - rp)
    end

    return h * 60, s, br
end

HSB.toRGB = t.wrap(function(h: number, s: number, b: number): (number, number, number)
    if (s == 0) then
        return b, b, b
    else
        h = (h % 360) / 60

        local i = math.floor(h)
        local f = h - i

        local m = b * (1 - s)
        local n = b * (1 - (s * f))
        local k = b * (1 - (s * (1 - f)))

        if (i == 0) then
            return b, k, m
        elseif (i == 1) then
            return n, b, m
        elseif (i == 2) then
            return m, b, k
        elseif (i == 3) then
            return m, n, b
        elseif (i == 4) then
            return k, m, b
        elseif (i == 5) then
            return b, m, n
        else
            -- throw an error instead?
            return 0, 0, 0
        end
    end
end, t.tuple(t.union(t.number, t.nan), t.number, t.number))

return HSB