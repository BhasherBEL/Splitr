import 'package:app_links/app_links.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splitr/model/connectors/local/project.dart';
import 'package:splitr/utils/extenders/collections.dart';
import 'package:sqflite/sqflite.dart';

import '../db/splitr_database.dart';
import '../screens/main_screen.dart';
import '../screens/new_project_screen.dart';
import 'instance.dart';
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
    db = await SplitrDatabase.instance.database;

    AppData.instances = await Instance.getAllInstances();

    AppData.projects = await Project.getAllProjects();

    print(AppData.projects);

    if (!sharedPreferences.containsKey("firstRun")) {
      firstRun = AppData.projects.enabled().isEmpty;
    } else {
      firstRun = sharedPreferences.getBool("firstRun")!;
    }

    if (sharedPreferences.containsKey("lastProject")) {
      try {
        _current =
            Project.fromName(sharedPreferences.getString("lastProject")!);
        await (_current!.conn as LocalProject).loadParticipants();
        await (_current!.conn as LocalProject).loadEntries();
      } catch (e) {
        sharedPreferences.remove("lastProject");
      }
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
        title: 'Splitr',
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
