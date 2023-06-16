import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:splitr/utils/helper/release_version.dart';
import 'package:tuple/tuple.dart';
import 'screens/project/project_page.dart';
import 'screens/projects_list/projects_list_page.dart';
import 'models/app_data.dart';
import 'screens/new_project/new_project.dart';
import 'utils/helper/theme.dart';
import 'utils/helper/update_box.dart';

void main() async {
  runApp(const SplashScreen());
  await AppData.init();
  runApp(const MainScreen());
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
        home: const CheckUpdatePage(),
      );
    });
  }
}

class CheckUpdatePage extends StatelessWidget {
  const CheckUpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        Tuple3<bool, String, String> hasNewRelease = await checkForNewRelease();

        if (hasNewRelease.item1) {
          if (context.mounted) {
            updateBox(
              context: context,
              currentVersion:
                  AppData.sharedPreferences.getString('last_version') ?? 'null',
              releaseVersion: hasNewRelease.item2,
              releaseUrl: hasNewRelease.item3,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error when trying to fetch releases data'),
            ),
          );
        }
      }
    });

    if (AppData.firstRun) {
      return NewProjectScreen(first: true);
    } else if (AppData.current == null) {
      return const ProjectsListPage();
    } else {
      return ProjectPage(AppData.current!);
    }
  }
}
