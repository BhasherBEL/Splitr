import 'package:flutter/material.dart';
import 'package:shared/model/project_data.dart';

import '../../model/item.dart';

class ItemList extends StatelessWidget {
  const ItemList(this.projectData, {super.key});

  final ProjectData projectData;

  @override
  Widget build(BuildContext context) {
    return projectData.items.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              Item item = projectData.items.elementAt(index);
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
            itemCount: projectData.items.length,
          )
        : const Center(
            child: Text("Add your first item!"),
          );
  }
}
