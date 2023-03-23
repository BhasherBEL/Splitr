import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';
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
    return SingleChildScrollView(
      child: Column(children: [
        TextFormField(
          validator: (value) => value == null || value.isEmpty
              ? 'Your project can\'t have an empty title'
              : null,
          initialValue: widget.setupData.projectName,
          onChanged: (value) => widget.setupData.projectName = value,
          decoration: const InputDecoration(
            labelText: "Title",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(
          height: 12, // <-- SEE HERE
        ),
        Row(
          children: [
            Expanded(
              child: SelectFormField(
                type: SelectFormFieldType.dropdown,
                items: const [
                  {'value': 0, 'label': "Local"},
                  {'value': 1, 'label': "PocketBase"},
                ],
                // initialSelection: widget.setupData.providerId,
                onChanged: (value) {
                  setState(() {
                    widget.setupData.providerId = int.parse(value);
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Project type",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 12, // <-- SEE HERE
        ),
        if (widget.setupData.providerId == 1)
          Column(
            children: [
              TextFormField(
                validator: (value) => value == null || value.isEmpty
                    ? 'Instance URL can\'t be empty'
                    : null,
                onChanged: (value) =>
                    widget.setupData.providerDataMap[0] = value,
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
                      onChanged: (value) =>
                          widget.setupData.providerDataMap[1] = value,
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
                      onChanged: (value) =>
                          widget.setupData.providerDataMap[2] = value,
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
