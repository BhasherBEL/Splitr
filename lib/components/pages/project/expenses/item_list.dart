import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:splitr/model/item_part.dart';
import 'package:splitr/utils/extenders/collections.dart';
import 'package:tuple/tuple.dart';

import '../../../../utils/extenders/string.dart';
import '../../../../model/item.dart';
import '../../../../model/project.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/time.dart';
import 'new_entry.dart';

class ItemList extends StatefulWidget {
  const ItemList(this.project, {super.key});

  final Project project;

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  Future<void> sync() async {
    Tuple2<bool, String> res = await widget.project.sync();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.item1
                ? "Project synced in ${res.item2} seconds"
                : "Error: ${res.item2}",
          ),
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastDate;
    return RefreshIndicator(
      onRefresh: sync,
      child: Column(
        children: [
          if (widget.project.provider.hasSync())
            SyncTile(project: widget.project, onTap: sync),
          Expanded(
            child: widget.project.items.enabled().isNotEmpty
                ? ScrollConfiguration(
                    behavior: NoGlow(),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        Item item =
                            widget.project.items.enabled().elementAt(index);
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
                                ],
                              ),
                            ),
                            tileColor: Theme.of(context).splashColor,
                            dense: true,
                          );
                        }

                        double share = widget.project.currentParticipant == null
                            ? 0
                            : (item.shareOf(widget
                                            .project.currentParticipant!) *
                                        100)
                                    .roundToDouble() /
                                100;

                        return Column(
                          children: [
                            if (header != null) header,
                            Slidable(
                              endActionPane: ActionPane(
                                extentRatio: 0.4,
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (BuildContext? context) async {
                                      item.deleted = true;
                                      await item.conn.save();
                                      for (ItemPart ip in item.itemParts) {
                                        ip.deleted = true;
                                        await ip.conn.save();
                                      }
                                      setState(() {});
                                    },
                                    icon: Icons.delete,
                                    backgroundColor: Colors.red,
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
                                  Expanded(
                                      child: Text(item.title.capitalize())),
                                  Text('${item.amount.toStringAsFixed(2)} €'),
                                ]),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${item.emitter.pseudo} ➝ ${item.toParticipantsString()}",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                    Text(
                                      '${share.toStringAsFixed(2)} €',
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: share > 0
                                            ? Colors.green
                                            : share < 0
                                                ? Colors.red
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
                      itemCount: widget.project.items.enabled().length,
                    ),
                  )
                : Center(
                    child: Text(widget.project.participants.isEmpty
                        ? "Add your first participant!"
                        : "Add your first item!"),
                  ),
          ),
        ],
      ),
    );
  }
}

class DynamicSync extends StatefulWidget {
  const DynamicSync({
    super.key,
    required this.time,
  });

  final DateTime time;

  @override
  State<DynamicSync> createState() => _DynamicSyncState();
}

class _DynamicSyncState extends State<DynamicSync> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text("Last sync ${timeElapsed(widget.time)}");
  }
}

class NoGlow extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class SyncTile extends StatefulWidget {
  const SyncTile({super.key, required this.project, this.onTap});

  final Project project;
  final Future<void> Function()? onTap;

  @override
  State<SyncTile> createState() => _SyncTileState();
}

class _SyncTileState extends State<SyncTile> {
  bool isSyncing = false;

  Future<void> onTap() async {
    setState(() {
      isSyncing = true;
    });

    if (widget.onTap != null) await widget.onTap!();

    setState(() {
      isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(isSyncing);
    return ListTile(
      subtitle: Text(
        "${widget.project.notSyncCount} changes to push",
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      trailing: isSyncing
          ? Padding(
              padding: const EdgeInsets.only(right: 5),
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            )
          : Icon(
              Icons.sync,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
      title: DynamicSync(time: widget.project.lastSync),
      dense: true,
      onTap: onTap,
    );
  }
}
