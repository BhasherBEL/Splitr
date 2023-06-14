import 'package:flutter/material.dart';

final defaultLightColorScheme = ColorScheme.fromSwatch(
  primarySwatch: Colors.red,
);

final defaultDarkColorScheme = ColorScheme.fromSwatch(
  primarySwatch: ColorModel.red,
  primaryColorDark: Colors.red,
  brightness: Brightness.dark,
  backgroundColor: Colors.black87,
);

final defaultTheme = ThemeData(
    colorScheme: defaultLightColorScheme,
    brightness: Brightness.light,
    useMaterial3: true,
    appBarTheme: AppBarTheme(backgroundColor: defaultDarkColorScheme.primary),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ));

final defaultDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: defaultDarkColorScheme,
  appBarTheme: AppBarTheme(backgroundColor: defaultDarkColorScheme.primary),
);

class ColorModel {
  static Color primary = const Color(0xff992722);
  static Color secondary = const Color(0xff229399);
  static Color background = const Color(0xff222222);
  static Color green = const Color(0xff229928);
  static Color text = const Color(0xffffffff);
  static Color orange = Colors.orange.shade600;

  static MaterialColor red = MaterialColor(
    const Color(_redPrimaryValue).withOpacity(0.8).value,
    <int, Color>{
      50: const Color(0xFFFFEBEE).withOpacity(0.8),
      100: const Color(0xFFFFCDD2).withOpacity(0.8),
      200: const Color(0xFFEF9A9A).withOpacity(0.8),
      300: const Color(0xFFE57373).withOpacity(0.8),
      400: const Color(0xFFEF5350).withOpacity(0.8),
      500: const Color(_redPrimaryValue).withOpacity(0.8),
      600: const Color(0xFFE53935).withOpacity(0.8),
      700: const Color(0xFFD32F2F).withOpacity(0.8),
      800: const Color(0xFFC62828).withOpacity(0.8),
      900: const Color(0xFFB71C1C).withOpacity(0.8),
    },
  );
  static const int _redPrimaryValue = 0xFFF44336;
}
