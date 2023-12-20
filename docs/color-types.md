---
sidebar_position: 4
---

# Color Types

This page is an explanation on the various color types, the arguments used for the various import aliases, as well as the values returned from exporting. For the `ColorType` enum, check [the API reference](/api/Enums#ColorType).

Unless otherwise stated, the arguments to a particular color type's import alias and the values returned by its export alias are the same.

## RGB

- Import alias: `Color.fromRGB`
- Export alias: `Color.toRGB`
- Import arguments/export values:
    - The amount of red, between 0 and 255
    - The amount of green, between 0 and 255
    - The amount of blue, between 0 and 255

## BrickColor

- Import alias: `Color.fromBrickColor`
- Export alias: `Color.toBrickColor`
- Import arguments/export values:
    - A [BrickColor](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor)

## CMYK

- Import alias: `Color.fromCMYK`
- Export alias: `Color.toCMYK`
- Import arguments/export values:
    - The amount of cyan, between 0 and 1
    - The amount of magenta, between 0 and 1
    - The amount of yellow, between 0 and 1
    - The amount of key (black), between 0 and 1

## Color3

- Import alias: `Color.fromColor3`
- Export alias: `Color.toColor3`
- Import arguments/export values:
    - A [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3)

## HPLuv

A variation of [HSLuv](#hsluv) that maintains chroma, as the cost of only allowing pastel colors

- Import alias: `Color.fromHPLuv`
- Export alias: `Color.toHPLuv`
- Import arguments/export values:
    - The hue in degrees
        - May export a hue of NaN
    - The saturation, typically between 0 and 100
    - The lightness, between 0 and 1

## HSB (and HSV)

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/HSL_and_HSV)

- Import alias: `Color.fromHSB`, `Color.fromHSV`
- Export alias: `Color.toHSB`, `Color.toHSV`
- Import arguments/export values:
    - The hue in degrees
        - May export a hue of NaN
    - The saturation, between 0 and 1
    - The brightness (or value), between 0 and 1

## HSL

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/HSL_and_HSV)

- Import alias: `Color.fromHSL`
- Export alias: `Color.toHSL`
- Import arguments/export values:
    - The hue in degrees
        - May export a hue of NaN
    - The saturation, between 0 and 1
    - The lightness, between 0 and 1

## HSLuv

Read about this color type on [its website](https://www.hsluv.org/)

- Import alias: `Color.fromHSLuv`
- Export alias: `Color.toHSLuv`
- Import arguments/export values:
    - The hue in degrees
        - May export a hue of NaN
    - The saturation, between 0 and 1
    - The lightness, between 0 and 1

## HWB

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/HWB_color_model)

- Import alias: `Color.fromHWB`
- Export alias: `Color.toHWB`
- Import arguments/export values:
    - The hue in degrees
        - May export a hue of NaN
    - The amount of white, between 0 and 1
    - The amount of black, between 0 and 1

## Hex

- Import alias: `Color.fromHex`
- Export alias: `Color.toHex`
- Import arguments/export values:
    - The hex string in the form `RGB` or `RRGGBB`, with an optional preceding `#`

## LChab (and LCh)

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/CIELAB_color_space#Cylindrical_model)

- Import alias: `Color.fromLChab`, `Color.fromLCh`
- Export alias: `Color.toLChab`, `Color.toLCh`
- Import arguments/export values:
    - The lightness, between 0 and 1
    - The chroma, greater than or equal to 0 (typically between 0 and 1.5)
    - The hue in degrees

## LChuv

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/CIELUV#Cylindrical_representation_(CIELCh))

- Import alias: `Color.fromLChuv`
- Export alias: `Color.toLChuv`
- Import arguments/export values:
    - The lightness, between 0 and 1
    - The chroma, greater than or equal to 0 (typically between 0 and 1.5)
    - The hue in degrees

## Lab

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/CIELAB_color_space)

- Import alias: `Color.fromLab`
- Export alias: `Color.toLab`
- Import arguments/export values:
    - The lightness, between 0 and 1
    - The amount of green or red, typically between -1.28 and 1.27
        - More negative values represent green, more positive values represent red
    - The amount of blue or yellow, typically between -1.28 and 1.27
        - More negative values represent blue, more positive values represent yellow

## Luv

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/CIELUV)

- Import alias: `Color.fromLuv`
- Export alias: `Color.toLuv`
- Import arguments/export values:
    - The lightness, between 0 and 1
    - The amount of green or red, typically between -1 and 1
        - More negative values represent green, more positive values represent red
    - The amount of blue or yellow, typically between -1 and 1
        - More negative values represent blue, more positive values represent yellow

## Number

- Import alias: `Color.fromNumber`
- Export alias: `Color.toNumber`
- Import arguments/export values:
    - The RGB integer, between 0 and 16777215

## Temperature

- Import alias: `Color.fromTemperature`
- Export alias: `Color.toTemperature`
- Import arguments/export values:
    - The blackbody temperature in Kelvin

:::note
The conversions for these functions are most accurate between 1000 (one-thousand) and 40000 (forty-thousand) Kelvin.
:::

## xyY

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/CIE_1931_color_space#CIE_xy_chromaticity_diagram_and_the_CIE_xyY_color_space)

- Import alias: None
- Export alias: None
- Values
    - The x chromaticity, between 0 and 0.8
    - The y chromaticity, between 0 and 0.9
    - The luminance, between 0 and 1

## XYZ

Read about this color type on [Wikipedia](https://en.wikipedia.org/wiki/CIE_1931_color_space)

- Import alias: `Color.fromXYZ`
- Export alias: `Color.toXYZ`
- Values
    - The X tristimulus value, typically between 0 and 1
    - The luminance, between 0 and 1
    - The Z tristimulus value, typically between 0 and 1