--!strict

local root = script.Parent
local t = require(root.t)
local Types = require(root.Types)

local Utils = require(root.Utils)
local Round = Utils.Round

---

-- D65 tristimulus values
local D65 = {
    X = 95.04,
    Y = 100,
    Z = 108.88,
}

-- XYZ constants
local ep = 216/24389
local ka = 24389/27

---

local ColorTypes: {[string]: Types.ColorInterface} = {}

ColorTypes.BrickColor = {
    fromRGB = function(r: number, g: number, b: number): BrickColor
        return BrickColor.new(Color3.new(r, g, b))
    end,

    toRGB = t.wrap(function(brickColor: BrickColor): (number, number, number)
        local color = brickColor.Color

        return color.R, color.G, color.B
    end, t.BrickColor)::(BrickColor) -> (number, number, number),
}

ColorTypes.CMYK = {
    fromRGB = function(r: number, g: number, b: number): (number, number, number, number)
        local c: number = 1 - r
        local m: number = 1 - g
        local y: number = 1 - b
        local k: number = math.min(c, m, y)
    
        c = (k < 1) and ((c - k) / (1 - k)) or 0
        m = (k < 1) and ((m - k) / (1 - k)) or 0
        y = (k < 1) and ((y - k) / (1 - k)) or 0
    
        return c, m, y, k
    end,

    toRGB = t.wrap(function(c: number, m: number, y: number, k: number): (number, number, number)
        return
            (1 - c) * (1 - k),
            (1 - m) * (1 - k),
            (1 - y) * (1 - k)
    end, t.tuple(t.numberBetween(0, 1), t.numberBetween(0, 1), t.numberBetween(0, 1), t.numberBetween(0, 1)))::(number, number, number, number) -> (number, number, number),
}

ColorTypes.Color3 = {
    fromRGB = function(r: number, g: number, b: number): Color3
        return Color3.new(r, g, b)
    end,

    toRGB = t.wrap(function(color: Color3): (number, number, number)
        return color.R, color.G, color.B
    end, t.Color3)::(Color3) -> (number, number, number)
}

--[[
    IMPORTANT

    Color3 components appear to have less precision than Lua numbers.
    For this reason, the Color3 functions fromHex and ToHex are not
    used in the conversions here.
]]
ColorTypes.Hex = {
    fromRGB = function(r: number, g: number, b: number): string
        r, g, b = Round(r * 255), Round(g * 255), Round(b * 255)

        return string.format("%02x%02x%02x", r, g, b)
    end,

    toRGB = t.wrap(function(hex: string): (number, number, number)
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

        return ColorTypes.Number.toRGB(number)
    end, t.string)::(string) -> (number, number, number)
}

-- Conversions from https://doi.org/10.1145/965139.807361
ColorTypes.HSB = {
    fromRGB = function(r: number, g: number, b: number): (number, number, number)
        local br: number = math.max(r, g, b)
        local x: number = math.min(r, g, b)
        local s: number = (br ~= 0) and ((br - x) / br) or 0
    
        local h: number
        local rp: number = (br - r) / (br - x)
        local gp: number = (br - g) / (br - x)
        local bp: number = (br - b) / (br - x)
    
        if (r == br) then
            h = (g == x) and (5 + bp) or (1 - gp)
        elseif (g == br) then
            h = (b == x) and (1 + rp) or (3 - bp)
        else
            h = (r == x) and (3 + gp) or (5 - rp)
        end
    
        return h * 60, s, br
    end,

    toRGB = t.wrap(function(h: number, s: number, b: number): (number, number, number)
        if (s == 0) then
            return b, b, b
        else
            h = (h % 360) / 60
    
            local i: number = math.floor(h)
            local f: number = h - i
    
            local m: number = b * (1 - s)
            local n: number = b * (1 - (s * f))
            local k: number = b * (1 - (s * (1 - f)))
    
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
    end, t.tuple(t.union(t.number, t.nan), t.numberBetween(0, 1), t.numberBetween(0, 1)))::(number, number, number) -> (number, number, number)
}

-- Conversions from https://en.wikipedia.org/wiki/HSL_and_HSV#Interconversion
ColorTypes.HSL = {
    fromRGB = function(r: number, g: number, b: number): (number, number, number)
        local h: number, s: number, br: number = ColorTypes.HSB.fromRGB(r, g, b)
    
        local l: number = br * (1 - (s / 2))
        local sL: number
    
        if ((l == 1) or (l == 0)) then
            sL = 0
        else
            sL = (br - l) / math.min(l, 1 - l)
        end
    
        return h, sL, l
    end,

    toRGB = t.wrap(function(h: number, s: number, l: number): (number, number, number)
        local b: number = l + (s * math.min(l, 1 - l))
        local sV: number
    
        if (b == 0) then
            sV = 0
        else
            sV = 2 * (1 - (l / b))
        end
    
        return ColorTypes.HSB.toRGB(h % 360, sV, b)
    end, t.tuple(t.union(t.number, t.nan), t.numberBetween(0, 1), t.numberBetween(0, 1)))::(number, number, number) -> (number, number, number),
}

ColorTypes.HWB = {
    fromRGB = function(r: number, g: number, b: number): (number, number, number)
        local h: number, s: number, br: number = ColorTypes.HSB.fromRGB(r, g, b)
    
        return h, (1 - s) * br, (1 - br)
    end,

    toRGB = t.wrap(function(h: number, w: number, b: number): (number, number, number)
        local sum: number = w + b
    
        if (sum > 1) then
            w, b = w / sum, b / sum
        end
    
        local br: number = 1 - b
        local s: number = (b ~= 1) and (1 - (w / br)) or 0
    
        return ColorTypes.HSB.toRGB(h % 360, s, br)
    end, t.tuple(t.union(t.number, t.nan), t.numberBetween(0, 1), t.numberBetween(0, 1)))::(number, number, number) -> (number, number, number)
}

ColorTypes.Number = {
    fromRGB = function(r: number, g: number, b: number): number
        r, g, b = Round(r * 255), Round(g * 255), Round(b * 255)
    
        return (r * (256^2)) + (g * 256) + b
    end,
    
    toRGB = t.wrap(function(n: number): (number, number, number)
        local r: number, g: number, b: number = bit32.rshift(n, 16), bit32.band(bit32.rshift(n, 8), 255), bit32.band(n, 255)
    
        return
            r / 255,
            g / 255,
            b / 255
    end, t.intersection(t.integer, t.numberBetween(0, 256^3 - 1)))::(number) -> (number, number, number)
}

ColorTypes.RGB = {
    fromRGB = function(r: number, g: number, b: number): (number, number, number)
        return
            Round(r * 255),
            Round(g * 255),
            Round(b * 255)
    end,
    
    toRGB = t.wrap(function(r: number, g: number, b: number): (number, number, number)
        return
            r / 255,
            g / 255,
            b / 255
    end, t.tuple(t.numberAtLeast(0), t.numberAtLeast(0), t.numberAtLeast(0)))::(number, number, number) -> (number, number, number)
}

--[[
    Implementation based on Neil Bartlett's color-temperature
    https://github.com/neilbartlett/color-temperature
]]
do
    local kelvinBestFitData: {[string]: { a: number, b: number, c: number }} = {
        Red = {
            a = 351.97690566805693,
            b = 0.114206453784165,
            c = -40.25366309332127,
        },
    
        Green1 = {
            a = -155.25485562709179,
            b = -0.44596950469579133,
            c = 104.49216199393888,
        },
    
        Green2 = {
            a = 325.4494125711974,
            b = 0.07943456536662342,
            c = -28.0852963507957,
        },
    
        Blue = {
            a = -254.76935184120902,
            b = 0.8274096064007395,
            c = 115.67994401066147
        }
    }

    local kelvinBestFit = function(a: number, b: number, c: number, x: number): number
        return a + (b * x) + (c * math.log(x))
    end

    local toRGB = t.wrap(function(kelvin: number): (number, number, number)
        local temperature: number = kelvin / 100
    
        local r255: number
        local g255: number
        local b255: number
    
        if (temperature < 66) then
            local greenData = kelvinBestFitData.Green1
    
            r255 = 255
            g255 = math.clamp(kelvinBestFit(greenData.a, greenData.b, greenData.c, temperature - 2), 0, 255)
        else
            local redData = kelvinBestFitData.Red
            local greenData = kelvinBestFitData.Green2
    
            r255 = math.clamp(kelvinBestFit(redData.a, redData.b, redData.c, temperature - 55), 0, 255)
            g255 = math.clamp(kelvinBestFit(greenData.a, greenData.b, greenData.c, temperature - 50), 0, 255)
        end
    
        if (temperature >= 66) then
            b255 = 255
        elseif (temperature <= 20) then
            b255 = 0
        else
            local blueData = kelvinBestFitData.Blue
    
            b255 = math.clamp(kelvinBestFit(blueData.a, blueData.b, blueData.c, temperature - 10), 0, 255)
        end
    
        return
            Round(r255) / 255,
            Round(g255) / 255,
            Round(b255) / 255
    end, t.numberAtLeast(0))::(number) -> (number, number, number)

    local fromRGB = function(r: number, _: number, b: number): number
        local minTemperature: number = 1000
        local maxTemperature: number = 40000
        local epsilon: number = 0.4
        
        local temperature: number, testColor: {number}
    
        while ((maxTemperature - minTemperature) > epsilon) do
            temperature = (minTemperature + maxTemperature) / 2
            testColor = {toRGB(temperature)}
    
            if ((testColor[3] / testColor[1]) >= (b / r)) then
                maxTemperature = temperature
            else
                minTemperature = temperature
            end
        end
    
        return Round(temperature)
    end

    ColorTypes.Temperature = {
        fromRGB = fromRGB,
        toRGB = toRGB,
    }
end

--[[
    D65 Tristimulus Values
        X = 95.04
        Y = 100
        Z = 108.88

    sRGB Chromaticity Coordinates
        r = (0.64, 0.33)
        g = (0.30, 0.60)
        b = (0.15, 0.06)

    Conversions
        RGB <-> XYZ matrices: http://www.brucelindbloom.com/Eqn_RGB_XYZ_Matrix.html
        RGB -> XYZ: http://www.brucelindbloom.com/Eqn_RGB_to_XYZ.html
        XYZ -> RGB: http://www.brucelindbloom.com/Eqn_XYZ_to_RGB.html
]]
do
    local sRGB_XYZ_MATRIX: {{number}} = {
        {962624/2334375, 3339089/9337500, 67391/373500},
        {165451/778125, 3339089/4668750, 67391/933750},
        {15041/778125, 3339089/28012500, 5323889/5602500}
    }
    
    local XYZ_sRGB_MATRIX: {{number}} = {
        {3750/1157, -23125/15041, -7500/15041},
        {-3236250/3339089, 6263750/3339089, 138750/3339089},
        {3750/67391, -13750/67391, 71250/67391}
    }

    ColorTypes.XYZ = {
        fromRGB = function(r: number, g: number, b: number): (number, number, number)
            r, g, b = Utils.GammaCorrection.toLinear(r), Utils.GammaCorrection.toLinear(g), Utils.GammaCorrection.toLinear(b)
        
            return
                (sRGB_XYZ_MATRIX[1][1] * r) + (sRGB_XYZ_MATRIX[1][2] * g) + (sRGB_XYZ_MATRIX[1][3] * b),
                (sRGB_XYZ_MATRIX[2][1] * r) + (sRGB_XYZ_MATRIX[2][2] * g) + (sRGB_XYZ_MATRIX[2][3] * b),
                (sRGB_XYZ_MATRIX[3][1] * r) + (sRGB_XYZ_MATRIX[3][2] * g) + (sRGB_XYZ_MATRIX[3][3] * b)
        end,

        toRGB = t.wrap(function(x: number, y: number, z: number): (number, number, number)
            local r: number = (XYZ_sRGB_MATRIX[1][1] * x) + (XYZ_sRGB_MATRIX[1][2] * y) + (XYZ_sRGB_MATRIX[1][3] * z)
            local g: number = (XYZ_sRGB_MATRIX[2][1] * x) + (XYZ_sRGB_MATRIX[2][2] * y) + (XYZ_sRGB_MATRIX[2][3] * z)
            local b: number = (XYZ_sRGB_MATRIX[3][1] * x) + (XYZ_sRGB_MATRIX[3][2] * y) + (XYZ_sRGB_MATRIX[3][3] * z)
        
            return
                Utils.GammaCorrection.toStandard(r),
                Utils.GammaCorrection.toStandard(g),
                Utils.GammaCorrection.toStandard(b)
        end, t.tuple(t.numberAtLeast(0), t.numberAtLeast(0), t.numberAtLeast(0)))::(number, number, number) -> (number, number, number)
    }
end

--[[
    Conversions
        XYZ -> xyY: http://www.brucelindbloom.com/Eqn_XYZ_to_xyY.html
        xyY -> XYZ: http://www.brucelindbloom.com/Eqn_xyY_to_XYZ.html
]]
do
    local xw = 0.31271
    local yw = 0.32902

    local fromXYZ = function(X: number, Y: number, Z: number): (number, number, number)
        if ((X == 0) and (Y == 0) and (Z == 0)) then
            return xw, yw, Y
        end
    
        return
            X / (X + Y + Z),
            Y / (X + Y + Z),
            Y
    end

    local toXYZ = function(x: number, y: number, Y: number): (number, number, number)
        if (y == 0) then
            return 0, 0, 0
        end
    
        local X = (x * Y) / y
        local Z = (Y * (1 - x - y)) / y
    
        return X, Y, Z
    end

    local fromRGB = function(r: number, g: number, b: number): (number, number, number)
        return fromXYZ(ColorTypes.XYZ.fromRGB(r, g, b))
    end
    
    local toRGB = t.wrap(function(x: number, y: number, Y: number): (number, number, number)
        return ColorTypes.XYZ.toRGB(toXYZ(x, y, Y))
    end, t.tuple(t.numberBetween(0, 1), t.numberBetween(0, 1), t.numberBetween(0, 1)))::(number, number, number) -> (number, number, number)

    ColorTypes.xyY = {
        fromRGB = fromRGB,
        toRGB = toRGB,

        fromXYZ = fromXYZ,
        toXYZ = toXYZ,
    }
end

--[[
    Conversions
        XYZ -> L*a*b*: http://www.brucelindbloom.com/Eqn_XYZ_to_Lab.html
        L*a*b* -> XYZ: http://www.brucelindbloom.com/Eqn_Lab_to_XYZ.html
]]
do
    local transform = function(n: number): number
        return (n > ep) and n^(1/3) or (((ka * n) + 16) / 116)
    end

    local fromXYZ = function(x: number, y: number, z: number): (number, number, number)
        x, y, z = x * 100, y * 100, z * 100
    
        local l: number = (116 * transform(y / D65.Y)) - 16
        local a: number = 500 * (transform(x / D65.X) - transform(y / D65.Y))
        local b: number = 200 * (transform(y / D65.Y) - transform(z / D65.Z))
    
        return
            l / 100,
            a / 100,
            b / 100
    end

    local toXYZ = function(l: number, a: number, b: number): (number, number, number)
        l, a, b = l * 100, a * 100, b * 100
    
        local fy: number = (l + 16) / 116
        local fx: number = (a / 500) + fy
        local fz: number = fy - (b / 200)
    
        local xr: number = ((fx^3) > ep) and fx^3 or (((116 * fx) - 16) / ka)
        local yr: number = (l > (ka * ep)) and fy^3 or (l / ka)
        local zr: number = ((fz^3) > ep) and fz^3 or (((116 * fz) - 16) / ka)
    
        local x: number = xr * D65.X
        local y: number = yr * D65.Y
        local z: number = zr * D65.Z
    
        return
            x / 100,
            y / 100,
            z / 100
    end
    
    local fromRGB = function(r: number, g: number, b: number): (number, number, number)
        return fromXYZ(ColorTypes.XYZ.fromRGB(r, g, b))
    end

    local toRGB = t.wrap(function(l: number, a: number, b: number): (number, number, number)
        return ColorTypes.XYZ.toRGB(toXYZ(l, a, b))
    end, t.tuple(t.numberBetween(0, 1), t.number, t.number))::(number, number, number) -> (number, number, number)

    ColorTypes.Lab = {
        fromRGB = fromRGB,
        toRGB = toRGB,

        fromXYZ = fromXYZ,
        toXYZ = toXYZ,
    }
end

--[[
    Conversions
        L*a*b* -> L*C*h(ab): http://www.brucelindbloom.com/Eqn_Lab_to_LCH.html
        L*C*h(ab) -> L*a*b*: http://www.brucelindbloom.com/Eqn_LCH_to_Lab.html
]]
do
    assert(ColorTypes.Lab.fromXYZ)
    assert(ColorTypes.Lab.toXYZ)
    
    local fromLab = function(l: number, a: number, b: number): (number, number, number)
        a, b = a * 100, b * 100
    
        local c: number = math.sqrt(a^2 + b^2)
        local h: number = math.atan2(b, a)
        h = (h < 0) and (h + (2 * math.pi)) or h
    
        return l, c / 100, math.deg(h)
    end
    
    local toLab = function(l: number, c: number, h: number): (number, number, number)
        h = math.rad(h % 360)
    
        local a: number = c * math.cos(h)
        local b: number = c * math.sin(h)
    
        return l, a, b
    end
    
    local fromRGB = function(r: number, g: number, b: number): (number, number, number)
        return fromLab(ColorTypes.Lab.fromXYZ(ColorTypes.XYZ.fromRGB(r, g, b)))
    end
    
    local toRGB = t.wrap(function(l: number, c: number, h: number): (number, number, number)
        return ColorTypes.XYZ.toRGB(ColorTypes.Lab.toXYZ(toLab(l, c, h)))
    end, t.tuple(t.numberBetween(0, 1), t.number, t.union(t.number, t.nan)))::(number, number, number) -> (number, number, number)

    ColorTypes.LChab = {
        fromRGB = fromRGB,
        toRGB = toRGB,

        fromLab = fromLab,
        toLab = toLab,
    }
end

--[[
    Conversions
        XYZ -> L*u*v*: http://www.brucelindbloom.com/Eqn_XYZ_to_Luv.html
        L*u*v* -> XYZ: http://www.brucelindbloom.com/Eqn_Luv_to_XYZ.html
]]
do
    local ur: number = (4 * D65.X) / (D65.X + (15 * D65.Y) + (3 * D65.Z))
    local vr: number = (9 * D65.Y) / (D65.X + (15 * D65.Y) + (3 * D65.Z))

    local fromXYZ = function(x: number, y: number, z: number): (number, number, number)
        if ((x == 0) and (y == 0) and (z == 0)) then
            return 0, 0, 0
        else
            x, y, z = x * 100, y * 100, z * 100
    
            local up: number = (4 * x) / (x + (15 * y) + (3 * z))
            local vp: number = (9 * y) / (x + (15 * y) + (3 * z))
    
            local yr: number = y / D65.Y
    
            local l: number = (yr > ep) and ((116 * yr^(1/3)) - 16) or (ka * yr)
            local u: number = 13 * l * (up - ur)
            local v: number = 13 * l * (vp - vr)
    
            return
                l / 100,
                u / 100,
                v / 100
        end
    end

    local toXYZ = function(l: number, u: number, v: number): (number, number, number)
        if (l == 0) then
            return 0, 0, 0
        end
    
        l, u, v = l * 100, u * 100, v * 100
    
        local x: number, z: number
        local y: number = (l > (ka * ep)) and ((l + 16) / 116)^3 or (l / ka)
        
        local a: number = (((52 * l) / (u + (13 * l * ur))) - 1) / 3
        local b: number = -5 * y
        local d: number = y * ((39 * l) / (v + (13 * l * vr)) - 5)
    
        x = (d - b) / (a + (1/3))
        z = (x * a) + b
    
        return x, y, z
    end

    local fromRGB = function(r: number, g: number, b: number): (number, number, number)
        return fromXYZ(ColorTypes.XYZ.fromRGB(r, g, b))
    end
    
    local toRGB = t.wrap(function(l: number, u: number, v: number): (number, number, number)
        return ColorTypes.XYZ.toRGB(toXYZ(l, u, v))
    end, t.tuple(t.numberBetween(0, 1), t.number, t.number))::(number, number, number) -> (number, number, number)

    ColorTypes.Luv = {
        fromRGB = fromRGB,
        toRGB = toRGB,

        fromXYZ = fromXYZ,
        toXYZ = toXYZ,
    }
end

--[[
    Conversions
        L*u*v* -> L*C*h(uv): http://www.brucelindbloom.com/Eqn_Luv_to_LCH.html
        L*C*h(uv) -> L*u*v*: http://www.brucelindbloom.com/Eqn_LCH_to_Luv.html
]]
do
    assert(ColorTypes.Luv.fromXYZ)
    assert(ColorTypes.Luv.toXYZ)
    
    local fromLuv = function(l: number, u: number, v: number): (number, number, number)
        u, v = u * 100, v * 100
    
        local c: number = math.sqrt(u^2 + v^2)
        local h: number = math.atan2(v, u)
        h = (h < 0) and (h + (2 * math.pi)) or h
    
        return l, c / 100, math.deg(h)
    end
    
    local toLuv = function(l: number, c: number, h: number): (number, number, number)
        h = math.rad(h % 360)
    
        local u: number = c * math.cos(h)
        local v: number = c * math.sin(h)
    
        return l, u, v
    end
    
    local fromRGB = function(r: number, g: number, b: number): (number, number, number)
        return fromLuv(ColorTypes.Luv.fromXYZ(ColorTypes.XYZ.fromRGB(r, g, b)))
    end
    
    local toRGB = t.wrap(function(l: number, c: number, h: number): (number, number, number)
        return ColorTypes.XYZ.toRGB(ColorTypes.Luv.toXYZ(toLuv(l, c, h)))
    end, t.tuple(t.numberBetween(0, 1), t.number, t.union(t.number, t.nan)))::(number, number, number) -> (number, number, number)

    ColorTypes.LChuv = {
        fromRGB = fromRGB,
        toRGB = toRGB,

        fromLuv = fromLuv,
        toLuv = toLuv,
    }
end

-- Aliases

ColorTypes.HSV = ColorTypes.HSB
ColorTypes.LCh = ColorTypes.LChab

return ColorTypes