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
      appBar: AppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(
              "Pseudo",
              maxLines: 1,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: pseudoController,
            autocorrect: false,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          ElevatedButton(
            onPressed: () async {
              Participant participant =
                  Participant(pseudo: pseudoController.text);
              await participant.conn.save();
              project.addParticipant(participant);
              project.conn.saveParticipants();
              Navigator.pop(context, true);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
