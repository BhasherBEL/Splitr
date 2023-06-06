import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared/model/participant.dart';

import '../../../model/project.dart';
import '../../../model/project_data.dart';
import '../../../utils/tiles/header_tile.dart';
import '../../../utils/tiles/participant_tile.dart';
import 'local.dart';
import 'pocketbase.dart';

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
