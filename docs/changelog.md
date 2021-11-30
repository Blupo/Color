## [Unreleased]

## [0.2.0]
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
- `Color.components` now allows you to obtain unclipped components
- `Color.luminance` compensates for the [error](https://www.w3.org/WAI/GL/wiki/index.php?title=Relative_luminance&oldid=11187) from the equation provided in WCAG 2
- `Gradient.toColorSequence` was renamed to `Gradient.colorSequence`

## [0.1.0] - 2021-11-09
### Added
- Initial release