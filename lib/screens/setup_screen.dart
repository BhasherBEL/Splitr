import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';
import 'new_project_screen.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Shared',
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        themeMode: ThemeMode.system,
        home: NewProjectScreen(first: true),
      );
    });
  }
}
