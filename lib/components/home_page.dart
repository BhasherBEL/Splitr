import 'package:flutter/material.dart';
import 'package:shared/components/new_project.dart';
import 'package:shared/components/projects_list.dart';
import 'package:shared/model/app_data.dart';

import '../model/project.dart';
import 'new_entry.dart';
import 'project/drawer.dart';
import 'project/item_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Project? project = AppData.current;
  bool isLoaded = false;

  void back() {
    setState(() {
      project = AppData.current;
    });
    if (project != null) _loadProjectData();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      project = AppData.current;
    });
    if (project != null) _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    await project!.db.loadParticipants();
    await project!.db.loadEntries();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    project = AppData.current;
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
            ? isLoaded
                ? ItemList(project!)
                : const Text("Loading entries ...")
            : ProjectsList(() => setState(back)),
      ),
      drawer:
          hasProject ? ProjectsDrawer(project!, onDrawerCallback: back) : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  hasProject ? NewEntryPage(project!) : NewProjectPage(),
            ),
          );
          setState(() {});
        },
        tooltip: 'Add new entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}
