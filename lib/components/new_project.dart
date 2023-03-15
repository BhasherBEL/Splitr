import 'package:flutter/material.dart';
import 'package:shared/model/app_data.dart';

import '../model/participant.dart';
import '../model/project.dart';

class NewProjectPage extends StatelessWidget {
  NewProjectPage({super.key, this.project});

  Project? project;

  @override
  Widget build(BuildContext context) {
    TextEditingController projectTitleController =
        TextEditingController(text: project != null ? project!.name : "");

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Project name",
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: projectTitleController,
            autocorrect: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (project == null) {
                project = Project(name: projectTitleController.text);
                project!.addParticipant(AppData.me);
                await project!.db.saveParticipants();
              } else {
                project!.name = projectTitleController.text;
              }
              await project!.db.save();
              Navigator.pop(context, true);
            },
            child: Text(project == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }
}
