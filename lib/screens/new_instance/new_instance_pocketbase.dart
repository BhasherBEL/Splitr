import 'package:flutter/material.dart';

import 'new_instance_page.dart';

class NewInstancePocketbase extends StatefulWidget {
  const NewInstancePocketbase(this.instanceData, {super.key});

  final InstanceData instanceData;

  @override
  State<NewInstancePocketbase> createState() => _NewInstancePocketbaseState();
}

class _NewInstancePocketbaseState extends State<NewInstancePocketbase> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            TextFormField(
              validator: (value) => value == null || value.isEmpty
                  ? 'Instance URL can\'t be empty'
                  : null,
              initialValue: widget.instanceData.data['instance'],
              onChanged: (value) =>
                  widget.instanceData.data['instance'] = value,
              decoration: const InputDecoration(
                labelText: 'Instance URL',
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
                    initialValue: widget.instanceData.data['username'],
                    onChanged: (value) =>
                        widget.instanceData.data['username'] = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Username can\'t be empty'
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.instanceData.data['password'],
                    onChanged: (value) =>
                        widget.instanceData.data['password'] = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password can\'t be empty'
                        : null,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
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
      ],
    );
  }
}
