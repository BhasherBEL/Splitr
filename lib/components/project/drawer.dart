import 'package:flutter/material.dart';
import 'package:shared/model/app_data.dart';

import '../../model/project.dart';
import '../new_participant.dart';
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
                Project project = AppData.projects.elementAt(index);
                return ListTile(
                  title: Text(project.name),
                  onTap: () {
                    AppData.current = project;
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
                      AppData.projects.remove(project);
                      project.db.delete();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Project ${project.name} deleted"),
                        ));
                        setState(() {});
                      }
                    }
                  },
                );
              },
              itemCount: AppData.projects.length,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (AppData.current != null)
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text("Add new participant"),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewParticipantPage(AppData.current!),
                          ),
                        );
                        setState(() {});
                      },
                    ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text("Add new project"),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewProjectPage(),
                        ),
                      );
                      setState(() {});
                    },
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
