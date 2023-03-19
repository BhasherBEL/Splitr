import 'package:flutter/material.dart';
import 'package:shared/model/setup_data.dart';

class ProjectSetupPage extends StatefulWidget {
  ProjectSetupPage(this.setupData, {super.key});

  SetupData setupData;

  @override
  State<ProjectSetupPage> createState() => _ProjectSetupPageState();
}

class _ProjectSetupPageState extends State<ProjectSetupPage> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("What's the name of your poject ?"),
      TextFormField(
        validator: (value) => value == null || value.isEmpty
            ? 'Your project can\'t have an empty name'
            : null,
        initialValue: widget.setupData.projectName,
        onChanged: (value) => widget.setupData.projectName = value,
      ),
      const Text("Which type of project do you want to create ?"),
      DropdownMenu<int>(
        dropdownMenuEntries: const [
          DropdownMenuEntry(value: 0, label: "Local"),
          DropdownMenuEntry(value: 1, label: "PocketBase"),
        ],
        initialSelection: widget.setupData.providerId,
        onSelected: (value) {
          setState(() {
            if (value != null) widget.setupData.providerId = value;
          });
        },
      ),
      if (widget.setupData.providerId == 1)
        Column(
          children: [
            const Text("Pocketbase instance:"),
            TextFormField(
              validator: (value) => value == null || value.isEmpty
                  ? 'Instance can\'t be empty'
                  : null,
              onChanged: (value) => widget.setupData.providerDataMap[0] = value,
            ),
            const Text("Pocketbase username:"),
            TextFormField(
              onChanged: (value) => widget.setupData.providerDataMap[1] = value,
            ),
            const Text("Pocketbase password:"),
            TextFormField(
              onChanged: (value) => widget.setupData.providerDataMap[2] = value,
            ),
          ],
        ),
    ]);
  }
}
