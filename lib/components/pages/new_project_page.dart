import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared/model/connectors/provider.dart';

import '../../model/project.dart';
import '../../model/project_data.dart';

class NewProjectPage extends StatefulWidget {
  NewProjectPage({super.key, this.project, required this.projectData});

  Project? project;
  ProjectData projectData;

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
        TextFormField(
          validator: (value) => value == null || value.isEmpty
              ? 'Your project can\'t have an empty title'
              : null,
          initialValue: widget.projectData.projectName,
          onChanged: (value) => widget.projectData.projectName = value,
          decoration: InputDecoration(
            labelText: widget.projectData.providerId == 1
                ? "Title (to create) or code (to join)"
                : "Title",
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 12, // <-- SEE HERE
        ),
        if (widget.projectData.providerId == 1)
          Column(
            children: [
              TextFormField(
                validator: (value) => value == null || value.isEmpty
                    ? 'Instance URL can\'t be empty'
                    : null,
                initialValue: widget.projectData.providerDataMap[0],
                onChanged: (value) =>
                    widget.projectData.providerDataMap[0] = value,
                decoration: const InputDecoration(
                  labelText: "Instance URL",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 12, // <-- SEE HERE
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.projectData.providerDataMap[1],
                      onChanged: (value) =>
                          widget.projectData.providerDataMap[1] = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Username can\'t be empty'
                          : null,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.projectData.providerDataMap[2],
                      onChanged: (value) =>
                          widget.projectData.providerDataMap[2] = value,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password can\'t be empty'
                          : null,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ]),
    );
  }
}
