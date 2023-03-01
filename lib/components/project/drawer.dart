import 'package:flutter/material.dart';

import '../../model/project.dart';
import '../new_project.dart';

class ProjectsDrawer extends StatefulWidget {
  const ProjectsDrawer({
    Key? key,
    this.onDrawerCallback,
  }) : super(key: key);

  final Function()? onDrawerCallback;

  @override
  State<ProjectsDrawer> createState() => _ProjectsDrawerState();
}

class _ProjectsDrawerState extends State<ProjectsDrawer> {
  List<Project> projects = Project.projects;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                Project project = projects.elementAt(index);
                return ListTile(
                  title: Text(project.name),
                  onTap: () {
                    Project.current = project;
                    Navigator.pop(context);
                    if (widget.onDrawerCallback != null) {
                      widget.onDrawerCallback!();
                    }
                  },
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
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Project ${project.name} deleted"),
                        ));
                      setState(() {
                        if (mounted) projects = Project.projects;
                      });
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
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NewProjectPage(),
                          ),
                        );
                        setState(() {
                          if (mounted) projects = Project.projects;
                        });
                      }),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
