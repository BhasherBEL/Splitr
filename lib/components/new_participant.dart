import 'package:flutter/material.dart';
import 'package:shared/model/participant.dart';

import '../model/project.dart';

class NewParticipantPage extends StatelessWidget {
  const NewParticipantPage(this.project, {super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    TextEditingController pseudoController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text("New participant"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: pseudoController,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                Participant participant =
                Participant(pseudo: pseudoController.text);
                await participant.db.save();
                project.addParticipant(participant);
                project.db.saveParticipants();
                Navigator.pop(context, true);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      )
    );
  }
}
