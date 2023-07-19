--!strict

local root = script.Parent
local Utils = require(root.Utils)

---

--[[
    Equations
        DOI: 10.1002/col.20070
        Also available at http://www2.ece.rochester.edu/~gsharma/ciede2000/ciede2000noteCRNA.pdf
]]

return function(refColorLab: {number}, testColorLab: {number}, optionalKl: number?, optionalKc: number?, optionalKh: number?): number
    local kl: number = optionalKl or 1
    local kc: number = optionalKc or 1
    local kh: number = optionalKh or 1

    local l1: number, a1: number, b1: number = refColorLab[1] * 100, refColorLab[2] * 100, refColorLab[3] * 100
    local l2: number, a2: number, b2: number = testColorLab[1] * 100, testColorLab[2] * 100, testColorLab[3] * 100

    local c1: number = math.sqrt(a1^2 + b1^2)
    local c2: number = math.sqrt(a2^2 + b2^2)
    local cb: number = (c1 + c2) / 2

    local g: number = (1 - math.sqrt(cb^7 / (cb^7 + 25^7))) / 2

    local a1p: number = a1 * (1 + g)
    local a2p: number = a2 * (1 + g)

    local c1p: number = math.sqrt(a1p^2 + b1^2)
    local c2p: number = math.sqrt(a2p^2 + b2^2)

    local h1p: number = math.deg(math.atan2(b1, a1p)) % 360
    local h2p: number = math.deg(math.atan2(b2, a2p)) % 360

    -- Remove rounding errors when calculating dhp and hbp
    local dha: number = Utils.Round(math.abs(h1p - h2p), -8)
    local dhb: number = Utils.Round(math.abs(h2p - h1p), -8)
    local dhc: number = Utils.Round(h2p - h1p, -8)
    local dhd: number = Utils.Round(h1p + h2p, -8)

    local dLp: number = l2 - l1
    local dCp: number = c2p - c1p
    local dHp: number
    local dhp: number

    if ((c1p * c2p) == 0) then
        dhp = 0
    elseif (dhb <= 180) then
        dhp = h2p - h1p
    elseif (dhc > 180) then
        dhp = h2p - h1p - 360
    elseif (dhc < -180) then
        dhp = h2p - h1p + 360
    end

    dHp = 2 * math.sin(math.rad(dhp / 2)) * math.sqrt(c1p * c2p)

    local lbp: number = (l1 + l2) / 2
    local cbp: number = (c1p + c2p) / 2
    local hbp: number

    if ((c1p * c2p) == 0) then
        hbp = h1p + h2p
    elseif (dha <= 180) then
        hbp = (h1p + h2p) / 2
    elseif ((dha > 180) and (dhd < 360)) then
        hbp = (h1p + h2p + 360) / 2
    elseif ((dha > 180) and (dhd >= 360)) then
        hbp = (h1p + h2p - 360) / 2
    end

    local t: number = 1
        - (0.17 * math.cos(math.rad(hbp - 30)))
        + (0.24 * math.cos(math.rad(2 * hbp)))
        + (0.32 * math.cos(math.rad((3 * hbp) + 6)))
        - (0.20 * math.cos(math.rad((4 * hbp) - 63)))

    local dt: number = 30 * math.exp(-((hbp - 275) / 25)^2)
    local rc: number = 2 * math.sqrt(cbp^7 / (cbp^7 + 25^7))

    local sl: number = 1 + ((0.015 * (lbp - 50)^2) / math.sqrt(20 + (lbp - 50)^2))
    local sc: number = 1 + (0.045 * cbp)
    local sh: number = 1 + (0.015 * cbp * t)
    local rt: number = rc * -math.sin(math.rad(2 * dt))

    return math.sqrt(
        (dLp / (kl * sl))^2 +
        (dCp / (kc * sc))^2 +
        (dHp / (kh * sh))^2 +
        (rt * (dCp / (kc * sc)) * (dHp / (kh * sh)))
    )
end