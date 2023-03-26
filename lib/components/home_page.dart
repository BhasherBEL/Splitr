import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/components/projects_list.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/screens/new_project_screen.dart';

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
    project = AppData.current;
    if (project != null) _loadProjectData();
    setState(() {});
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
    await project!.conn.loadParticipants();
    await project!.conn.loadEntries();
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
        // backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
        centerTitle: true,
        elevation: 4,
        title: Column(
          children: [
            Text(
              hasProject ? project!.name : "Shared",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasProject)
              Text(
                project!.participants.map((e) => e.pseudo).join(', '),
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        actions: [
          if (hasProject && project!.code != null)
            IconButton(
              onPressed: () {
                Share.share(
                  'Join my shared project with this code: ${project!.code!}',
                );
              },
              icon: const Icon(Icons.share),
            ),
        ],
      ),
      body: Center(
        child: hasProject
            ? isLoaded
                ? ItemList(project!)
                : const Text("Loading entries ...")
            : ProjectsList(() => setState(back)),
      ),
      drawer: hasProject
          ? ProjectsDrawer(project!, onDrawerCallback: () => setState(back))
          : null,
      floatingActionButton: hasProject && project!.participants.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => hasProject
                        ? NewEntryPage(project!)
                        : NewProjectScreen(),
                  ),
                );
                setState(back);
              },
              tooltip: 'Add new entry',
              child: const Icon(Icons.add),
            ),
    );
  }
}
