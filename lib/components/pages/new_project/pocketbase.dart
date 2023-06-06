import 'package:flutter/material.dart';
import 'package:shared/model/project_data.dart';

class PocketbaseNewProject extends StatefulWidget {
  const PocketbaseNewProject(this.projectData, {super.key});

  final ProjectData projectData;

  @override
  State<PocketbaseNewProject> createState() => _PocketbaseNewProjectState();
}

class _PocketbaseNewProjectState extends State<PocketbaseNewProject> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                height: 12,
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
        const SizedBox(
          height: 12,
        ),
        TextSwitch(
          state: widget.projectData.join,
          leftText: 'Create',
          rightText: 'Join',
          onChanged: (value) {
            setState(() {
              widget.projectData.join = value;
            });
          },
        ),
        const SizedBox(
          height: 12,
        ),
        TextFormField(
          validator: (value) => value == null || value.isEmpty
              ? 'Your project can\'t have an empty title'
              : null,
          initialValue: widget.projectData.projectName,
          onChanged: (value) => widget.projectData.projectName = value,
          decoration: InputDecoration(
            labelText: widget.projectData.join ? "Code" : "Title",
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class TextSwitch extends StatelessWidget {
  const TextSwitch({
    super.key,
    required this.state,
    this.leftText = '',
    this.rightText = '',
    this.onChanged,
    this.padding = 10,
  });

  final bool state;
  final String leftText;
  final String rightText;
  final Function(bool newState)? onChanged;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(leftText),
        SizedBox(
          width: padding,
        ),
        Switch(
          value: state,
          onChanged: onChanged,
        ),
        SizedBox(
          width: padding,
        ),
        Text(rightText),
      ],
    );
  }
}
