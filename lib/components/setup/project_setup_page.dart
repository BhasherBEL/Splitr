import 'package:flutter/material.dart';
import 'package:shared/model/setup_data.dart';

class ProjectSetupPage extends StatelessWidget {
  ProjectSetupPage(this.setupData, {super.key});

  SetupData setupData;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("Which type of project do you want to create ? (soon)"),
      TextFormField(
        enabled: false,
      ),
      const Text("What's the name of your poject ?"),
      TextFormField(
        validator: (value) => value == null || value.isEmpty
            ? 'Your project can\'t have an empty name'
            : null,
        initialValue: setupData.projectName,
        onChanged: (value) => setupData.projectName = value,
        // update((state) => state.copyWith(projectName: value)),
      ),
    ]);
  }
}
