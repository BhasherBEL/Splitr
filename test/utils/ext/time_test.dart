import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/utils/ext/time.dart';

void main() {
  group('DateExtension', () {
    late DateTime now;

    setUp(() {
      now = DateTime(
          2023, 6, 15, 12, 0, 0); // Set a specific date and time for testing
    });

    test('toDate() should format the date correctly for current year', () {
      final date = DateTime(DateTime.now().year, 5, 25);
      final result = date.toDate();
      expect(result, '25th May');
    });

    test('toDate() should format the date correctly for previous year', () {
      final date = DateTime(2022, 5, 25);
      final result = date.toDate();
      expect(result, '25th May 2022');
    });

    test('toPocketTime() should format the date and time correctly', () {
      final date = DateTime(2023, 5, 25, 8, 30, 0);
      final result = date.toPocketTime();
      expect(result, '2023-05-25 08:30:00');
    });

    test('getFullDate() should return the full formatted date', () {
      final date = DateTime(2023, 5, 25);
      final result = date.getFullDate();
      expect(result, '25 May 2023');
    });

    test('getDay() should return a new DateTime with the same day', () {
      final date = DateTime(2023, 5, 25, 8, 30, 0);
      final result = date.getDay();
      expect(result, DateTime(2023, 5, 25));
    });

    test('daysElapsed() should return the correct days elapsed', () {
      final date = DateTime.now().subtract(const Duration(days: 3));
      final result = date.daysElapsed();
      expect(result, '3 days ago');
    });

    test(
        'daysSince() should return the correct number of days since the given date',
        () {
      final date = DateTime(2023, 5, 10);
      final result = now.daysSince(date);
      expect(result, 36);
    });

    test('daysTo() should return the correct number of days to the given date',
        () {
      final date = DateTime(2023, 6, 20);
      final result = now.daysTo(date);
      expect(result, 5);
    });

    test('timeElapsed() should return the correct time elapsed', () {
      final date = DateTime.now().subtract(const Duration(hours: 1));
      final result = date.timeElapsed();
      expect(result, '1 hour ago');
    });
  });
}
