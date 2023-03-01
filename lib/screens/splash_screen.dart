import 'package:flutter/material.dart';
import 'package:shared/screens/main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: mainThemeData,
      home: const Scaffold(
        body: Center(
          child: Text("loading your projects"),
        ),
      ),
    );
  }
}
