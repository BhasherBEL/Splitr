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
      appBar: AppBar(
        elevation: 4,
        title: Text("New project"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: projectTitleController,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
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
      ),
    );
  }
}
