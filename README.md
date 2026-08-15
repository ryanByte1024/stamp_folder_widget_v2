# stamp_folder_widget_v2

English | [简体中文](./README.zh-CN.md)

A reusable Flutter package for rendering a stylized folder with a rounded back panel, a frosted folding pocket, and three configurable image cards. Its geometry and motion use a fixed `520 x 582` reference canvas for consistent rendering at every size.

## Features

- Reusable Flutter package API
- Configurable overall size
- Configurable front pocket colors
- Configurable back panel colors
- Configurable external stamp image source, position, size, rotation, and tint
- Three-state idle, engaged, and expanded motion aligned to the reference animation
- Reversible click interaction with lift, front-pocket fold, and staggered card reveal
- Smooth animated palette changes
- Supports `AssetImage`, `NetworkImage`, and other `ImageProvider` sources
- Example app included

## Installation

```yaml
dependencies:
  stamp_folder_widget_v2: ^1.0.0
```

For local development:

```yaml
dependencies:
  stamp_folder_widget_v2:
    path: ../stamp_widget_v2
```

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:stamp_folder_widget_v2/stamp_folder_widget_v2.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: const AssetImage('assets/example.webp'),
    );

    return Center(
      child: StampFolderWidget(width: 760, stamps: stamps),
    );
  }
}
```

You can customize the artwork with size, panel colors, labels, and stamp layout:

```dart
import 'package:flutter/material.dart';
import 'package:stamp_folder_widget_v2/stamp_folder_widget_v2.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final baseImage = const AssetImage('assets/example.webp');
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: baseImage,
    );
    final customizedStamps = [
      stamps[0],
      stamps[1].copyWith(
        leftFactor: 0.41,
        tint: const Color(0x3378A66A),
      ),
      stamps[2].copyWith(
        rightFactor: 0.16,
        topFactor: 0.245,
      ),
    ];

    return Center(
      child: StampFolderWidget(
        width: 820,
        title: 'STAMP',
        subtitle: 'Collection',
        frontPanelColors: const [
          Color(0xFFF7F0E3),
          Color(0xFFE8DFC7),
          Color(0xFFF7F2EA),
        ],
        backPanelColors: const [
          Color(0xFFF8F2E6),
          Color(0xFFF1E7D6),
          Color(0xFFFBF7F0),
        ],
        stamps: customizedStamps,
      ),
    );
  }
}
```

## Main API

- `StampFolderWidget`
- `StampFolderStampData`

## Configurable Parameters

### Widget Size

- `width`: outer widget width
- `height`: outer widget height
- `aspectRatio`: overall layout ratio when height is not fixed
- `padding`: inner spacing around the artwork

### Folder Appearance

- `frontPanelColors`: gradient colors for the frosted front pocket
- `backPanelColors`: gradient colors for the rear panel
- `frontEdgeGlowColor`: glow color around the front pocket edge
- `backEdgeGlowColor`: glow color around the rear panel edge
- `title`: main label on the front pocket
- `subtitle`: secondary label on the front pocket
- `labelColor`: text and leaf decoration color
- `showLeafDecoration`: whether to show the leaf decoration
- `showStampBorders`: globally show or hide the white image borders

### Open Animation

- `enableTapAnimation`: enables tap-to-open and tap-to-close behavior
- `initiallyOpen`: controls the initial open state
- `animationDuration`: controls the opening duration
- `liftAnimationDuration`: controls the idle-to-engaged lift phase
- `frontOpenAnimationDuration`: controls the front-pocket fold and card reveal phase
- `reverseAnimationDuration`: controls the closing duration
- `colorTransitionDuration`: controls palette transition duration
- `openLiftFactor`: controls how far the whole folder rises while opening
- `openFrontScale`: controls the front-pocket foreshortening while it folds toward the user
- `semanticsLabel`: accessible label for the interactive folder
- `onOpenChanged`: reports the new open state after a tap

### Stamp Configuration

Pass exactly 3 `StampFolderStampData` items to `stamps`.

Each `StampFolderStampData` supports:

- `imageProvider`
- `leftFactor`
- `rightFactor`
- `topFactor`
- `widthFactor`
- `heightFactor`
- `rotation`
- `tint`
- `showBorder`
- `fit`
- `borderRadius`
- `borderWidth`
- `borderColor`
- `shadowColor`
- `shadowBlurRadius`
- `shadowOffset`

## Notes

- The widget expects exactly 3 stamp items when `stamps` is provided.
- If fewer than 3 panel colors are passed, the package automatically resolves them into a usable gradient set.
- The package no longer bundles a built-in stamp image. Provide your own image source from the host app.
- The example app in [`example/lib/main.dart`](./example/lib/main.dart) shows a complete package usage setup.
- The measured geometry and animation contract is documented in [`FOLDER_SHAPE_ANIMATION_SPEC.md`](docs/FOLDER_SHAPE_ANIMATION_SPEC.md).

## Development

```bash
flutter analyze
flutter test
```
