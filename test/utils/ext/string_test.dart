import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/utils/ext/string.dart';

void main() {
  group('StringExtension', () {
    test(
        'capitalize() should capitalize the first letter and lowercase the remaining letters',
        () {
      expect('hEllo WoRlD'.capitalize(), 'Hello world');
    });

    test('capitalize() should handle an empty string', () {
      expect(''.capitalize(), '');
    });

    test(
        'firstCapitalize() should capitalize the first letter without changing the remaining letters',
        () {
      expect('hello World'.firstCapitalize(), 'Hello World');
    });

    test('firstCapitalize() should handle an empty string', () {
      expect(''.firstCapitalize(), '');
    });

    test('firstCapitalize() should handle a string with only one character',
        () {
      expect('a'.firstCapitalize(), 'A');
    });
  });
}
