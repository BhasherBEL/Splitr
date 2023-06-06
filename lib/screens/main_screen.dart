import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import '../components/pages/project/project_page.dart';
import '../components/pages/projects_list/projects_list_page.dart';
import '../model/app_data.dart';
import '../utils/colors.dart';

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

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Splitr',
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        themeMode: ThemeMode.system,
        home: AppData.current == null
            ? const ProjectsListPage()
            : ProjectPage(AppData.current!),
      );
    });
  }
}
