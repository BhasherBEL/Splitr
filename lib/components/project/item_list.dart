import 'package:flutter/material.dart';

import '../../model/item.dart';
import '../../model/project.dart';

class ItemList extends StatelessWidget {
  const ItemList(this.project, {super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return project.items.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              Item item = project.items.elementAt(index);
              return ListTile(
                title: Row(children: [
                  Expanded(child: Text(item.title)),
                  Text('${item.amount} €'),
                ]),
                subtitle: Row(
                  children: [
                    Text(item.date.millisecondsSinceEpoch.toString()),
                  ],
                ),
              );
            },
            itemCount: project.items.length,
          )
        : const Center(
            child: Text("Add your first item!"),
          );
  }
}
