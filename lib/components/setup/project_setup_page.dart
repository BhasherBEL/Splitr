import 'package:flutter/material.dart';
import 'package:shared/model/setup_data.dart';

class ProjectSetupPage extends StatelessWidget {
  ProjectSetupPage(this.setupData, {super.key});

  SetupData setupData;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextFormField(
        enabled: false,
        decoration: const InputDecoration(
          labelText: "Project type",
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(
        height: 12, // <-- SEE HERE
      ),
      TextFormField(
        validator: (value) => value == null || value.isEmpty
            ? 'Your project can\'t have an empty name'
            : null,
        initialValue: setupData.projectName,
        onChanged: (value) => setupData.projectName = value,
        decoration: const InputDecoration(
          labelText: "Name",
          border: OutlineInputBorder(),
        ),
        // update((state) => state.copyWith(projectName: value)),
      ),
    ]);
  }
}
