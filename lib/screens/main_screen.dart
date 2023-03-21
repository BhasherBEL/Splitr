import 'package:flutter/material.dart';
import 'package:shared/utils/colors.dart';

import '../components/home_page.dart';

ThemeData mainThemeData = ThemeData(
  useMaterial3: true,
  colorSchemeSeed: Colors.green,
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
