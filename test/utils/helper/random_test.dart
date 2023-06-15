import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/utils/helper/random.dart';

void main() {
  group('getRandom', () {
    test('getRandom() should return a random string of the specified length',
        () {
      const length = 10;
      final result = getRandom(length);

      expect(result.length, length);
    });

    test(
        'getRandom() should only contain characters from the given character set',
        () {
      const length = 10;
      final result = getRandom(length);

      const validCharacters =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
      for (var i = 0; i < result.length; i++) {
        expect(validCharacters.contains(result[i]), isTrue);
      }
    });

    test('getRandom() should return different strings for different calls', () {
      const length = 10;
      final result1 = getRandom(length);
      final result2 = getRandom(length);

      expect(result1, isNot(result2));
    });
  });
}
