--!strict

local Color = require(script.Color)
local Gradient = require(script.Gradient)

return {
    new = Color.new,
    random = Color.random,
    from = Color.from,

    isAColor = Color.isAColor,
    isClipped = Color.isClipped,
    unclippedEq = Color.unclippedEq,

    components = Color.components,
    to = Color.to,

    invert = Color.invert,
    mix = Color.mix,
    blend = Color.blend,

    luminance = Color.luminance,
    contrast = Color.contrast,
    bestContrastingColor = Color.bestContrastingColor,

    brighten = Color.brighten,
    darken = Color.darken,
    saturate = Color.saturate,
    desaturate = Color.desaturate,

    gradient = Gradient.new,
    gradientFromColors = Gradient.fromColors,
    gradientFromColorSequence = Gradient.fromColorSequence,
}