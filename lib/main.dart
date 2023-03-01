import 'package:flutter/material.dart';
import 'package:shared/screens/main_screen.dart';
import 'package:shared/screens/splash_screen.dart';
import 'package:shared/model/project.dart';

void main() async {
  runApp(const SplashScreen());
  Project.projects = await Project.getAllProjects();
  runApp(const MainScreen());
}
