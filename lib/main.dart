import 'package:flutter/material.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/screens/main_screen.dart';
import 'package:shared/screens/splash_screen.dart';
import 'package:shared/model/project.dart';

import 'screens/setup_screen.dart';

void main() async {
  runApp(const SplashScreen());
  Project.projects = await Project.getAllProjects();
  Participant.me = await Participant.getMe();
  if (Project.projects.isEmpty) {
    runApp(const SetupScreen());
  } else {
    runApp(const MainScreen());
  }
}
