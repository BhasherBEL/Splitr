import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../model/app_data.dart';
import '../../../model/project.dart';
import '../../../screens/new_project_screen.dart';
import '../../../utils/navigator/navigator.dart';
import '../project/project_page.dart';

class ProjectsList extends StatefulWidget {
  const ProjectsList({super.key});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  @override
  Widget build(BuildContext context) {
    return AppData.projects.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              Project project = AppData.projects.elementAt(index);
              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.4,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext? context) {
                        AppData.projects.remove(project);
                        project.conn.delete();
                        setState(() {});
                      },
                      icon: Icons.delete,
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewProjectScreen(
                              project: project,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      icon: Icons.edit,
                      backgroundColor: const Color(0xFFF9A602),
                      foregroundColor: Colors.white,
                      label: 'Edit',
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () async {
                    AppData.current = project;
                    await project.conn.loadParticipants();
                    int err = await project.conn.loadEntries();
                    if (context.mounted) {
                      if (err > 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$err errors when loading items.'),
                          ),
                        );
                      }
                      navigatorPush(context, () => ProjectPage(project));
                    }
                  },
                  title: Text(project.name),
                  subtitle: Text(
                    "${project.provider.instance.name} (${project.provider.instance.type})",
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              );
            },
            itemCount: AppData.projects.length,
          )
        : const Center(
            child: Text("Create your first project!"),
          );
  }
}
