## [Unreleased]

### Added
- `Color.black` returns a Color with all components being 0
- `Color.white` returns a Color with all components being 1
- `Color.red` returns a Color with components (1, 0, 0)
- `Color.green` returns a Color with components (0, 1, 0)
- `Color.blue` returns a Color with components (0, 0, 1)
- `Color.cyan` returns a Color with components (0, 1, 1)
- `Color.magenta` returns a Color with components (1, 0, 1)
- `Color.yellow` returns a Color with components (1, 1, 0)
- `Color.fuzzyEq` returns if Color components are within a certain distance
- `Color.blend` now supports non-separable blending modes
- `Color`s now support math operations:
    - (These operations act on *unclipped* components)
    - Color + Color
    - Color - Color
    - Color * number
    - Color * Color (component multiplication)
    - Color / number
    - Color / Color (component division)
- `Gradient.isAGradient` checks if a value can be used as a Gradient
- `Gradient.getMaxColorSequenceKeypoints` returns the maximum number of keypoints a ColorSequence can have

### Changed
- Code refactoring and module consolidation
- Got rid of all the of type-checker warnings (for now)
- Removed most argument validation in favour of performance
- Any API functions that accept Colors will now accept any table with the necessary color structure, even if they aren't actual Colors
- `Color.isAColor` will now return `true` for tables with the necessary color structure, even if they aren't actual Colors
- `Color.isAColor` now returns a type-checking message if the value cannot be used as a Color
- `Color.bestContrastingColor` now requires 2 Colors to compare instead of 1
- `Color.random` now uses a Random object instead of `math.random`
- `Gradient.colorSequence` was renamed *back* to `Gradient.toColorSequence`

### Deprecated
- `Gradient.colorSequence` will be removed in a future release, use `Gradient.toColorSequence` instead

## [0.2.2] - 2022-04-06

### Changed
- Replaced the `Raw` hue adjustment option with `Specified` to match spec, however `Raw` will still work

## [0.2.1] - 2022-01-06

### Changed
- The `Gradient.new` constructor now creates a copy of the input table instead of using the input table itself
- `Gradient.Keypoints` is now correctly frozen, where previously it was possible to modify the individual keypoints but not the keypoint list itself

## [0.2.0] - 2021-12-01
### Added
- Added links in the documentation for further reading on various color types
- Added alternative from/to functions for the various color types
    - e.g. `Color.fromColor3(...)` instead of `Color.from("Color3", ...)`
    - e.g. `Color:toColor3()` instead of `Color:to("Color3")`
- Added `Color.gray` as a shortcut for creating achromatic colors
- Added `Color.harmonies` for generating color harmonies
- Added `Color.deltaE` for calculating color differences
- Added `Color.named` for referencing CSS colors
- Added the `xyY` color type

### Removed
- `lRGB` interpolation has been removed, since it can be done in `XYZ`

### Changed
- Refined code to reduce type-check warnings
- Documentation now reflects that the Hue component for some color types can be NaN
- Static functions in the documentation now have a badge
- Read-only properties in the documentation now have a badge
- The Color and Gradient modules of the library are now split apart
    - You can access the modules using `[Module].Color` and `[Module].Gradient`
- Updated the allowed interpolations for `Color.mix`
- `Color.isAColor` should work for Colors from different versions of the library
- `Color.components` now allows you to obtain unclipped components
- `Color.luminance` compensates for the [error](https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187) from the equation provided in WCAG 2
- `Gradient.toColorSequence` was renamed to `Gradient.colorSequence`

## [0.1.0] - 2021-11-09
### Added
- Initial release