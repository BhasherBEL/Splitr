import 'package:flutter/material.dart';
import 'package:shared/model/app_data.dart';

import '../model/project.dart';

class NewProjectPage extends StatefulWidget {
  NewProjectPage({super.key, this.project});

  Project? project;

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  int? providerId;
  Map<int, String> providerDataMap = {};
  String? message;

  String get providerData {
    int i = 0;
    List<String> res = [];
    while (providerDataMap.containsKey(i)) {
      res.add(providerDataMap[i]!);
      i++;
    }
    return res.join(';');
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController projectTitleController = TextEditingController(
        text: widget.project != null ? widget.project!.name : "");

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text("New project"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: projectTitleController,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (widget.project == null) {
                  widget.project = Project(
                      name: projectTitleController.text,
                      providerId: providerId!,
                      providerData: providerData);
                  AppData.current = widget.project;
                } else {
                  widget.project!.name = projectTitleController.text;
                }
                await widget.project!.conn.save();
                Navigator.pop(context, true);
              },
              child: Text(widget.project == null ? 'Create' : 'Update'),
            ),
            const SizedBox(
              height: 10,
            ),
            TextField(
              controller: projectTitleController,
              autocorrect: false,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            if (widget.project == null)
              Column(
                children: [
                  const Text("Which type of project do you want to create ?"),
                  DropdownMenu<int>(
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 0, label: "Local"),
                      DropdownMenuEntry(value: 1, label: "PocketBase"),
                    ],
                    initialSelection: providerId,
                    onSelected: (value) {
                      setState(() {
                        if (value != null) providerId = value;
                      });
                    },
                  ),
                  if (providerId == 1)
                    Column(
                      children: [
                        const Text("Pocketbase instance:"),
                        TextFormField(
                          validator: (value) => value == null || value.isEmpty
                              ? 'Instance can\'t be empty'
                              : null,
                          onChanged: (value) => providerDataMap[0] = value,
                        ),
                        const Text("Pocketbase username:"),
                        TextFormField(
                          onChanged: (value) => providerDataMap[1] = value,
                        ),
                        const Text("Pocketbase password:"),
                        TextFormField(
                          onChanged: (value) => providerDataMap[2] = value,
                        ),
                      ],
                    ),
                ],
              ),
            ElevatedButton(
              onPressed: () async {
                if (widget.project == null) {
                  widget.project = Project(
                    name: projectTitleController.text,
                    providerId: providerId!,
                    providerData: providerData,
                  );
                  await widget.project!.provider.connect();
                  if (!await widget.project!.provider.checkConnection()) {
                    return;
                  }
                } else {
                  widget.project!.name = projectTitleController.text;
                }
                await widget.project!.conn.save();
                Navigator.pop(context, true);
              },
              child: Text(widget.project == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }
}
