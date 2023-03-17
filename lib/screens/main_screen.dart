import 'package:flutter/material.dart';
import 'package:shared/utils/colors.dart';

import '../components/home_page.dart';

ThemeData mainThemeData = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: ColorModel.primary,
    onPrimary: Colors.white,
    secondary: ColorModel.secondary,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: ColorModel.background,
    onBackground: Colors.white,
    surface: ColorModel.background,
    onSurface: Colors.white,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: ColorModel.primary,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      iconColor: MaterialStateColor.resolveWith((states) => Colors.grey),
    ),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: ColorModel.secondary,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ColorModel.primary,
    foregroundColor: Colors.white,
  ),
);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared',
      theme: mainThemeData,
      home: const HomePage(),
    );
  }
}
