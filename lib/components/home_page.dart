import 'package:flutter/material.dart';

import 'project/drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              "Berlin Trip",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // fontFeatures: [FontFeature.enable('smcp')],
              ),
            ),
            Text(
              "Arthur, Sandrine, Paul",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Select a project to start adding entries',
            ),
          ],
        ),
      ),
      drawer: const ProjectsDrawer(),
      floatingActionButton: const FloatingActionButton(
        onPressed: null,
        tooltip: 'Add new entry',
        child: Icon(Icons.add),
      ),
    );
  }
}
