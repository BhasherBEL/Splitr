import 'package:flutter/material.dart';

import '../../model/project.dart';
import '../new_project.dart';

class ProjectsDrawer extends StatefulWidget {
  const ProjectsDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<ProjectsDrawer> createState() => _ProjectsDrawerState();
}

class _ProjectsDrawerState extends State<ProjectsDrawer> {
  late List<Project> projects;
  bool isLoading = true;

  Future refreshProjects() async {
    setState(() => isLoading = true);
    projects = await Project.getAllProjects();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    refreshProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Text("loading ...")
                : ListView.builder(
                    itemBuilder: (context, index) {
                      Project project = projects.elementAt(index);
                      return ListTile(
                        title: Text(project.name),
                        onLongPress: () async {
                          final result = await showMenu(
                            context: context,
                            position: const RelativeRect.fromLTRB(0, 0, 0, 0),
                            items: [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text("delete"),
                              ),
                            ],
                          );
                          if (result == 'delete') {
                            await project.delete();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Project ${project.name} deleted"),
                            ));
                          }
                        },
                      );
                    },
                    itemCount: projects.length,
                  ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Add new"),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewProjectPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
