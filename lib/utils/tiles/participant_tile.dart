import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/participant.dart';
import '../../model/project.dart';
import '../dialogs/confirm_box.dart';

class ParticipantTile extends StatefulWidget {
  ParticipantTile({
    super.key,
    required this.project,
    required this.participant,
    required this.onChange,
    required this.setHasNew,
  });

  final Project project;
  Participant? participant;
  final Function() onChange;
  final void Function(bool v) setHasNew;

  @override
  State<ParticipantTile> createState() => _ParticipantTileState();
}

class _ParticipantTileState extends State<ParticipantTile> {
  late TextEditingController controller;

  bool edit = false;

  @override
  Widget build(BuildContext context) {
    bool hasParticipant = widget.participant != null;
    if (!hasParticipant) edit = true;

    bool isMe = widget.participant == widget.project.currentParticipant;

    controller = TextEditingController(
      text: hasParticipant
          ? widget.participant!.pseudo + (isMe && !edit ? ' (me)' : '')
          : '',
    );

    return ListTile(
      onTap: () {
        widget.project.currentParticipant = widget.participant;
        widget.onChange();
      },
      title: TextField(
        autofocus: true,
        enabled: edit,
        maxLines: 1,
        maxLength: 30,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(
          counterText: "",
          border: edit ? null : InputBorder.none,
        ),
        controller: controller,
        style: TextStyle(
          fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () async {
              edit = !edit;
              if (!edit) {
                if (hasParticipant) {
                  widget.participant!.pseudo = controller.text;
                  await widget.participant!.conn.save();
                } else {
                  widget.participant = Participant(
                    pseudo: controller.text,
                    project: widget.project,
                  );
                  await widget.participant!.conn.save();
                  widget.project.participants.add(widget.participant!);
                  widget.setHasNew(false);
                  return;
                }
              }
              setState(() {});
            },
            icon: Icon(edit ? Icons.done : Icons.edit),
          ),
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () async {
                if (hasParticipant) {
                  await confirmBox(
                    context: context,
                    title: "Remove ${widget.participant!.pseudo}",
                    content:
                        "Are you sure you want to remove ${widget.participant!.pseudo}? You will not be able to undo it.",
                    onValidate: () async {
                      await widget.project
                          .deleteParticipant(widget.participant!);
                      widget.onChange();
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  );
                } else {
                  widget.setHasNew(false);
                }
              }),
        ],
      ),
    );
  }
}
