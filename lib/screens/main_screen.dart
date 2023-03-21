import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../components/home_page.dart';

final defaultLightColorScheme = ColorScheme.fromSwatch(
  primarySwatch: Colors.red,
);

final defaultDarkColorScheme = ColorScheme.fromSwatch(
  primarySwatch: Colors.red,
  brightness: Brightness.dark,
  backgroundColor: Colors.black87,
);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Shared',
        theme: ThemeData(
          colorScheme: defaultLightColorScheme,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        // ),
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: defaultDarkColorScheme,
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      );
    });
  }
}
