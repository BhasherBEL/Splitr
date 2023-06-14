import 'dart:math';

String getRandom(int length) {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789';
  Random r = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => ch.codeUnitAt(
        r.nextInt(ch.length),
      ),
    ),
  );
}
