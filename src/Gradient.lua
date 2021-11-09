--!strict

local root = script.Parent

local Color = require(root.Color)

---

type Color = Color.Color

type GradientKeypoint = {
    Time: number,
    Color: Color,
}

local CS_MAX_KEYPOINTS

do
    local n = 2
    local csConstructionOk = true
    
    -- in case the limit is removed, cap at 100
    while ((csConstructionOk) and (n < 101)) do
        n = n + 1

        local keypoints = {}

        for i = 1, n do
            table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / (n - 1), Color3.new()))
        end

        csConstructionOk = pcall(function()
            ColorSequence.new(keypoints)
        end)
    end

    CS_MAX_KEYPOINTS = n - 1
end

---

local Gradient = {}

local gradientMetatable = table.freeze({
    __index = Gradient,

    __eq = function(gradient1, gradient2): boolean
        local gradient1Keypoints = gradient1.Keypoints
        local gradient2Keypoints = gradient2.Keypoints

        for i = 1, #gradient1Keypoints do
            local gradient1Keypoint = gradient1Keypoints[i]
            local gradient2Keypoint = gradient2Keypoints[i]

            if ((gradient1Keypoint.Time ~= gradient2Keypoint.Time) or (not gradient1Keypoint.Color:unclippedEq(gradient2Keypoint.Color))) then
                return false
            end
        end

        return true
    end,

    __tostring = function(gradient): string
        local keypoints = gradient.Keypoints
        local keypointStrings = {}

        for i = 1, #keypoints do
            local color = keypoints[i]
            local r, g, b = color.Color:components()

            table.insert(keypointStrings, string.format("%f = [%f, %f, %f]", color.Time, r, g, b))
        end
        
        return string.format("Gradient(%s)", table.concat(keypointStrings, ", "))
    end
})

Gradient.new = function(keypoints: {GradientKeypoint})
    assert(#keypoints >= 2, "Gradient must have at least 2 Colors")
    assert(keypoints[1].Time == 0, "Gradient must start at t = 0")
    assert(keypoints[#keypoints].Time == 1, "Gradient must end at t = 1")

    for i = 1, (#keypoints - 1) do
        local this = keypoints[i]
        local next = keypoints[i + 1]

        assert(next.Time > this.Time, "keypoints must be sorted by time")
        assert(Color.isAColor(this.Color), "keypoint colors must be Colors")
    end

    return table.freeze(setmetatable({
        Keypoints = table.freeze(keypoints),
    }, gradientMetatable))
end

Gradient.fromColors = function(...: Color): Gradient
    local colors = {...}
    local numColors = #colors
    assert(numColors >= 1, "no Colors provided")

    if (numColors == 1) then
        local color = colors[1]
        assert(Color.isAColor(color), "color is not a Color")

        return Gradient.new({
            {Time = 0, Color = color},
            {Time = 1, Color = color},
        })
    elseif (numColors == 2) then
        local startColor = colors[1]
        local endColor = colors[2]

        assert(Color.isAColor(startColor), "start color is not a Color")
        assert(Color.isAColor(endColor), "end color is not a Color")

        return Gradient.new({
            {Time = 0, Color = startColor},
            {Time = 1, Color = endColor},
        })
    else
        local keypoints = {}

        for i = 1, numColors do
            local color = colors[i]
            assert(Color.isAColor(color), "cannot create a Gradient with a non-Color value")

            table.insert(keypoints, {
                Time = (i - 1) / (numColors - 1),
                Color = color
            })
        end

        return Gradient.new(keypoints)
    end
end

Gradient.fromColorSequence = function(colorSequence: ColorSequence): Gradient
    local colors = {}
    local keypoints = colorSequence.Keypoints

    for i = 1, #keypoints do
        local keypoint = keypoints[i]

        table.insert(colors, {
            Time = keypoint.Time,
            Color = Color.from("Color3", keypoint.Value),
        })
    end

    return Gradient.new(colors)
end

---

Gradient.invert = function(gradient: Gradient): Gradient
    local keypoints = gradient.Keypoints
    local invertedKeypoints = {}

    for i = #keypoints, 1, -1 do
        local keypoint = keypoints[i]

        table.insert(invertedKeypoints, {
            Time = 1 - keypoint.Time,
            Color = keypoint.Color,
        })
    end

    return Gradient.new(invertedKeypoints)
end

-- https://developer.roblox.com/en-us/api-reference/datatype/ColorSequence#evaluation
Gradient.color = function(gradient: Gradient, time: number, mode: string?, hueAdjustment: string?): Color
    assert((time >= 0) and (time <= 1), "time out of range [0, 1]")
    mode = mode or "RGB"

    local keypoints = gradient.Keypoints
    local color

    if (time == 0) then
        color = keypoints[1].Color
    elseif (time == 1) then
        color = keypoints[#keypoints].Color
    else
        for i = 1, #keypoints - 1 do
            local this = keypoints[i]
            local next = keypoints[i + 1]

            if ((time >= this.Time) and (time < next.Time)) then
                color = this.Color:mix(next.Color, (time - this.Time) / (next.Time - this.Time), mode, hueAdjustment)
                break
            end
        end
    end

    return color
end

Gradient.colors = function(gradient: Gradient, amount: number, mode: string?, hueAdjustment: string?): {Color}
    local colors = {}

    for i = 1, amount do
        table.insert(colors, Gradient.color(gradient, (i - 1) / (amount - 1), mode, hueAdjustment))
    end

    return colors
end

Gradient.toColorSequence = function(gradient: Gradient, steps: number?, mode: string?, hueAdjustment: string?): ColorSequence
    mode = mode or "RGB"

    local csKeypoints = {}

    if (mode == "RGB") then
        local keypoints = gradient.Keypoints

        for i = 1, #keypoints do
            local color = keypoints[i]

            table.insert(csKeypoints, ColorSequenceKeypoint.new(color.Time, color.Color:to("Color3")))
        end
    else
        steps = steps or CS_MAX_KEYPOINTS
        assert((steps >= 2) and (steps <= CS_MAX_KEYPOINTS), "number of steps out of range [2, " .. CS_MAX_KEYPOINTS .. "]")

        local colors = Gradient.colors(gradient, steps, mode, hueAdjustment)

        for i = 1, steps do
            table.insert(csKeypoints, ColorSequenceKeypoint.new((i - 1) / (steps - 1), colors[i]:to("Color3")))
        end
    end

    return ColorSequence.new(csKeypoints)
end

---

export type Gradient = typeof(Gradient.new({}))

return table.freeze(Gradient)