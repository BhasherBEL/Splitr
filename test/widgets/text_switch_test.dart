import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/widgets/text_switch.dart';

void main() {
  group('TexteSwitch', () {
    testWidgets(
        'TextSwitch should render correctly with the provided texts and initial state',
        (WidgetTester tester) async {
      const leftText = 'Left';
      const rightText = 'Right';
      const initialState = false;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TextSwitch(
              state: initialState,
              leftText: leftText,
              rightText: rightText,
            ),
          ),
        ),
      );

      expect(find.text(leftText), findsOneWidget);
      expect(find.text(rightText), findsOneWidget);

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, initialState);
    });

    testWidgets(
        'TextSwitch should call onChanged callback when the switch state is changed',
        (WidgetTester tester) async {
      bool onChangedCalled = false;
      bool newState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextSwitch(
              state: false,
              onChanged: (bool state) {
                onChangedCalled = true;
                newState = state;
              },
            ),
          ),
        ),
      );

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(onChangedCalled, isTrue);
      expect(newState, isTrue);
    });
  });
}
