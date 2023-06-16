import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/widgets/header_tile.dart';

void main() {
  testWidgets('HeaderTile should render correctly with the provided text',
      (WidgetTester tester) async {
    const text = 'Header Title';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeaderTile(
            text,
            smallCaps: false,
          ),
        ),
      ),
    );

    expect(find.text(text), findsOneWidget);
  });
}
