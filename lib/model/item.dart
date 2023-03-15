import 'package:shared/model/bill_data.dart';
import 'package:shared/model/itemPart.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/model/project.dart';

import '../db/shared_database.dart';

const String tableItems = 'items';

class ItemFields {
  static const values = [
    id,
    project,
    title,
    emitter,
    amount,
    date,
  ];

  static const String id = '_id';
  static const String project = 'project';
  static const String title = 'title';
  static const String emitter = 'emitter';
  static const String amount = 'amount';
  static const String date = 'date';
}

class Item {
  Item({
    this.id,
    required this.project,
    required this.title,
    required this.emitter,
    required this.amount,
    required this.date,
  }) {
    db = _ItemDB(this);
  }

  int? id;
  Project project;
  String title;
  Participant emitter;
  double amount;
  DateTime date;
  List<ItemPart> itemParts = [];
  late _ItemDB db;

  Map<String, Object?> toJson() => {
        ItemFields.id: id,
        ItemFields.project: project.id,
        ItemFields.title: title,
        ItemFields.emitter: emitter.id,
        ItemFields.amount: amount,
        ItemFields.date: date.millisecondsSinceEpoch,
      };

  static Item fromJson(Map<String, Object?> json, {Project? project}) {
    Project p;
    if (project != null) {
      p = project;
    } else {
      p = Project.fromId(json[ItemFields.project] as int)!;
    }

    return Item(
      id: json[ItemFields.id] as int?,
      project: p,
      title: json[ItemFields.title] as String,
      emitter: p.participants.firstWhere(
          (participant) => participant.id == json[ItemFields.emitter] as int),
      amount: json[ItemFields.amount] as double,
      date: DateTime.fromMillisecondsSinceEpoch(json[ItemFields.date] as int),
    );
  }
}

class _ItemDB {
  _ItemDB(this.item);

  Item item;

  Future loadParts() async {
    item.itemParts = (await AppData.db.query(
      tableItemParts,
      columns: ItemPartFields.values,
      where: "${ItemPartFields.itemId} = ?",
      whereArgs: [item.id],
    ))
        .map((e) => ItemPart.fromJson(e, item))
        .toList();
  }

  Future save() async {
    if (item.id != null) {
      final results = await AppData.db.query(
        tableItems,
        where: 'id = ?',
        whereArgs: [item.id],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableItems,
          item.toJson(),
          where: 'id = ?',
          whereArgs: [item.id],
        );
        return;
      }
    }
    item.id = await AppData.db.insert(tableItems, item.toJson());
  }

  Future saveRecursively() async {
    await save();
    for (final ItemPart ip in item.itemParts) {
      await ip.db.save();
    }
  }
}
