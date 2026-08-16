import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_folder_widget_v2/stamp_folder_widget_v2.dart';

final _transparentImage = Uint8List.fromList(const <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0xF8,
  0xCF,
  0xC0,
  0x00,
  0x00,
  0x03,
  0x01,
  0x01,
  0x00,
  0xC9,
  0xFE,
  0x92,
  0xEF,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  test('default cards use the portrait full-image layout', () {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    );

    expect(stamps, hasLength(3));
    expect(stamps[0].leftFactor, 120 / 520);
    expect(stamps[0].topFactor, 84 / 582);
    expect(stamps[0].widthFactor, 108 / 520);
    expect(stamps[0].heightFactor, 144 / 582);
    expect(stamps[1].topFactor, 96 / 582);
    expect(stamps[1].widthFactor, 117 / 520);
    expect(stamps[1].heightFactor, 156 / 582);
    expect(stamps[2].topFactor, 84 / 582);
    expect(stamps[2].widthFactor, 108 / 520);
    expect(stamps[2].heightFactor, 144 / 582);
    expect(stamps[2].rightFactor, 120 / 520);
    expect(
      stamps.every(
        (stamp) => stamp.displayMode == StampImageDisplayMode.containWithBlur,
      ),
      isTrue,
    );
  });

  test('supports a dynamic image aspect ratio', () {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
      imageAspectRatio: 0.72,
    );

    expect(
      stamps,
      everyElement(
        predicate<StampFolderStampData>((stamp) {
          return stamp.imageAspectRatio == 0.72 &&
              stamp.displayMode == StampImageDisplayMode.cover;
        }),
      ),
    );
  });

  testWidgets('renders the stamp folder package widget', (
    WidgetTester tester,
  ) async {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: StampFolderWidget(width: 720, stamps: stamps)),
        ),
      ),
    );

    expect(find.byType(StampFolderWidget), findsOneWidget);
    expect(find.text('Designs'), findsOneWidget);
    expect(find.text('Collection'), findsNothing);
  });

  testWidgets('renders a blurred backdrop for full-image cards', (
    WidgetTester tester,
  ) async {
    final stamp = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    ).first;

    await tester.pumpWidget(
      MaterialApp(home: StampCard(data: stamp, width: 108, height: 144)),
    );

    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));
  });

  testWidgets('opens and closes when tapped', (WidgetTester tester) async {
    final states = <bool>[];
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StampFolderWidget(
              width: 720,
              stamps: stamps,
              animationDuration: const Duration(milliseconds: 700),
              liftAnimationDuration: const Duration(milliseconds: 180),
              frontOpenAnimationDuration: const Duration(milliseconds: 180),
              onOpenChanged: states.add,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(StampFolderWidget));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(StampFolderWidget));
    await tester.pumpAndSettle();

    expect(states, [true, false]);
  });

  testWidgets('supports dynamically adding and removing up to three cards', (
    WidgetTester tester,
  ) async {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    );
    final visibleCount = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: visibleCount,
            builder: (context, count, _) => StampFolderWidget(
              stamps: stamps.take(count).toList(growable: false),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(StampCard), findsNothing);

    visibleCount.value = 1;
    await tester.pump();
    expect(find.byType(StampCard), findsOneWidget);

    visibleCount.value = 3;
    await tester.pump();
    expect(find.byType(StampCard), findsNWidgets(3));

    visibleCount.value = 2;
    await tester.pump();
    expect(find.byType(StampCard), findsNWidgets(2));

    visibleCount.value = 0;
    await tester.pump();
    expect(find.byType(StampCard), findsNothing);

    await tester.pumpWidget(const SizedBox());
    visibleCount.dispose();
  });

  testWidgets('rejects more than three cards', (WidgetTester tester) async {
    final stamps = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    );

    await tester.pumpWidget(
      MaterialApp(home: StampFolderWidget(stamps: [...stamps, stamps.first])),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('supports configurable folder edge borders', (
    WidgetTester tester,
  ) async {
    const frontBorderColor = Color(0xFFEF8354);
    const backBorderColor = Color(0xFF2D3047);

    await tester.pumpWidget(
      MaterialApp(
        home: StampFolderWidget(
          frontBorderColor: frontBorderColor,
          frontBorderWidth: 4,
          backBorderColor: backBorderColor,
          backBorderWidth: 3,
        ),
      ),
    );

    final frontPocket = tester.widget<FrontPocket>(find.byType(FrontPocket));
    final backPanel = tester.widget<FolderBackPanel>(
      find.byType(FolderBackPanel),
    );

    expect(frontPocket.borderColor, frontBorderColor);
    expect(frontPocket.borderWidth, 4);
    expect(backPanel.borderColor, backBorderColor);
    expect(backPanel.borderWidth, 3);
  });

  test('copyWith preserves layout and updates card appearance', () {
    final stamp = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    ).first;
    final changed = stamp.copyWith(
      borderWidth: 4,
      shadowBlurRadius: 16,
      rotation: 0.2,
    );

    expect(changed.leftFactor, stamp.leftFactor);
    expect(changed.borderWidth, 4);
    expect(changed.shadowBlurRadius, 16);
    expect(changed.rotation, 0.2);

    final fullImage = changed.copyWith(
      displayMode: StampImageDisplayMode.containWithBlur,
    );
    expect(fullImage.displayMode, StampImageDisplayMode.containWithBlur);
  });

  testWidgets('can hide an individual stamp border', (
    WidgetTester tester,
  ) async {
    final stamp = StampFolderWidget.buildDefaultStamps(
      imageProvider: MemoryImage(_transparentImage),
    ).first.copyWith(showBorder: false);

    await tester.pumpWidget(
      MaterialApp(home: StampCard(data: stamp, width: 128, height: 124)),
    );

    final outerDecoration = tester.widget<DecoratedBox>(
      find.byType(DecoratedBox).first,
    );
    final decoration = outerDecoration.decoration as BoxDecoration;
    expect(decoration.color, Colors.transparent);
  });
}
