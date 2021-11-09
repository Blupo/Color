## Types

### GradientKeypoint

```
{
    Time: number,
    Color: Color
}
```

`Time` must be in the range [0, 1].

## Constructors

### Color.gradient

```
Color.gradient(keypoints: array<GradientKeypoint>): Gradient
```

Standard Gradient constructor. The first keypoint must have a `Time` of 0, and the last keypoint must have a `Time` of 1. (Consequently, there must be at least 2 keypoints.) The keypoint list must be sorted by time.

!!! warning
    The keypoint list will be frozen once passed to the constructor. If you know that you will need to modify the list later, you should pass a copy instead.

---

### Color.gradientFromColors

```
Color.gradientFromColors(...: Color): Gradient
```

Creates a Gradient from one or more Colors. If one Color is passed, the start and end keypoints will have the same color. If two Colors are passed, the start and end keypoints will have the first and second color, respectively. If 3 or more Colors is passed, the keypoints will be equidistant with respect to time.

---

### Color.gradientFromColorSequence

```
Color.gradientFromColorSequence(colorSequence: ColorSequence): Gradient
```

Creates a Gradient from a [ColorSequence](https://developer.roblox.com/en-us/api-reference/datatype/ColorSequence).

---

## Properties

### Gradient.Keypoints

```
Gradient.Keypoints: array<GradientKeypoint>
```

The keypoint list is read-only.

---

## Functions

### Gradient.invert

```
Gradient.invert(gradient: Gradient): Gradient
```

Returns a Gradient with reversed keypoints.

---

### Gradient.color

```
Gradient.color(gradient: Gradient, time: number, mode: string? = "RGB", hueAdjustment: string? = "Shorter"): Color
```

Returns a Color from the Gradient at the specified `time`, which should be in the range [0, 1]. `mode` is a [color mixing](color.md#colormix) mode.

---

### Gradient.colors

```
Gradient.colors(gradient: Gradient, amount: number?, mode: string? = "RGB", hueAdjustment: string? = "Shorter"): array<Color>
```

Returns an array of `amount` equidistant colors, using the [mixing `mode`](color.md#colormix). If `amount` is not specified, the function returns a copy of the GradientKeypoints used to construct it.

---

### Gradient.toColorSequence

```
Gradient.toColorSequence(gradient: Gradient, steps: number? = 20, mode: string? = "RGB", hueAdjustment: string? = "Shorter"): ColorSequence
```

Returns a [ColorSequence](https://developer.roblox.com/en-us/api-reference/datatype/ColorSequence) with `steps` equidistant colors. If the [mixing `mode`](color.md#colormix) is RGB, the ColorSequence will instead consist of the colors from the GradientKeypoints used to construct it.

!!! info
    Due to an engine limitation that only allows up to 20 keypoints in a ColorSequence, you may notice differences between the ColorSequence's intermediate colors and the Gradient's intermediate colors if you are using a mixing mode other than RGB.

## Math Operations

### Gradient == Gradient

Comparing Gradients with `==` checks if they have the same number of keypoints, that the keypoints have the same Time values, and that the keypoints have the same Color values (using [Color.unclippedEq](color.md#colorunclippedeq)).

```lua
local gradient1 = Color.gradientFromColors(
    Color.new(0, 0, 0),
    Color.new(1, 1, 1)
)

local gradient2 = Color.gradient({
    {Time = 0, Color = Color.new(0, 0, 0)},
    {Time = 1, Color = Color.new(1, 1, 1)}
})

local gradient3 = Color.gradient({
    {Time = 0, Color = Color.new(1, 1, 1)},
    {Time = 1, Color = Color.new(0, 0, 0)}
}) 

print(gradient1 == gradient2) --> true
print(gradient1 == gradient3) --> false
print(gradient1 == gradient3:invert()) --> true
```