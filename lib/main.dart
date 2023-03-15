import 'package:flutter/material.dart';

import 'model/app_data.dart';
import 'screens/main_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';

void main() async {
  runApp(const SplashScreen());
  await AppData.init();
  if (AppData.firstRun) {
    runApp(const SetupScreen());
  } else {
    runApp(const MainScreen());
  }
}
