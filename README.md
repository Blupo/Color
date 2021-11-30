# Color

<a href="https://roblox.com/library/7933448750"><img src="https://img.shields.io/badge/roblox-model-green.svg" alt="Install" /></a>
<a href="https://blupo.github.io/Color"><img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" /></a>

Color is a Roblox Luau library for color management and manipulation, inspired by [chroma.js](https://vis4.net/chromajs/).

## Installing

The module is available in the library [here](https://roblox.com/library/7933448750) if you want to install it using the Toolbox. You can also grab a [release](https://github.com/Blupo/Color/releases) from GitHub and install it manually.

If you know how to use [Rojo](https://rojo.space), you can build the latest code from the development branch to get the newest features. Keep in mind that this is **development code**, and things can break or change quickly.

## Features

Some of the library's features includes:

- Reading colors from many different formats
- Converting colors to many different formats
- Color interpolation in different spaces
- Creating gradients

```lua
-- Constructors
local pink = Color.fromHex("#ff69b4")
local blue = Color.from("HSB", 240, 1, 1)
local yellow = Color.fromLab(0.97139, -0.21554, 0.94478)

local newYeller = Color.fromBrickColor(BrickColor.new("New Yeller"))
local white = Color.new(1, 1, 1) -- or Color.gray(1)

local hotpink = Color.named("hotpink")

-- Conversions
print(blue:toHex()) --> "0000ff"
print(blue:toHSB()) --> 240, 1, 1
print(blue:to("Lab")) --> 0.32297, 0.79188, -1.07860
print(blue:components()) --> 0, 0, 1

-- Interpolation
local red = Color.named("red")
local aqua = Color.named("aqua")

red:mix(aqua, 0.5)
red:mix(aqua, 0.5, "XYZ")
red:mix(aqua, 0.5, "Lab")
red:mix(aqua, 0.5, "Luv")

-- Gradients
local gradient = Color.gradientFromColors(
    Color.named("red"),
    Color.named("green"),
    Color.named("blue")
)

print(gradient:color(0.6, "XYZ"):toHex()) --> "00737c"
print(gradient:color(0.6, "HSB", "Increasing"):to("Hex")) --> "00993d"

gradient:colors(50, "XYZ")
gradient:colorSequence(nil, "XYZ")
```

For a full introduction to the library, you can read the [documentation](https://blupo.github.io/Color).