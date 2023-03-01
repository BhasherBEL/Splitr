import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shared/model/project_data.dart';

import '../../model/item.dart';

class ItemList extends StatelessWidget {
  const ItemList(this.projectData, {super.key});

  final ProjectData projectData;

  @override
  Widget build(BuildContext context) {
    return projectData.items.length > 0
        ? ListView.builder(
            itemBuilder: (context, index) {
              Item item = projectData.items.elementAt(index);
              return ListTile(
                title: Row(children: [
                  Expanded(child: Text(item.title)),
                  Expanded(child: Text('${item.amount} €')),
                ]),
              );
            },
            itemCount: projectData.items.length,
          )
        : Center(
            child: Text("Add an item !"),
          );
  }
}
