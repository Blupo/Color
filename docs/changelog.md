## [Unreleased]

## [0.2.0]
### Added
- Added alternative from/to functions for the various color types
    - e.g. `Color.fromColor3(...)` instead of `Color.from("Color3", ...)`
    - e.g. `Color:toColor3()` instead of `Color:to("Color3")`

### Changed
- Refined code to reduce type-check warnings
- Added more type annotations
- Docs reflect that Hue for some color types can be NaN

## [0.1.0] - 2021-11-09
### Added
- Initial release