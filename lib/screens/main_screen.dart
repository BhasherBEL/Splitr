import 'package:flutter/material.dart';

import '../components/home_page.dart';

int mainThemeColor = 0xff992722;
ThemeData mainThemeData = ThemeData(
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(mainThemeColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(mainThemeColor),
      foregroundColor: Colors.white,
    ));

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
