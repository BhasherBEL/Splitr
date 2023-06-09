import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:splitr/utils/string.dart';

import '../../../model/app_data.dart';
import '../../../model/instance.dart';
import '../../../model/project.dart';
import '../../../model/project_data.dart';
import '../../../utils/navigator/navigator.dart';
import '../../../utils/switches/text_switch.dart';
import '../../../utils/tiles/header_tile.dart';
import 'participant_tile.dart';
import '../instances/instances_list_page.dart';

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
      widget.projectData.instance = widget.project!.provider.instance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: SelectFormField(
                enabled: widget.project == null,
                validator: (value) => value == null || value.isEmpty
                    ? 'You must select a project instance!'
                    : null,
                type: SelectFormFieldType.dropdown,
                initialValue: widget.projectData.instance != null
                    ? widget.projectData.instance!.name
                    : null,
                items: AppData.instances
                    .map<Map<String, dynamic>>((e) => {
                          'value': e.name,
                          'label': e.name.firstCapitalize(),
                        })
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    widget.projectData.instance = Instance.fromName(v);
                  });
                },
                decoration: InputDecoration(
                  labelText: "Project instance",
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () async {
                await navigatorPush(context, () => const InstancesListPage());
                setState(() {});
              },
              icon: const Icon(Icons.settings),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const HeaderTile("Configuration"),
        const SizedBox(height: 12),
        if (widget.project == null)
          TextSwitch(
            state: widget.projectData.join,
            leftText: "Create",
            rightText: "Join",
            onChanged: (v) => setState(() => widget.projectData.join = v),
          ),
        TextFormField(
          validator: (value) =>
              value == null || value.isEmpty ? 'Name can\'t be empty' : null,
          initialValue: widget.projectData.projectName,
          onChanged: (value) => widget.projectData.projectName = value,
          decoration: InputDecoration(
            labelText:
                widget.projectData.join ? "Project code" : "Project title",
            border: const OutlineInputBorder(),
          ),
        ),
        if (widget.project != null)
          const SizedBox(
            height: 12,
          ),
        if (widget.project != null)
          SelectFormField(
            type: SelectFormFieldType.dropdown,
            initialValue:
                widget.project!.currentParticipant?.pseudo ?? "anonymous",
            items: [
              ...widget.project!.participants.map<Map<String, dynamic>>((e) => {
                    'value': e.pseudo,
                  }),
              const {'value': 'anonymous', 'label': 'Anonymous'},
            ],
            onChanged: (v) {
              setState(() {
                if (v == 'anonymous') {
                  widget.project!.currentParticipant = null;
                  widget.project!.currentParticipantId = null;
                } else {
                  widget.project!.currentParticipant =
                      widget.project!.participantByPseudo(v);
                  widget.project!.currentParticipantId =
                      widget.project!.currentParticipant?.localId;
                }
              });
            },
            decoration: const InputDecoration(
              labelText: "Who are you  ?",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.arrow_drop_down),
            ),
          ),
        const SizedBox(
          height: 12,
        ),
        if (widget.project != null)
          ParticipantListWidget(
            widget.project!,
            reloadParent: () => setState(() {}),
          ),
      ]),
    );
  }
}

class ParticipantListWidget extends StatefulWidget {
  const ParticipantListWidget(this.project, {super.key, this.reloadParent});

  final Project project;
  final Function()? reloadParent;

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
            onChange: widget.reloadParent ?? () => setState(() {}),
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
