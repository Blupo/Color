--!strict

local root = script.Parent
local Color = require(root.Color)
local Types = require(root.Types)

---

type Color = Color.Color

export type GradientKeypoint = {
    Time: number,
    Color: Color,
}

---

local CS_MAX_KEYPOINTS: number

local keypointsCheck = function(value: {GradientKeypoint}): (boolean, string?)
    if (typeof(value) ~= "table") then
        return false, "not a table"
    end

    local arraySize: number = #value

    -- make sure there are at least 2 keypoints
    if (arraySize < 2) then
        return false, "must have at least 2 keypoints"
    end

    -- make sure the keypoints are actually keypoints
    for i = 1, arraySize do
        local keypoint: GradientKeypoint = value[i]

        if (not Color.isAColor(keypoint.Color)) then
            return false, "keypoint #" .. i .. " does not have a valid color"
        end

        if (typeof(keypoint.Time) ~= "number") then
            return false, "keypoint #" .. i .. " does not have a valid time"
        end

        if ((keypoint.Time < 0) or (keypoint.Time > 1)) then
            return false, "keypoint #" .. i .. " has a time outside of [0, 1]"
        end
    end

    -- make sure the first keypoint has time 0
    if (value[1].Time ~= 0) then
        return false, "first keypoint must have time 0"
    end

    -- make sure the last keypoint has time 1
    if (value[arraySize].Time ~= 1) then
        return false, "last keypoint must have time 1"
    end

    -- make sure the array is sorted by time
    if (arraySize > 2) then
        for i = 1, (arraySize - 1) do
            local thisKeypoint: GradientKeypoint = value[i]
            local nextKeypoint: GradientKeypoint = value[i + 1]

            if (thisKeypoint.Time > nextKeypoint.Time) then
                return false, "keypoints must be sorted by ascending time"
            end
        end
    end

    return true
end

local gradientCheck = function(value: any): (boolean, string?)
    if (typeof(value) ~= "table") then
        return false, "not a table"
    end

    return keypointsCheck(value)
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

-- calculate the maximum number of ColorSequence keypoints (up to 100)
do
    local numKeypoints: number = 2
    local colorSequenceOk: boolean = true

    repeat
        local keypoints: {ColorSequenceKeypoint} = {}

        for i = 1, numKeypoints do
            table.insert(keypoints, ColorSequenceKeypoint.new((i - 1) / (numKeypoints - 1), Color3.new()))
        end

        colorSequenceOk = pcall(function()
            ColorSequence.new(keypoints)
            numKeypoints += 1
        end)
    until ((not colorSequenceOk) or (numKeypoints >= 101))

    CS_MAX_KEYPOINTS = numKeypoints - 1
end

---

--[=[
    @class Gradient
]=]
--[=[
    @prop Keypoints {GradientKeypoint}
    @within Gradient
    @readonly
]=]
--[=[
    @interface GradientKeypoint
    @within Gradient
    @field Time number -- Between 0 and 1
    @field Color Color
]=]

local Gradient = {}
local gradientMetatable = { __index = Gradient }

--[=[
    Creates a new Gradient from an array of GradientKeypoints

    @function new
    @within Gradient
    @param keypoints {GradientKeypoint}
    @return Gradient
    @tag Constructor
]=]
Gradient.new = function(keypoints: {GradientKeypoint})
    assert(keypointsCheck(keypoints))

    return table.freeze(setmetatable({
        Keypoints = copyKeypointTable(keypoints),
    }, gradientMetatable))
end

export type Gradient = typeof(Gradient.new({}))

gradientMetatable.__eq = function(gradient1: Gradient, gradient2: Gradient): boolean
    local gradient1Keypoints: {GradientKeypoint} = gradient1.Keypoints
    local gradient2Keypoints: {GradientKeypoint} = gradient2.Keypoints

    for i = 1, #gradient1Keypoints do
        local gradient1Keypoint: GradientKeypoint = gradient1Keypoints[i]
        local gradient2Keypoint: GradientKeypoint = gradient2Keypoints[i]

        if ((gradient1Keypoint.Time ~= gradient2Keypoint.Time) or (gradient1Keypoint.Color ~= gradient2Keypoint.Color)) then
            return false
        end
    end

    return true
end

gradientMetatable.__tostring = function(gradient: Gradient): string
    local keypoints: {GradientKeypoint} = gradient.Keypoints
    local keypointStrings: {string} = {}

    for i = 1, #keypoints do
        local keypoint: GradientKeypoint = keypoints[i]
        local r: number, g: number, b: number = Color.components(keypoint.Color)

        table.insert(keypointStrings, string.format("%f = [%f, %f, %f]", keypoint.Time, r, g, b))
    end
    
    return string.format("Gradient(%s)", table.concat(keypointStrings, ", "))
end

---

--[=[
    Returns the maximum number of keypoints a ColorSequence can have

    @function getMaxColorSequenceKeypoints
    @within Gradient
    @return number
]=]
Gradient.getMaxColorSequenceKeypoints = function(): number
    return CS_MAX_KEYPOINTS
end

--[=[
    Returns if a value can be used as a Gradient

    @function isAGradient
    @within Gradient
    @param value any
    @return boolean
    @return string?
]=]
Gradient.isAGradient = gradientCheck

--[=[
    Creates a new Gradient from a Color tuple

    @function fromColors
    @within Gradient
    @param ... Color
    @return Gradient
    @tag Constructor
]=]
Gradient.fromColors = function(...: Color): Gradient
    local colors: {Color} = {...}
    local numColors: number = #colors
    assert(numColors >= 1, "no colors provided")

    for i = 1, numColors do
        assert(Color.isAColor(colors[i]), "argument #" .. i .. " is not a color")
    end

    if (numColors == 1) then
        local color: Color = colors[1]

        return Gradient.new({
            {Time = 0, Color = color},
            {Time = 1, Color = color},
        })
    elseif (numColors == 2) then
        local startColor: Color = colors[1]
        local endColor: Color = colors[2]

        return Gradient.new({
            {Time = 0, Color = startColor},
            {Time = 1, Color = endColor},
        })
    else
        local keypoints: {GradientKeypoint} = {}

        for i = 1, numColors do
            local color: Color = colors[i]

            table.insert(keypoints, {
                Time = (i - 1) / (numColors - 1),
                Color = color
            })
        end

        return Gradient.new(keypoints)
    end
end

--[=[
    Creates a Gradient from a ColorSequence

    @function fromColorSequence
    @within Gradient
    @param colorSequence ColorSequence
    @return Gradient
    @tag Constructor
]=]
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

--[=[
    Returns a Gradient with the keypoints reversed in time

    @function invert
    @within Gradient
    @param gradient Gradient
    @return Gradient
]=]
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

-- https://create.roblox.com/docs/reference/engine/datatypes/ColorSequence
--[=[
    Evaluates a Gradient at a specific time and returns the corresponding Color

    @function color
    @within Gradient
    @param gradient Gradient
    @param time number
    @param colorType MixableColorType? -- The color type to mix with
    @param hueAdjustment HueAdjustment? -- The hue adjustment method when mixing with color types that have a hue component
    @return Color
]=]
Gradient.color = function(gradient: Gradient, time: number, optionalColorType: Types.MixableColorType?, optionalHueAdjustment: Types.HueAdjustment?): Color
    local keypoints: {GradientKeypoint} = gradient.Keypoints

    if (time == 0) then
        return keypoints[1].Color
    elseif (time == 1) then
        return keypoints[#keypoints].Color
    else
        for i = 1, #keypoints - 1 do
            local this: GradientKeypoint = keypoints[i]
            local next: GradientKeypoint = keypoints[i + 1]

            if ((time >= this.Time) and (time < next.Time)) then
                local ratio: number = (time - this.Time) / (next.Time - this.Time)

                return Color.mix(this.Color, next.Color, ratio, optionalColorType, optionalHueAdjustment)
            end
        end
    end

    -- how did we get here?
    error("unable to evaluate Gradient")
end

--[=[
    Returns a list of Colors with keypoints that are an equal distance of time apart  

    @function colors
    @within Gradient
    @param gradient Gradient
    @param steps number -- The number of Colors to generate, at least 2
    @param colorType MixableColorType? -- The color type to mix with
    @param hueAdjustment HueAdjustment? -- The hue adjustment method when mixing with color types that have a hue component
    @return {Color}
]=]
Gradient.colors = function(gradient: Gradient, steps: number, optionalColorType: Types.MixableColorType?, optionalHueAdjustment: Types.HueAdjustment?): {Color}
    assert(steps >= 2, "must generate at least 2 colors")

    local colors: {Color} = {}

    for i = 1, steps do
        table.insert(colors, Gradient.color(gradient, (i - 1) / (steps - 1), optionalColorType, optionalHueAdjustment))
    end

    return colors
end

--[=[
    Returns a ColorSequence derived from a Gradient

    @function toColorSequence
    @within Gradient
    @param gradient Gradient
    @param steps number -- The number of keypoints to generate, between 2 and the maximum possible number of ColorSequence keypoints
    @param colorType MixableColorType? -- The color type to mix with
    @param hueAdjustment HueAdjustment? -- The hue adjustment method when mixing with color types that have a hue component
    @return ColorSequence
]=]
Gradient.toColorSequence = function(gradient: Gradient, optionalSteps: number?, optionalColorType: Types.MixableColorType?, optionalHueAdjustment: Types.HueAdjustment?): ColorSequence
    if (optionalSteps) then
        assert((optionalSteps >= 2) and (optionalSteps <= CS_MAX_KEYPOINTS), "number of keypoints must be between 2 and " .. CS_MAX_KEYPOINTS)
    end
    
    local colorType: Types.MixableColorType = optionalColorType or "RGB"
    local csKeypoints: {ColorSequenceKeypoint} = {}

    if (colorType == "RGB") then
        local keypoints: {GradientKeypoint} = gradient.Keypoints

        for i = 1, #keypoints do
            local keypoint: GradientKeypoint = keypoints[i]

            table.insert(csKeypoints, ColorSequenceKeypoint.new(keypoint.Time, Color.to(keypoint.Color, "Color3")))
        end
    else
        local steps: number = optionalSteps or CS_MAX_KEYPOINTS
        local colors: {Color} = Gradient.colors(gradient, steps, colorType, optionalHueAdjustment)

        for i = 1, steps do
            table.insert(csKeypoints, ColorSequenceKeypoint.new((i - 1) / (steps - 1), Color.to(colors[i], "Color3")))
        end
    end

    return ColorSequence.new(csKeypoints)
end

--[=[
    Alias for [`Gradient.toColorSequence`](#toColorSequence)

    @function colorSequence
    @within Gradient
    @param gradient Gradient
    @param steps number
    @param colorType MixableColorType?
    @param hueAdjustment HueAdjustment?
    @return ColorSequence
    @deprecated 0.3.0
]=]
Gradient.colorSequence = Gradient.toColorSequence

---

return table.freeze(Gradient)