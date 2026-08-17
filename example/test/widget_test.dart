import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_folder_widget_example/main.dart';

void main() {
  testWidgets('renders the package example', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Summer Escape'), findsOneWidget);
    expect(find.text('3 stamps'), findsOneWidget);
    expect(find.byKey(const ValueKey('palette-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('palette-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('palette-2')), findsOneWidget);
    expect(find.byKey(const ValueKey('stamp-count-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('stamp-count-3')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('palette-1')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('stamp-count-0')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('0 stamps'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('stamp-count-3')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });
}
