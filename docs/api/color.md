## Constructors

### Color.new

```
Color.new(r: number, g: number, b: number): Color
```

Standard Color constructor. Arguments should be in the range [0, 1], similar to [Color3.new](https://developer.roblox.com/en-us/api-reference/datatype/Color3#constructors).

---

### Color.random

```
Color.random(): Color
```

Creates a Color with random RGB components.

---

### Color.from

```
Color.from(colorType: string, ...: any): Color
```

Creates a Color from various color types. See the [Color Types](#color-types) section for the list of available conversions and what arguments they require.

!!! info
    You can also use an alternative constructor using `Color.from[ColorType]`, e.g. `Color.fromColor3(...)` instead of `Color.from("Color3", ...)`.

---

## Properties

### Color.R

```
Color.R: number
```

The [clipped](#colorisclipped) red RGB channel of the color, in the range [0, 1]. Read-only.

---

### Color.G

```
Color.G: number
```

The [clipped](#colorisclipped) green RGB channel of the color, in the range [0, 1]. Read-only.

---

### Color.B

```
Color.B: number
```

The [clipped](#colorisclipped) blue RGB channel of the color, in the range [0, 1]. Read-only.

---

## Functions

### Color.isAColor

```
Color.isAColor(color: any): boolean
```

Returns whether the provided value behaves as a Color.

---

### Color.isClipped

```
Color.isClipped(color: Color): boolean
```

Returns whether the Color's RGB components are clipped. Some conversions (e.g. XYZ to sRGB) may result in RGB components outside of the range [0, 1]. In this case, the components will be clipped to the range [0, 1].

```lua
print(Color.new(1, 1, 1):isClipped()) --> false
print(Color.new(2, 2, 2):isClipped()) --> true
```

---

### Color.unclippedEq

```
Color.unclippedEq(refColor: Color, testColor: Color): boolean
```

Returns whether the [*unclipped*](#colorisclipped) components of two Colors are equal.

```lua
print(Color.new(1, 1, 1) == Color.new(2, 2, 2)) --> true
print(Color.new(1, 1, 1):unclippedEq(Color.new(2, 2, 2))) --> false
```

---

### Color.components

```
Color.components(color: Color): (number, number, number)
```

Returns the [clipped](#colorisclipped) RGB components of the Color in the range [0, 1]. You can also access the individual components using [Color.R](#colorr), [Color.G](#colorg), and [Color.B](#colorb).

---

### Color.to

```
Color.to(color: Color, colorType: string): ...any
```

Converts a color to different formats. See the [Color Types](#color-types) section for the list of available conversions and what values they output.

!!! info
    You can also use an alternative converter using `Color.to[ColorType]`, e.g. `Color:toColor3()` instead of `Color:to("Color3")`.

---

### Color.invert

```
Color.invert(color: Color): Color
```

Returns a Color with inverted RGB components.

---

### Color.mix

```
Color.mix(startColor: Color, endColor: Color, ratio: number, mode: string? = "RGB", hueAdjustment: string? = "Shorter"): Color
```

Interpolates the start and end Colors in various mixing modes. Available mixing modes are: `RGB` (default), `lRGB`, `CMYK`, `HSB` (or `HSV`), `HWB`, `HSL`, `Lab`, `Luv`, `LChab` (or `LCh`), `LChuv`, and `XYZ`. The `ratio` should be in the range [0, 1].

For color spaces with a hue component (e.g. HSB/L or LCh), there are different ways to interpolate the hue, and you can specify how it should be done, either `Shorter` (default), `Longer`, `Increasing`, `Decreasing`, or `Raw`. These adjustments correspond to those specified in [CSS Color Module Level 4](https://www.w3.org/TR/css-color-4/#hue-interpolation).

---

### Color.blend

```
Color.blend(baseColor: Color, topColor: Color, mode: string): Color
```

Blends the base and top Colors in various mixing modes. Available blending modes are: `Normal`, `Multiply`, `Screen`, `Overlay`, `Darken`, `Lighten`, `ColorDodge`, `ColorBurn`, `HardLight`, `SoftLight`, `Difference`, and `Exclusion`.

---

### Color.luminance

```
Color.luminance(color: Color): number
```

Returns the [relative luminance](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#relativeluminancedef) of the Color.

---

### Color.contrast

```
Color.contrast(refColor: Color, testColor: Color): number
```

Returns the [contrast ratio](https://www.w3.org/TR/2008/REC-WCAG20-20081211/#contrast-ratiodef) between the two Colors.

---

### Color.bestContrastingColor

```
Color.bestContrastingColor(refColor: Color, ...: Color): (Color, number)
```

Returns the Color with the highest contrast ratio to the reference color, along with the contrast ratio itself.

---

### Color.brighten

```
Color.brighten(color: Color, amount: number? = 1): Color
```

Brightens a Color by modifying its L* (L\*a\*b\*) component.

---

### Color.darken

```
Color.darken(color: Color, amount: number? = 1): Color
```

Equivalent to `Color.brighten(color, -amount)`.

---

### Color.saturate

```
Color.saturate(color: Color, amount: number? = 1): Color
```

Saturates a Color by modifying its C* (L\*C\*h) component.

---

### Color.desaturate

```
Color.desaturate(color: Color, amount: number? = 1): Color
```

Equivalent to `Color.saturate(color, -amount)`.

---

## Math Operations

### Color == Color

Comparing Colors with `==` returns whether their [clipped](#colorisclipped) RGB components are the same.

```lua
print(Color.new(0, 0, 0) == Color.new(0, 0, 0)) --> true
print(Color.new(0, 0, 0) == Color.new(1, 1, 1)) --> false
print(Color.new(1, 1, 1) == Color.new(2, 2, 2)) --> true
```

---

## Color Types

### BrickColor

- `color: BrickColor`

---

### Color3

- `color: Color3`

---

### Hex

- `hex: string`

The hex string can be in the format `ABC` or `AABBCC`, with or without a leading `#`.

---

### Number

- `color: number` [0, 16777215]

---

### RGB

- `r: number` [0, 255]
- `g: number` [0, 255]
- `b: number` [0, 255]

---

### HSB

- `h: number` [0, 360) or NaN
- `s: number` [0, 1]
- `b: number` [0, 1]

---

### HSV

Alias for [`HSB`](#hsb)

---

### HWB

- `h: number` [0, 360) or NaN
- `w: number` [0, 1]
- `b: number` [0, 1]

---

### HSL

- `h: number` [0, 360) or NaN
- `s: number` [0, 1]
- `l: number` [0, 1]

---

### CMYK

- `c: number` [0, 1]
- `m: number` [0, 1]
- `y: number` [0, 1]
- `k: number` [0, 1]

---

### Temperature

- `kelvin: number`

For best results, use temperatures in the range [1000, 40000].

---

### XYZ

- `x: number` [0, 1] (typical)
- `y: number` [0, 1]
- `z: number` [0, 1] (typical)

---

### Lab

- `l: number` [0, 1]
- `a: number` [-1.28, 1.27] (typically)
- `b: number` [-1.28, 1.27] (typically)

---

### LChab

- `l: number` [0, 1]
- `c: number` [0, 1.50] (typically)
- `h: number` [0, 360)

---

### LCh

Alias for [`LChab`](#lchab)

---

### Luv

- `l: number` [0, 1]
- `u: number` [-1, 1] (typically)
- `v: number` [-1, 1] (typically)

---

### LChuv

- `l: number` [0, 1]
- `c: number` [0, 1.50] (typically)
- `h: number` [0, 360)