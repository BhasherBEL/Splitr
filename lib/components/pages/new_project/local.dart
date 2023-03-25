import 'package:flutter/material.dart';
import 'package:shared/model/project_data.dart';

class LocalNewProject extends StatelessWidget {
  const LocalNewProject(this.projectData, {super.key});

  final ProjectData projectData;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) => value == null || value.isEmpty
          ? 'Your project can\'t have an empty title'
          : null,
      initialValue: projectData.projectName,
      onChanged: (value) => projectData.projectName = value,
      decoration: const InputDecoration(
        labelText: "Title",
        border: OutlineInputBorder(),
      ),
    );
  }
}
