import 'package:flutter/material.dart';
import 'model/app_data.dart';
import 'screens/main_screen.dart';
import 'screens/new_project_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  runApp(const SplashScreen());
  await AppData.init();
  if (AppData.firstRun) {
    runApp(NewProjectScreen(
      first: true,
    ));
  } else {
    runApp(const MainScreen());
  }
}
