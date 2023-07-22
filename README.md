# Color

<a href="https://roblox.com/library/7933448750"><img src="https://img.shields.io/badge/roblox-model-green.svg" alt="Install" /></a>
<a href="https://blupo.github.io/Color"><img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" /></a>

Color is a Roblox Luau library for color management and manipulation, inspired by libraries like [chroma.js](https://www.vis4.net/chromajs/) and [Color.js](https://colorjs.io/).

## Features

Some of the library's features includes:

- Importing colors from various formats
- Exporting colors to various formats
- Color interpolation in different spaces
- Creating gradients

<!--moonwave-hide-before-this-line-->
For a full introduction to the library, you can read the [documentation](https://blupo.github.io/Color/docs/intro). Some example code of the library's features is included below:

```lua
-- Accessing the modules
local ColorAPI = require(...)

local Color = ColorAPI.Color
local Gradient = ColorAPI.Gradient

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
local gradient = Gradient.fromColors(
    Color.named("red"),
    Color.named("green"),
    Color.named("blue")
)

print(gradient:color(0.6, "XYZ"):toHex()) --> "00737c"
print(gradient:color(0.6, "HSB", "Increasing"):to("Hex")) --> "00993d"

gradient:colors(50, "XYZ")
gradient:colorSequence(nil, "XYZ")
```