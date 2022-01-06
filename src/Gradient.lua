--!strict

local root = script.Parent
local Color = require(root.Color)

---

type Color = Color.Color

export type GradientKeypoint = {
    Time: number,
    Color: Color,
}

local CS_MAX_KEYPOINTS: number

do
    local n: number = 2
    local csConstructionOk: boolean = true
    
    -- in case the limit is removed, cap at 100
    while ((csConstructionOk) and (n < 101)) do
        n = n + 1

        local keypoints: {ColorSequenceKeypoint} = {}

        for i = 1, n do
            table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / (n - 1), Color3.new()))
        end

        csConstructionOk = pcall(function()
            ColorSequence.new(keypoints)
        end)
    end

    CS_MAX_KEYPOINTS = n - 1
end

local copyKeypointTable = function(original: {GradientKeypoint}): {GradientKeypoint}
    local copy: {GradientKeypoint} = {}

    for i = 1, #original do
        local keypoint = original[i]

        copy[i] = table.freeze({
            Time = keypoint.Time,
            Color = keypoint.Color
        })
    end

    return table.freeze(copy)
end

---

local Gradient = {}

local gradientMetatable = table.freeze({
    __index = Gradient,

    __eq = function(gradient1, gradient2): boolean
        local gradient1Keypoints: {GradientKeypoint} = gradient1.Keypoints
        local gradient2Keypoints: {GradientKeypoint} = gradient2.Keypoints

        for i = 1, #gradient1Keypoints do
            local gradient1Keypoint: GradientKeypoint = gradient1Keypoints[i]
            local gradient2Keypoint: GradientKeypoint = gradient2Keypoints[i]

            if ((gradient1Keypoint.Time ~= gradient2Keypoint.Time) or (not Color.unclippedEq(gradient1Keypoint.Color, gradient2Keypoint.Color))) then
                return false
            end
        end

        return true
    end,

    __tostring = function(gradient): string
        local keypoints: {GradientKeypoint} = gradient.Keypoints
        local keypointStrings: {string} = {}

        for i = 1, #keypoints do
            local keypoint: GradientKeypoint = keypoints[i]
            local r: number, g: number, b: number = Color.components(keypoint.Color)

            table.insert(keypointStrings, string.format("%f = [%f, %f, %f]", keypoint.Time, r, g, b))
        end
        
        return string.format("Gradient(%s)", table.concat(keypointStrings, ", "))
    end
})

Gradient.new = function(keypoints: {GradientKeypoint})
    assert(#keypoints >= 2, "Gradient must have at least 2 Colors")
    assert(keypoints[1].Time == 0, "Gradient must start at t = 0")
    assert(keypoints[#keypoints].Time == 1, "Gradient must end at t = 1")

    for i = 1, (#keypoints - 1) do
        local this: GradientKeypoint = keypoints[i]
        local next: GradientKeypoint = keypoints[i + 1]

        assert(next.Time > this.Time, "keypoints must be sorted by time")
        assert(Color.isAColor(this.Color), "keypoint colors must be Colors")
    end

    return table.freeze(setmetatable({
        Keypoints = copyKeypointTable(keypoints),
    }, gradientMetatable))
end

Gradient.fromColors = function(...: Color): Gradient
    local colors: {Color} = {...}
    local numColors: number = #colors
    assert(numColors >= 1, "no Colors provided")

    if (numColors == 1) then
        local color: Color = colors[1]
        assert(Color.isAColor(color), "color is not a Color")

        return Gradient.new({
            {Time = 0, Color = color},
            {Time = 1, Color = color},
        })
    elseif (numColors == 2) then
        local startColor: Color = colors[1]
        local endColor: Color = colors[2]

        assert(Color.isAColor(startColor), "start color is not a Color")
        assert(Color.isAColor(endColor), "end color is not a Color")

        return Gradient.new({
            {Time = 0, Color = startColor},
            {Time = 1, Color = endColor},
        })
    else
        local keypoints: {GradientKeypoint} = {}

        for i = 1, numColors do
            local color: Color = colors[i]
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
    local colors: {GradientKeypoint} = {}
    local keypoints: {ColorSequenceKeypoint} = colorSequence.Keypoints

    for i = 1, #keypoints do
        local keypoint: ColorSequenceKeypoint = keypoints[i]

        table.insert(colors, {
            Time = keypoint.Time,
            Color = Color.from("Color3", keypoint.Value),
        })
    end

    return Gradient.new(colors)
end

---

Gradient.invert = function(gradient: Gradient): Gradient
    local keypoints: {GradientKeypoint} = gradient.Keypoints
    local invertedKeypoints: {GradientKeypoint} = {}

    for i = #keypoints, 1, -1 do
        local keypoint: GradientKeypoint = keypoints[i]

        table.insert(invertedKeypoints, {
            Time = 1 - keypoint.Time,
            Color = keypoint.Color,
        })
    end

    return Gradient.new(invertedKeypoints)
end

-- https://developer.roblox.com/en-us/api-reference/datatype/ColorSequence#evaluation
Gradient.color = function(gradient: Gradient, time: number, optionalMode: string?, optionalHueAdjustment: string?): Color
    assert((time >= 0) and (time <= 1), "time out of range [0, 1]")

    local keypoints: {GradientKeypoint} = gradient.Keypoints
    local color: Color

    if (time == 0) then
        color = keypoints[1].Color
    elseif (time == 1) then
        color = keypoints[#keypoints].Color
    else
        for i = 1, #keypoints - 1 do
            local this: GradientKeypoint = keypoints[i]
            local next: GradientKeypoint = keypoints[i + 1]

            if ((time >= this.Time) and (time < next.Time)) then
                color = Color.mix(this.Color, next.Color, (time - this.Time) / (next.Time - this.Time), optionalMode, optionalHueAdjustment)
                break
            end
        end
    end

    return color
end

Gradient.colors = function(gradient: Gradient, amount: number, optionalMode: string?, optionalHueAdjustment: string?): {Color}
    local colors: {Color} = {}

    for i = 1, amount do
        table.insert(colors, Gradient.color(gradient, (i - 1) / (amount - 1), optionalMode, optionalHueAdjustment))
    end

    return colors
end

Gradient.colorSequence = function(gradient: Gradient, optionalSteps: number?, optionalMode: string?, optionalHueAdjustment: string?): ColorSequence
    local mode = optionalMode or "RGB"
    local csKeypoints: {ColorSequenceKeypoint} = {}

    if (mode == "RGB") then
        local keypoints: {GradientKeypoint} = gradient.Keypoints

        for i = 1, #keypoints do
            local keypoint: GradientKeypoint = keypoints[i]

            table.insert(csKeypoints, ColorSequenceKeypoint.new(keypoint.Time, Color.to(keypoint.Color, "Color3")))
        end
    else
        local steps: number = optionalSteps or CS_MAX_KEYPOINTS
        assert((steps >= 2) and (steps <= CS_MAX_KEYPOINTS), "number of steps out of range [2, " .. CS_MAX_KEYPOINTS .. "]")

        local colors: {Color} = Gradient.colors(gradient, steps, mode, optionalHueAdjustment)

        for i = 1, steps do
            table.insert(csKeypoints, ColorSequenceKeypoint.new((i - 1) / (steps - 1), Color.to(colors[i], "Color3")))
        end
    end

    return ColorSequence.new(csKeypoints)
end

---

export type Gradient = typeof(Gradient.new({}))

return table.freeze(Gradient)