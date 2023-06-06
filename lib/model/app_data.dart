import 'package:app_links/app_links.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shared/model/instance.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/shared_database.dart';
import '../screens/main_screen.dart';
import '../screens/new_project_screen.dart';
import 'connectors/local/instance.dart';
import 'project.dart';

class AppData {
  static late SharedPreferences sharedPreferences;
  static late bool _firstRun;
  static Set<Project> projects = {};
  static late Database db;
  static Project? _current;
  static Set<Instance> instances = {};
  static bool hasBeenInit = false;

  static bool get firstRun {
    return _firstRun;
  }

  static set firstRun(bool v) {
    _firstRun = v;
    sharedPreferences.setBool("firstRun", v);
  }

  static Project? get current {
    return _current;
  }

  static set current(Project? project) {
    if (project == null) {
      sharedPreferences.remove("lastProject");
    } else {
      sharedPreferences.setString(
        "lastProject",
        project.name,
      );
    }
    _current = project;
  }

  static init() async {
    hasBeenInit = true;
    sharedPreferences = await SharedPreferences.getInstance();
    db = await SharedDatabase.instance.database;

    if (!sharedPreferences.containsKey("firstRun")) {
      firstRun = true;
    } else {
      firstRun = sharedPreferences.getBool("firstRun")!;
    }

    AppData.instances = await Instance.getAllInstances();

    AppData.projects = await Project.getAllProjects();

    if (sharedPreferences.containsKey("lastProject")) {
      try {
        _current =
            Project.fromName(sharedPreferences.getString("lastProject")!);
        await _current!.conn.loadParticipants();
        await _current!.conn.loadEntries();
      } catch (e) {}
    }

    final appLinks = AppLinks();

    appLinks.allUriLinkStream.listen((uri) {
      if (uri.queryParameters.containsKey('code') &&
          uri.queryParameters.containsKey('instance')) {
        runApp(
          _NewProjectFromLink(
            code: uri.queryParameters['code']!,
            instanceName: uri.queryParameters['instance']!,
          ),
        );
      }
    });
  }
}

class _NewProjectFromLink extends StatelessWidget {
  const _NewProjectFromLink({required this.code, required this.instanceName});

  final String code;
  final String instanceName;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        title: 'Shared',
        theme: defaultTheme,
        darkTheme: defaultDarkTheme,
        themeMode: ThemeMode.system,
        home: NewProjectScreen(
          instance: Instance.fromName(instanceName),
          code: code,
        ),
      );
    });
  }
}
