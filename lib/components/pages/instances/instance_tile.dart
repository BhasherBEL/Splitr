import 'package:flutter/material.dart';
import 'package:splitr/model/connectors/local/instance.dart';

import '../../../model/app_data.dart';
import '../../../model/instance.dart';
import '../../../utils/dialogs/confirm_box.dart';
import '../../../utils/navigator/navigator.dart';
import '../new_instance/new_instance_page.dart';

class InstanceTile extends StatefulWidget {
  const InstanceTile({
    super.key,
    required this.instance,
    this.onChange,
  });

  final Instance instance;
  final Function()? onChange;

  @override
  State<InstanceTile> createState() => _InstanceTileState();
}

class _InstanceTileState extends State<InstanceTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.instance.name),
      trailing: widget.instance.localId ==
              1 // TODO maybe use a "editable" parameter ?
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () async {
                    await navigatorPush(
                      context,
                      () => NewInstancePage(instance: widget.instance),
                    );
                    setState(() {});
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () async {
                      await confirmBox(
                        context: context,
                        title: "Remove ${widget.instance.name}",
                        content:
                            "Are you sure you want to remove ${widget.instance.name}? You will not be able to sync or create projects with it.",
                        onValidate: () async {
                          await widget.instance.conn.delete();
                          AppData.instances.remove(widget.instance);
                          if (widget.onChange != null) widget.onChange!();
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      );
                    }),
              ],
            ),
    );
  }
}
