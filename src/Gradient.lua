--!strict

local root = script.Parent
local Color = require(root.Color)
local Types = require(root.Types)
local t = require(root.t)

---

type Color = Color.Color

export type GradientKeypoint = {
    Time: number,
    Color: Color,
}

export type RawGradient = {
    Keypoints: {GradientKeypoint}
}

---

local CS_MAX_KEYPOINTS: number

local keypointCheck = t.struct({
    Time = t.numberBetween(0, 1),
    Color = Color.isAColor,
})

local keypointsCheck = function(value: {GradientKeypoint}): (boolean, string?)
    local isArray, arrayError = t.array(keypointCheck)(value)

    if (not isArray) then
        return false, arrayError
    end

    local arraySize: number = #value

    -- make sure there are at least 2 keypoints
    if (arraySize < 2) then
        return false, "Gradient must have at least 2 keypoints"
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
    if (#value > 2) then
        for i = 1, (#value - 1) do
            local thisKeypoint: GradientKeypoint = value[i]
            local nextKeypoint: GradientKeypoint = value[i + 1]

            if (thisKeypoint.Time > nextKeypoint.Time) then
                return false, "keypoints must be sorted by ascending time"
            end
        end
    end

    return true
end

local gradientCheck = t.struct({
    Keypoints = keypointsCheck
})

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

local Gradient = {}

local gradientMetatable = table.freeze({
    __index = Gradient,

    __eq = t.wrap(function(gradient1: RawGradient, gradient2: RawGradient): boolean
        local gradient1Keypoints: {GradientKeypoint} = rawget(gradient1, "Keypoints")
        local gradient2Keypoints: {GradientKeypoint} = rawget(gradient2, "Keypoints")

        for i = 1, #gradient1Keypoints do
            local gradient1Keypoint: GradientKeypoint = gradient1Keypoints[i]
            local gradient2Keypoint: GradientKeypoint = gradient2Keypoints[i]

            if ((gradient1Keypoint.Time ~= gradient2Keypoint.Time) or (not Color.unclippedEq(gradient1Keypoint.Color, gradient2Keypoint.Color))) then
                return false
            end
        end

        return true
    end, t.tuple(gradientCheck, gradientCheck)),

    __tostring = t.wrap(function(gradient: RawGradient): string
        local keypoints: {GradientKeypoint} = rawget(gradient, "Keypoints")
        local keypointStrings: {string} = {}

        for i = 1, #keypoints do
            local keypoint: GradientKeypoint = keypoints[i]
            local r: number, g: number, b: number = Color.components(keypoint.Color)

            table.insert(keypointStrings, string.format("%f = [%f, %f, %f]", keypoint.Time, r, g, b))
        end
        
        return string.format("Gradient(%s)", table.concat(keypointStrings, ", "))
    end, gradientCheck)
})

--[[
    Creates a new Gradient from an array of GradientKeypoints
]]
Gradient.new = function(keypoints: {GradientKeypoint})
    assert(keypointsCheck(keypoints))

    return table.freeze(setmetatable({
        Keypoints = copyKeypointTable(keypoints),
    }, gradientMetatable))
end

export type MetaGradient = typeof(Gradient.new({}))
export type Gradient = RawGradient | MetaGradient

---

--[[
    Returns the maximum number of keypoints a ColorSequence can have
]]
Gradient.getMaxColorSequenceKeypoints = function(): number
    return CS_MAX_KEYPOINTS
end

--[[
    Returns if a value can be used as a Gradient in the API
]]
Gradient.isAGradient = gradientCheck

--[[
    Creates a new Gradient from a Color tuple
]]
Gradient.fromColors = function(...: Color): MetaGradient
    local colors: {Color} = {...}
    assert(t.array(Color.isAColor))

    local numColors: number = #colors
    assert(numColors >= 1, "no Colors are provided")

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

--[[
    Creates a Gradient from a ColorSequence
]]
Gradient.fromColorSequence = t.wrap(function(colorSequence: ColorSequence): MetaGradient
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
end, t.ColorSequence)

---

--[[
    Returns a Gradient with the keypoints reversed in time
]]
Gradient.invert = t.wrap(function(gradient: Gradient): MetaGradient
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
end, gradientCheck)

-- https://create.roblox.com/docs/reference/engine/datatypes/ColorSequence
--[[
    Evaluates a Gradient at a specific time and returns the corresponding Color

    @param gradient
    @param time 
    @param colorType? The color type to mix with
    @param hueAdjustment? The hue adjustment method when mixing with color types that have a hue component
]]
Gradient.color = t.wrap(function(gradient: Gradient, time: number, optionalColorType: Types.ColorType?, optionalHueAdjustment: Types.HueAdjustment?): Color
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
end, t.tuple(gradientCheck, t.numberBetween(0, 1), t.optional(Types.Runtime.ColorType), t.optional(Types.Runtime.HueAdjustment)))

--[[
    Returns a list of Colors with keypoints that are an equal distance of time apart  

    @param gradient
    @param steps The number of Colors to generate, at least 2
    @param colorType? The color type to mix with
    @param hueAdjustment? The hue adjustment method when mixing with color types that have a hue component
]]
Gradient.colors = t.wrap(function(gradient: Gradient, steps: number, optionalColorType: Types.ColorType?, optionalHueAdjustment: Types.HueAdjustment?): {Color}
    local colors: {Color} = {}

    for i = 1, steps do
        table.insert(colors, Gradient.color(gradient, (i - 1) / (steps - 1), optionalColorType, optionalHueAdjustment))
    end

    return colors
end, t.tuple(gradientCheck, t.intersection(t.integer, t.numberAtLeast(2)), t.optional(Types.Runtime.ColorType), t.optional(Types.Runtime.HueAdjustment)))

--[[
    Returns a ColorSequence derived from a Gradient

    @param gradient
    @param steps The number of keypoints to generate, between 2 and the maximum possible number of ColorSequence keypoints
    @param colorType? The color type to mix with
    @param hueAdjustment? The hue adjustment method when mixing with color types that have a hue component
]]
Gradient.toColorSequence = t.wrap(function(gradient: Gradient, optionalSteps: number?, optionalColorType: Types.ColorType?, optionalHueAdjustment: Types.HueAdjustment?): ColorSequence
    local colorType: Types.ColorType = optionalColorType or "RGB"
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
end, t.tuple(gradientCheck, t.optional(t.intersection(t.integer, t.numberBetween(2, CS_MAX_KEYPOINTS))), t.optional(Types.Runtime.ColorType), t.optional(Types.Runtime.HueAdjustment)))

--[[
    **DEPRECATED**\
    Alias for `Gradient.toColorSequence`
]]
Gradient.colorSequence = Gradient.toColorSequence

---

return table.freeze(Gradient)