--!strict

local root = script.Parent.Parent
local t = require(root.t)

local Utils = root.Utils
local round = require(Utils.Round)

---

type BestFitData = {
    a: number,
    b: number,
    c: number,
}

-- Implementation based on Neil Bartlett's color-temperature
-- https://github.com/neilbartlett/color-temperature

local kelvinBestFit = function(a: number, b: number, c: number, x: number): number
    return a + (b * x) + (c * math.log(x))
end

local kelvinBestFitData: {[string]: BestFitData} = {
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

---

local Temperature = {}

Temperature.toRGB = t.wrap(function(kelvin: number): (number, number, number)
    local temperature: number = kelvin / 100

    local r255: number
    local g255: number
    local b255: number

    if (temperature < 66) then
        local greenData: BestFitData = kelvinBestFitData.Green1

        r255 = 255
        g255 = math.clamp(kelvinBestFit(greenData.a, greenData.b, greenData.c, temperature - 2), 0, 255)
    else
        local redData: BestFitData = kelvinBestFitData.Red
        local greenData: BestFitData = kelvinBestFitData.Green2

        r255 = math.clamp(kelvinBestFit(redData.a, redData.b, redData.c, temperature - 55), 0, 255)
        g255 = math.clamp(kelvinBestFit(greenData.a, greenData.b, greenData.c, temperature - 50), 0, 255)
    end

    if (temperature >= 66) then
        b255 = 255
    elseif (temperature <= 20) then
        b255 = 0
    else
        local blueData: BestFitData = kelvinBestFitData.Blue

        b255 = math.clamp(kelvinBestFit(blueData.a, blueData.b, blueData.c, temperature - 10), 0, 255)
    end

    return
        round(r255) / 255,
        round(g255) / 255,
        round(b255) / 255
end, t.number)

Temperature.fromRGB = function(r: number, _: number, b: number): number
    local minTemperature: number = 1000
    local maxTemperature: number = 40000
    local epsilon: number = 0.4
    
    local temperature: number, testColor: {number}

    while ((maxTemperature - minTemperature) > epsilon) do
        temperature = (minTemperature + maxTemperature) / 2
        testColor = {Temperature.toRGB(temperature)}

        if ((testColor[3] / testColor[1]) >= (b / r)) then
            maxTemperature = temperature
        else
            minTemperature = temperature
        end
    end

    return round(temperature)
end

return Temperature