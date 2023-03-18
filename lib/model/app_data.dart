import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../db/shared_database.dart';
import 'connectors/local/participant.dart';
import 'participant.dart';
import 'project.dart';

class AppData {
  static late SharedPreferences sharedPreferences;
  static late bool _firstRun;
  static Set<Project> projects = {};
  static Set<Participant> participants = {};
  static late Participant me;
  static late Database db;
  static Project? _current;

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
    sharedPreferences = await SharedPreferences.getInstance();
    db = await SharedDatabase.instance.database;

    participants = await LocalParticipant.getAll();

    Participant? maybeMe = Participant.fromId(1);

    if (maybeMe == null) {
      firstRun = true;
    } else {
      me = maybeMe;
    }

    if (!sharedPreferences.containsKey("firstRun")) {
      firstRun = true;
    } else {
      firstRun = sharedPreferences.getBool("firstRun")!;
    }

    AppData.projects = await Project.getAllProjects();

    if (sharedPreferences.containsKey("lastProject")) {
      _current = Project.fromName(sharedPreferences.getString("lastProject")!);
    }
  }
}
