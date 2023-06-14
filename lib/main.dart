import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'screens/project/project_page.dart';
import 'screens/projects_list/projects_list_page.dart';
import 'models/app_data.dart';
import 'screens/new_project/new_project.dart';
import 'utils/helper/theme.dart';

void main() async {
  runApp(const SplashScreen());
  await AppData.init();
  if (AppData.firstRun) {
    runApp(const SetupScreen());
  } else {
    runApp(const MainScreen());
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        home: const Scaffold(
          body: Center(
            child: Text('Starting up Splitr ...'),
          ),
        ),
      );
    });
  }
}

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

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Splitr',
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        themeMode: ThemeMode.system,
        home: NewProjectScreen(first: true),
      );
    });
  }
}
