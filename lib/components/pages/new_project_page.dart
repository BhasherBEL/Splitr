import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared/model/participant.dart';

import '../../model/project.dart';
import '../../model/project_data.dart';
import 'new_project/local.dart';
import 'new_project/pocketbase.dart';

class NewProjectPage extends StatefulWidget {
  const NewProjectPage({super.key, this.project, required this.projectData});

  final Project? project;
  final ProjectData projectData;

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      widget.projectData.projectName = widget.project!.name;
      widget.projectData.providerId = widget.project!.provider.id;
      widget.projectData.providerDataMap =
          widget.project!.provider.data.split(';').asMap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        const SizedBox(
          height: 5,
        ),
        SelectFormField(
          validator: (value) => value == null || value.isEmpty
              ? 'You must select a project type!'
              : null,
          type: SelectFormFieldType.dropdown,
          initialValue: widget.projectData.providerId?.toString(),
          items: const [
            {'value': 0, 'label': "Local"},
            {'value': 1, 'label': "PocketBase"},
          ],
          // initialSelection: widget.setupData.providerId,
          onChanged: (value) {
            setState(() {
              widget.projectData.providerId = int.parse(value);
            });
          },
          decoration: const InputDecoration(
            labelText: "Project type",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.arrow_drop_down),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        if (widget.projectData.providerId == 0)
          LocalNewProject(widget.projectData),
        if (widget.projectData.providerId == 1)
          PocketbaseNewProject(widget.projectData),
        const SizedBox(
          height: 12,
        ),
        if (widget.project != null) ParticipantListWidget(widget.project!),
      ]),
    );
  }
}

class ParticipantListWidget extends StatefulWidget {
  const ParticipantListWidget(this.project, {super.key});

  final Project project;

  @override
  State<ParticipantListWidget> createState() => _ParticipantListWidgetState();
}

class _ParticipantListWidgetState extends State<ParticipantListWidget> {
  bool hasNew = false;

  void setHasNew(bool v) {
    setState(() {
      hasNew = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const HeaderTile("Participants"),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => ParticipantTile(
            project: widget.project,
            participant: hasNew && index >= widget.project.participants.length
                ? null
                : widget.project.participants.elementAt(index),
            setHasNew: setHasNew,
            onChange: () => setState(() {}),
          ),
          itemCount: widget.project.participants.length + (hasNew ? 1 : 0),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: IconButton(
            onPressed: () => setState(() {
              hasNew = true;
            }),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class HeaderTile extends StatelessWidget {
  const HeaderTile(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        text,
        style: const TextStyle(
          fontFeatures: [FontFeature.enable('smcp')],
        ),
      ),
      tileColor: Theme.of(context).splashColor,
      dense: false,
    );
  }
}

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

  Future<dynamic> confirmBox({
    required BuildContext context,
    required String title,
    required String content,
    required Function()? onValidate,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onValidate,
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("No"),
          ),
        ],
      ),
    );
  }
}
