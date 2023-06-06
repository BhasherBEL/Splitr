import 'package:flutter/material.dart';
import 'package:shared/components/pages/projects_list/projects_list.dart';
import 'package:shared/screens/new_project_screen.dart';

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
          "Shared",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const ProjectsList(),
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
        if (onDone != null) onDone!();
      },
      tooltip: 'Add new project',
      child: const Icon(Icons.add),
    );
  }
}
