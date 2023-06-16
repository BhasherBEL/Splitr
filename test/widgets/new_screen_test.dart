import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/widgets/new_screen.dart';

void main() {
  group('NewScreen Widget', () {
    Future<void> pumpNewScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return NewScreen(
                child: Container(),
              );
            },
          ),
        ),
      );
    }

    testWidgets('NewScreen should display child widget',
        (WidgetTester tester) async {
      await pumpNewScreen(tester);

      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('NewScreen should call onValidate when button is pressed',
        (WidgetTester tester) async {
      bool onValidateCalled = false;

      await pumpNewScreen(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return NewScreen(
                child: Container(),
                onValidate: (context, formKey) {
                  onValidateCalled = true;
                  return Future.value();
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(onValidateCalled, isTrue);
    });
  });
}
