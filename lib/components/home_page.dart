import 'package:flutter/material.dart';
import 'package:shared/components/new_entry.dart';
import 'package:shared/components/project/item_list.dart';
import 'package:shared/model/project.dart';
import 'package:shared/model/project_data.dart';

import 'project/drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Project? project = Project.current;
  ProjectData? projectData;

  void back() {
    setState(() {
      project = Project.current;
    });
    if (project != null) _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    projectData = ProjectData(project!);
    await projectData!.load();
    setState(() {
      projectData!.isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool hasProject = project != null;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(
              hasProject ? project!.name : "Shared",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // fontFeatures: [FontFeature.enable('smcp')],
              ),
            ),
            if (hasProject)
              Text(
                project!.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
      body: Center(
        child: hasProject
            ? projectData!.isLoaded
                ? ItemList(projectData!)
                : const Text("Loading entries ...")
            : const Text(
                'Select a project to start adding entries',
              ),
      ),
      drawer: ProjectsDrawer(onDrawerCallback: back),
      floatingActionButton: hasProject
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewEntryPage(projectData!),
                ),
              ),
              tooltip: 'Add new entry',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
