import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared/utils/colors.dart';
import 'package:shared/utils/string.dart';

import '../../model/app_data.dart';
import '../../model/item.dart';
import '../../model/project.dart';
import '../../utils/time.dart';
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
    DateTime? lastDate;
    return widget.project.items.isNotEmpty
        ? ListView.builder(
            itemBuilder: (context, index) {
              Item item = widget.project.items.elementAt(index);
              Widget? header;
              if (lastDate == null ||
                  item.date.day != lastDate!.day ||
                  item.date.month != lastDate!.month ||
                  item.date.year != lastDate!.year) {
                lastDate = item.date;
                header = ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            daysElapsed(lastDate!).toUpperCase(),
                          ),
                        ),
                        // Expanded(
                        //   child: Text(
                        //     lastDate!.toDate(),
                        //     textAlign: TextAlign.right,
                        //     style: const TextStyle(
                        //       fontSize: 11,
                        //       // color: Color(0xFF333333),
                        //       fontStyle: FontStyle.italic,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  tileColor: Color(0xFF444444),
                  dense: true,
                );
              }

              double share =
                  (item.shareOf(AppData.me) * 100).roundToDouble() / 100;

              return Column(
                children: [
                  if (header != null) header,
                  Slidable(
                    endActionPane: ActionPane(
                      extentRatio: 0.4,
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext? context) {
                            widget.project.deleteItem(item);
                            item.conn.delete();
                            setState(() {});
                          },
                          icon: Icons.delete,
                          backgroundColor: ColorModel.red,
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
                          backgroundColor: ColorModel.orange,
                          foregroundColor: Colors.white,
                          label: 'Edit',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Row(children: [
                        Expanded(child: Text(item.title.capitalize())),
                        Text('${item.amount} €'),
                      ]),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${item.emitter.pseudo} ➝ ${item.toParticipantsString()}",
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          Text(
                            '$share €',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: share > 0
                                  ? Color.fromARGB(200, 76, 175, 80)
                                  : share < 0
                                      ? Color.fromARGB(200, 250, 68, 55)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
            itemCount: widget.project.items.length,
          )
        : const Center(
            child: Text("Add your first item!"),
          );
  }
}
