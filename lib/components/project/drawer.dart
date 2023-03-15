import 'package:flutter/material.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/model/participant.dart';

import '../../model/project.dart';
import '../new_participant.dart';
import '../new_project.dart';

class ProjectsDrawer extends StatefulWidget {
  const ProjectsDrawer(
    this.project, {
    Key? key,
    this.onDrawerCallback,
  }) : super(key: key);

  final Project project;
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
                Participant participant =
                    widget.project.participants.elementAt(index);
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(participant.pseudo)),
                      Text(
                        '${(([
                              0.0
                            ] + widget.project.items.map((e) => e.shareOf(participant)).toList()).reduce((a, b) => a + b) * 100).roundToDouble() / 100} €',
                      ),
                    ],
                  ),
                  subtitle: (participant.firstname != null ||
                          participant.lastname != null)
                      ? Text("${participant.firstname} ${participant.lastname}")
                      : null,
                );
              },
              itemCount: widget.project.participants.length,
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
                    leading: const Icon(Icons.close),
                    title: const Text("Exit project"),
                    onTap: () async {
                      AppData.current = null;
                      Navigator.pop(context);
                      if (widget.onDrawerCallback != null) {
                        widget.onDrawerCallback!();
                      }
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
