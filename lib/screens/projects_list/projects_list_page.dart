import 'package:flutter/material.dart';

import '../project/new_project.dart';
import 'projects_list.dart';

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  State<ProjectsListPage> createState() => _ProjectsListPageState();
}

class _ProjectsListPageState extends State<ProjectsListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        title: const Text(
          "Splitr",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // ignore: prefer_const_constructors
      body: ProjectsList(),
      floatingActionButton: MainFloatingActionButton(
        onDone: () => setState(() {}),
      ),
    );
  }
}

class MainFloatingActionButton extends StatelessWidget {
  const MainFloatingActionButton({
    super.key,
    this.onDone,
  });

  final void Function()? onDone;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewProjectScreen(),
          ),
        );
        if (onDone != null && context.mounted) onDone!();
      },
      tooltip: 'Add new project',
      child: const Icon(Icons.add),
    );
  }
}
