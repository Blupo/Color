--!strict

local Color = require(script.Color)
local Gradient = require(script.Gradient)

export type Color = Color.Color
export type Gradient = Gradient.Gradient
export type GradientKeypoint = Gradient.GradientKeypoint

---

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

    fromBrickColor = Color.fromBrickColor,
    fromCMYK = Color.fromCMYK,
    fromColor3 = Color.fromColor3,
    fromHex = Color.fromHex,
    fromHSB = Color.fromHSB,
    fromHSL = Color.fromHSL,
    fromHWB = Color.fromHWB,
    fromLab = Color.fromLab,
    fromLChab = Color.fromLChab,
    fromLChuv = Color.fromLChuv,
    fromLuv = Color.fromLuv,
    fromNumber = Color.fromNumber,
    fromRGB = Color.fromRGB,
    fromTemperature = Color.fromTemperature,
    fromXYZ = Color.fromXYZ,

    toBrickColor = Color.toBrickColor,
    toCMYK = Color.toCMYK,
    toColor3 = Color.toColor3,
    toHex = Color.toHex,
    toHSB = Color.toHSB,
    toHSL = Color.toHSL,
    toHWB = Color.toHWB,
    toLab = Color.toLab,
    toLChab = Color.toLChab,
    toLChuv = Color.toLChuv,
    toLuv = Color.toLuv,
    toNumber = Color.toNumber,
    toRGB = Color.toRGB,
    toTemperature = Color.toTemperature,
    toXYZ = Color.toXYZ,

    fromHSV = Color.fromHSV,
    fromLCh = Color.fromLCh,

    toHSV = Color.toHSV,
    toLCh = Color.toLCh,
}