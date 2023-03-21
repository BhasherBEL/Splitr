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
      TextFormField(
        validator: (value) => value == null || value.isEmpty
            ? 'Your project can\'t have an empty name'
            : null,
        initialValue: widget.setupData.projectName,
        onChanged: (value) => widget.setupData.projectName = value,
        decoration: const InputDecoration(
          labelText: "Name",
          border: OutlineInputBorder(),
        ),
      ),
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
        // decoration: const InputDecoration(
        //   labelText: "Project type",
        //   border: OutlineInputBorder(),
        // ),
      ),
      const SizedBox(
        height: 12, // <-- SEE HERE
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
