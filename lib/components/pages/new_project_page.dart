import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';

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
          height: 12, // <-- SEE HERE
        ),
        if (widget.projectData.providerId == 0)
          LocalNewProject(widget.projectData),
        if (widget.projectData.providerId == 1)
          PocketbaseNewProject(widget.projectData),
      ]),
    );
  }
}
