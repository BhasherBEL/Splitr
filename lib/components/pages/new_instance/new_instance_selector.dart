import 'package:flutter/material.dart';
import 'package:shared/components/pages/new_instance/new_instance_page.dart';
import 'package:shared/components/pages/new_instance/new_instance_pocketbase.dart';
import 'package:shared/utils/tiles/header_tile.dart';

class NewInstanceSelector extends StatefulWidget {
  const NewInstanceSelector(this.instanceData, {super.key});

  final InstanceData instanceData;

  @override
  State<NewInstanceSelector> createState() => _NewInstanceSelectorState();
}

class _NewInstanceSelectorState extends State<NewInstanceSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            validator: (value) =>
                value == null || value.isEmpty ? 'Name can\'t be empty' : null,
            initialValue: widget.instanceData.name,
            onChanged: (value) => widget.instanceData.name = value,
            decoration: const InputDecoration(
              labelText: "Friendly name",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const HeaderTile("Instance type"),
        ListTile(
          leading: Radio<String>(
            value: 'pocketbase',
            groupValue: widget.instanceData.type,
            onChanged: (value) {
              setState(() {
                if (value != null) widget.instanceData.type = value;
              });
            },
          ),
          title: const Text("Pocketbase"),
        ),
        const HeaderTile("Instance parameters"),
        if (widget.instanceData.type == "pocketbase")
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NewInstancePocketbase(widget.instanceData),
          ),
      ],
    );
  }
}
