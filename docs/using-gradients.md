---
sidebar_position: 3
---

# Using Gradients

:::note
This guide assumes you've already read the [introduction to Colors](/docs/using-colors).
:::

## Accessing the Module

The module has two components, Color and Gradient. You can access the Gradient API using `Module.Gradient`.

```lua
local ColorAPI = require(...)

local Color = ColorAPI.Color
local Gradient = ColorAPI.Gradient
```

There are also some type annotations you can access:

```lua
type HueAdjustment = ColorAPI.HueAdjustment
type Harmony = ColorAPI.Harmony
type MixableColorType = ColorAPI.MixableColorType

type Gradient = ColorAPI.Gradient
```

More information about these types is available in the API reference.

## Constructing Gradients

Gradients can be constructed in 3 ways:

- From a list of keypoints
- From a list of Colors
- From a [`ColorSequence`](https://create.roblox.com/docs/reference/engine/datatypes/ColorSequence)

```lua
local red = Color.red()
local blue = Color.blue()

local colorSequence = ColorSequence.new(Color.random():toColor3(), Color.random():toColor3())

---

local rbGradient = Gradient.new({ -- From a list of keypoints
    { Time = 0, Color = red },
    { Time = 1, Color = blue }
})

local rbGradientAlt = Gradient.fromColors(red, blue) -- From a list of Colors, same as rbGradient
local rndGradient = Gradient.fromColorSequence(colorSequence) -- From a ColorSequence
```

## Generating Colors

Gradients can be used to generate intermediate Colors.

```lua
local gradient = Gradient.new(Color.random(), Color.random(), Color.random())

gradient:color(0.4, "Lab") -- generate a single Color using CIELAB interpolation
gradient:colors(5, "Lab") -- generate 5 Colors using CIELAB interpolation that are equidistant in time
```

## Generating ColorSequences

Color3s use RGB interpolation, and subsequently so do ColorSequences. To get around this, we can generate a ColorSequence filled with keypoints that were interpolated in a different space. This won't change the underlying RGB interpolation, but will at least give the appearance of a non-RGB interpolation.

```lua
local red = Color.red()
local aqua = Color.named("aqua")

local gradient = Gradient.new(red, aqua)
local colorSequence = gradient:toColorSequence(nil, "Lab") -- generate a ColorSequence with as many keypoints as possible, using CIELAB interpolation
```