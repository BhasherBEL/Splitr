import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/utils/ext/datetime.dart';

void main() {
  group('DateTimeExtension', () {
    test('operator <', () {
      final dateTime1 = DateTime(2023, 6, 15);
      final dateTime2 = DateTime(2023, 6, 16);

      expect(dateTime1 < dateTime2, true);
      expect(dateTime2 < dateTime1, false);
      expect(dateTime1 < dateTime1, false);
    });

    test('operator <=', () {
      final dateTime1 = DateTime(2023, 6, 15);
      final dateTime2 = DateTime(2023, 6, 16);

      expect(dateTime1 <= dateTime2, true);
      expect(dateTime2 <= dateTime1, false);
      expect(dateTime1 <= dateTime1, true);
    });

    test('operator >', () {
      final dateTime1 = DateTime(2023, 6, 15);
      final dateTime2 = DateTime(2023, 6, 16);

      expect(dateTime1 > dateTime2, false);
      expect(dateTime2 > dateTime1, true);
      expect(dateTime1 > dateTime1, false);
    });

    test('operator >=', () {
      final dateTime1 = DateTime(2023, 6, 15);
      final dateTime2 = DateTime(2023, 6, 16);

      expect(dateTime1 >= dateTime2, false);
      expect(dateTime2 >= dateTime1, true);
      expect(dateTime1 >= dateTime1, true);
    });
  });
}
