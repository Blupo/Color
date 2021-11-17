## [Unreleased]

## [0.2.0]
### Added
- Added alternative from/to functions for the various color types
    - e.g. `Color.fromColor3(...)` instead of `Color.from("Color3", ...)`
    - e.g. `Color:toColor3()` instead of `Color:to("Color3")`
- Added `Color.gray` as a shortcut for creating achromatic Colors
- Added links in the documentation for further reading on various color types

### Removed
- The `lRGB` interpolation mode has been removed, since it is the same as `XYZ` mode

### Changed
- Refined code to reduce type-check warnings
- Documentation now reflects that the Hue component for some color types can be NaN
- Static functions in the documentation now have a badge
- Read-only properties in the documentation now have a badge
- `Color.components` now allows you to obtain unclipped components
- `Color.luminance` now corrects the [error](https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187) from the equation in the definition of relative luminance

## [0.1.0] - 2021-11-09
### Added
- Initial release