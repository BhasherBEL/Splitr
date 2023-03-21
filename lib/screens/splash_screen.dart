import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: lightColorScheme ?? defaultLightColorScheme,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: darkColorScheme ?? defaultDarkColorScheme,
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(
            child: Text("Starting up Shared ..."),
          ),
        ),
      );
    });
  }
}
