# Changelog

## 0.1.3

- Added the `showShadow` switch for the folder floating shadow and stamp card shadows; it defaults to `true` to preserve the existing appearance.
- Added `enableDecorativeEffects` and `filterQuality` options to reduce raster work in dense thumbnail layouts without changing the default visual style.
- Added per-stamp repaint boundaries and reduced decorative texture draw calls to improve scrolling performance.


## 0.1.2

- Added independent front-pocket title and subtitle offsets that follow the pocket during its opening animation.
- Added separate `TextStyle` configuration for the folder name and content count, including font family, size, color, weight, and spacing.
- Updated the example to show a polished folder name and dynamic stamp count in the front pocket.

## 0.1.1

- Changed stamp content to support dynamic lists from 0 to 3 images; more than 3 images are rejected.
- Added independent front-pocket and rear-panel border color and width parameters.
- Enhanced the example with a 0-to-3 image count selector and folder border configuration.

## 0.1.0

- Rebuilt the artwork on a fixed 520 x 582 reference canvas.
- Added idle, engaged, and expanded animation states with separate open, close, and palette timings.
- Added accessibility labeling, animated palettes, card borders, and card shadows.
- Added configurable global and per-card image borders; interaction is now click-only.
- Added independent lift and front-open animation duration controls.
- Updated the example with three external images and blue, yellow, and green palette controls.
