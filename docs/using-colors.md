---
sidebar_position: 2
---

# Using Colors

## Accessing the Module

The module has two components, Color and Gradient. You can access the Color API using `Module.Color`.

```lua
local ColorAPI = require(...)
local Color = ColorAPI.Color
```

There are also some type annotations you can access:

```lua
type BlendMode = ColorAPI.BlendMode
type HueAdjustment = ColorAPI.HueAdjustment
type Harmony = ColorAPI.Harmony

type MixableColorType = ColorAPI.MixableColorType
type ColorType = ColorAPI.ColorType

type Color = ColorAPI.Color
```

More information about these types is available in the API reference.

## Constructing Colors

There are lots of ways to create Colors. The most basic is [`Color.new`](/api/Color#new), which takes the same arguments as [`Color3.new`](https://create.roblox.com/docs/reference/engine/datatypes/Color3#new) (unlike `Color3.new`, the component arguments are not optional).

```lua
local newColor = Color.new(0.1, 0.2, 0.3)
```

There are also various other constructors for convenience.

```lua
local black = Color.black() -- Color.new(0, 0, 0)
local white = Color.white() -- Color.new(1, 1, 1)

local red = Color.red() -- Color.new(1, 0, 0)
local green = Color.green() -- Color.new(0, 1, 0)
local blue = Color.blue() -- Color3.new(0, 0, 1)

local cyan = Color.cyan() -- Color.new(0, 1, 1)
local magenta = Color.magenta() -- Color.new(1, 0, 1)
local yellow = Color.yellow() -- Color.new(1, 1, 0)

local randomColor = Color.random()
local anotherRandomColor = Color.random()

local gray = Color.gray() -- also Color.gray(0.5)
local altBlack = Color.gray(0) -- 0 is black
local altWhite = Color.gray(1) -- 1 is white

local hotpink = Color.named("hotpink")
local coral = Color.named("coral")
```

:::note
The current list of accepted names for [`Color.named`](/api/Color#named) comes from [CSS Color Module Level 3](https://www.w3.org/TR/2021/REC-css-color-3-20210805/#svg-color).
:::

## Importing Colors

Colors can also be constructed from various other types of colors, such as [BrickColor](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor)s, [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3)s, hex codes, HSL values, and much more. There are two ways to import Colors: the generic [`Color.from`](/api/Color#from), or the various import aliases (e.g. `Color.fromHex`, `Color.fromBrickColor`, etc.).

```lua
local colorFromHex = Color.from("Hex", "#bcb6be")

local anotherColorFromHex = Color.fromHex("#fa6182")
local newYeller = Color.fromBrickColor(BrickColor.new("New Yeller"))
local colorFromColor3 = Color.fromColor3(Color3.new())
local hsbColor = Color.fromHSB(241, 1, 1)
local xyzColor = Color.fromXYZ(0.9504, 1, 1.0888)
```

:::info
Currently, the only color type that doesn't have an import (or export) alias is `xyY`, and can only be accessed using `Color.from("xyY", ...)`.
:::

The full list of import aliases can be found in the [API reference](/api/Color), as well as the [complete list of color types](/api/Color#ColorType) you can import/export from.

## Exporting Colors

Colors can also be *exported* to these color types. It works similarly to importing, with the generic [`Color.to`](/api/Color#to) or an export alias. Since Colors act as class objects, you can use `color:to("SomeColorType")` instead of having to write `Color.to(color, "SomeColorType")`.

```lua
local white = Color.white()
local randomColor = Color.random()

-- These 4 do the same thing
Color.to(white, "Hex") --> ffffff
Color.toHex(white) --> ffffff
white:to("Hex") --> ffffff
white:toHex() --> ffffff
```

The full list of export aliases can be found in the [API reference](/api/Color).

## Color Operations

Colors are similar to vectors in that they have some math operations. Specifically, the following operations are supported:

- Color == Color
- Color + Color
- Color - Color
- Color \* Color, which multiplies each component separately
- Color \* number
- Color / Color, which divides each component separately
- Color / number

```lua
local black = Color.black()
local white = Color.white()
local gray = Color.gray()
local scalar = 1.5

local colorsAreTheSame = black == white --> false
local colorA = black * white --> (0, 0, 0)
local colorB = black - white --> (-1, -1, -1)
local colorC = white * scalar --> (1.5, 1.5, 1.5)
local colorD = black / gray --> (0, 0, 0)
local colorE = white / gray --> (2, 2, 2)
```

You might be thinking of using these operations to make a Color darker or brighter (i.e. by multiplying or dividing the Color). *Don't.* There are better ways to do this, demonstrated [further down](#everything-else) in this tutorial.

### Component Clamping

You may have noticed that some of the operations demonstrated aboved resulting in Colors with components outside of the typical [0, 1] range. This may seem like an error, however there are legitimate reasons for the components to be out of range. Colors (as in the Color object from this library) are a representation of sRGB, which is the current standard color space for the web and Roblox. sRGB, however, doesn't encompass all colors that are perceptible to humans, which may be represented by components outside the range [0, 1].

If you're worried about how this will affect exporting, don't be. Exporting to most color types will clamp the components to [0, 1] before conversion, specifically any export that expects sRGB. This includes [BrickColor](https://create.roblox.com/docs/reference/engine/datatypes/BrickColor)s and [Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3)s, as well as hex codes, HSB, HSL, and a few others. You can also manually check if a Color's components are unclamped using [`Color.isUnclamped`](/api/Color#isUnclamped).

## Color Functions

### Blending

Blending determines how two colors are combined when one is put on top of the other. Color blending can be done with [`Color.blend`](/api/Color#blend). For an explanation of various blending modes, you can read [this article on Sketch](https://www.sketch.com/blog/blend-modes/). The library currently supports normal, multiply, screen, color dodge, color burn, soft light, difference, exclusion, darken, lighten, hard light, overlay, hue, saturation, color, and luminosity blend modes.

### Mixing

Also called color interpolation, mixing refers to transitioning one color to another. You'll be familiar with this if you've used [`Color3.Lerp`](https://create.roblox.com/docs/reference/engine/datatypes/Color3#Lerp) before. Colors can be mixed with [`Color.mix`](/api/Color#mix).

```lua
local red = Color.red()
local aqua = Color.named("aqua")

red:mix(aqua, 0.5) -- equal mix of red and aqua
red:mix(aqua, 0.75) -- closer to aqua
red:mix(aqua, 0.25) -- closer to red
```

[Color3](https://create.roblox.com/docs/reference/engine/datatypes/Color3)s and Colors by default interpolate using RGB. Here's what that sequence looks like with red and aqua:

![RGB interpolaiton of red and aqua](/rgb-interpolation.png)

You may notice that the sequence goes through gray in the middle. If you want to know why that is (and why other RGB interpolations might not look the way you expect), you can read [this article on Programming Design Systems](https://programmingdesignsystems.com/color/perceptually-uniform-color-spaces/). To fix this, we need to change the space we interpolate in. [`Color.mix`](/api/Color#mix) allows you to interpolate Colors in several different spaces, and the complete list is available [in the API](/api/Enums#MixableColorType).

If you want to preserve uniformity, you should use `Lab` or `Luv` (or their cylindrical representations, `LChab` and `LChuv`). Here's what they look like:

| Code | Sequence |
|-|-|
| `red:mix(aqua, ..., "Lab")` | ![Lab interpolaiton of red and aqua](/lab-interpolation.png) |
| `red:mix(aqua, ..., "Luv")` | ![Luv interpolaiton of red and aqua](/luv-interpolation.png) |
| `red:mix(aqua, ..., "LChab")` | ![LCh(ab) interpolaiton of red and aqua](/lchab-interpolation.png) |
| `red:mix(aqua, ..., "LChuv")` | ![LCh(uv) interpolaiton of red and aqua](/lchuv-interpolation.png) |

### Contrast

Colors have functions that let you check their contrast against other Colors. These functions are [`Color.contrast`](/api/Color#contrast), which returns the contrast between two Colors, and [`Color.bestContrastingColor`](/api/color#bestContrastingColor), which returns the best-contrasting Color and its contrast.

Note: Contrast calculations are implemented from [WCAG 2.0](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef).

```lua
local black = Color.black()
local white = Color.white()
local red = Color.red()
local blue = Color.blue()

black:contrast(white) --> 21
red:contrast(blue) --> 2.14

black:bestContrastingColor(white, red, blue) --> white, 21
red:bestContrastingColor(white, blue) --> white, 3.99
```

### Color Difference

Color difference refers to the distance between two colors. ΔE* (also known as Delta E), are a family of algorithms that calculate color difference. The most accurate (and newest) of these is CIEDE2000, which is what the library uses, via [`Color.deltaE`](/api/Color#deltaE).

The number returned by the function indicates the difference between the two Colors. Larger numbers indicate less similar Colors, while smaller numbers indicate more similarity. A ΔE* of 2.3 is a [just-noticable difference](https://en.wikipedia.org/wiki/Just-noticeable_difference), and values less than that indicate the two Colors are very difficult (or impossible) to tell apart. This function is also commutative, i.e. `a:deltaE(b)` is the same as `b:deltaE(a)`.

```lua
local red = Color.red()
local redAlt = Color.fromRGB(255, 25, 0)
local black = Color.black()
local white = Color.white()

red:deltaE(black) -- 50.4067
red:deltaE(redAlt) -- 1.2914
black:deltaE(white) -- 100
white:deltaE(black) -- 100
```

### Harmonies

Color harmony refers to the aesthetic property that certain color combinations have. You can generate harmonic Colors using [`Color.harmonies`](/api/Color#harmonies).

```lua
local red = Color.red()
local blue = Color.blue()
local redBlueMix = red:mix(blue, 0.5)

red:harmonies("Square")
redBlueMix:harmonies("Analogous", 20)
```

### Everything Else

You can change the brightness of Colors using [`Color.brighten`](/api/Color#brighten) and [`Color.darken`](/api/Color#darken). These functions manipulate Colors in CIELAB, which should result in more perceptually-uniform results than doing `color * n` or `color / n`.

```lua
local randomColor = Color.random()
local white = Color.white()

white:darken(2)
randomColor:brighten() -- randomColor:brighten(1)
```

There are similar functions for changing the saturation of Colors, [`Color.saturate`](/api/Color#saturate) and [`Color.desaturate`](/api/Color#desaturate).

```lua
local dullBlue = Color.fromRGB(60, 70, 100)
local vibrantBlue = Color.fromHSB(240, 0.85, 1)

dullBlue:saturate(2)
vibrantBlue:desaturate() -- vibrantBlue:desaturate(1)
```

## Tips and Tricks

### Chaining

Most Color functions return another Color, so you can chain them together:

```lua
local randomColor = Color.random()
local anotherRandomColor = Color.random()

randomColor
    :blend(anotherRandomColor, "Multiply")
    :brighten(0.5)
    :invert()
    :mix(anotherRandomColor, 0.5, "XYZ")
    :toHex()
```