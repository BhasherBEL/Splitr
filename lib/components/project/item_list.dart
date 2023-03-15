import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../model/app_data.dart';
import '../../model/item.dart';
import '../../model/project.dart';
import '../new_entry.dart';

class ItemList extends StatefulWidget {
  const ItemList(this.project, {super.key});

  final Project project;

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return widget.project.items.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              Item item = widget.project.items.elementAt(index);
              return Slidable(
                endActionPane: ActionPane(
                  extentRatio: 0.4,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (BuildContext? context) {
                        widget.project.deleteItem(item);
                        item.db.delete();
                        setState(() {});
                      },
                      icon: Icons.delete,
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewEntryPage(
                              widget.project,
                              item: item,
                            ),
                          ),
                        );
                        setState(() {});
                      },
                      icon: Icons.edit,
                      backgroundColor: const Color(0xFFF9A602),
                      foregroundColor: Colors.white,
                      label: 'Edit',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Row(children: [
                    Expanded(child: Text(item.title)),
                    Text('${item.amount} €'),
                  ]),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                            "${item.emitter.pseudo} -> ${item.itemParts.map((e) => e.participant.pseudo).join(", ")}"),
                      ),
                      Text(
                          '${(item.shareOf(AppData.me) * 100).roundToDouble() / 100} €'),
                    ],
                  ),
                ),
              );
            },
            itemCount: widget.project.items.length,
          )
        : const Center(
            child: Text("Add your first item!"),
          );
  }
}
