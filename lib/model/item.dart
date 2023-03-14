import 'package:shared/model/bill_data.dart';
import 'package:shared/model/itemPart.dart';
import 'package:shared/model/participant.dart';
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
  const Item({
    this.id,
    required this.projectId,
    required this.title,
    required this.emitterId,
    required this.amount,
    required this.date,
  });

  final int? id;
  final int projectId;
  final String title;
  final int emitterId;
  final double amount;

  final DateTime date;

  Map<String, Object?> toJson() => {
        ItemFields.id: id,
        ItemFields.project: projectId,
        ItemFields.title: title,
        ItemFields.emitter: emitterId,
        ItemFields.amount: amount,
        ItemFields.date: date.millisecondsSinceEpoch,
      };

  Map<String, Object?> toTempJson() => {
        ItemFields.project: projectId,
        ItemFields.title: title,
        ItemFields.emitter: emitterId,
        ItemFields.amount: amount,
        ItemFields.date: date.millisecondsSinceEpoch,
      };

  Item copyWith({
    final int? id,
    final int? projectId,
    final String? title,
    final int? emitterId,
    final double? amount,
    final DateTime? date,
  }) {
    return Item(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      emitterId: emitterId ?? this.emitterId,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      id: id ?? this.id,
    );
  }

  static Item fromJson(Map<String, Object?> json) {
    return Item(
      id: json[ItemFields.id] as int?,
      projectId: json[ItemFields.project] as int,
      title: json[ItemFields.title] as String,
      emitterId: json[ItemFields.emitter] as int,
      amount: json[ItemFields.amount] as double,
      date: DateTime.fromMillisecondsSinceEpoch(json[ItemFields.date] as int),
    );
  }

  static Future<Item> fromBill(BillData bill) async {
    final db = await SharedDatabase.instance.database;

    Item item = Item(
      amount: bill.amount,
      date: bill.date,
      emitterId: bill.emitter.id!,
      projectId: Project.current!.id,
      title: bill.title,
    );

    final id = await db.insert(tableItems, item.toTempJson());

    bill.shares.forEach((participant, share) {
      ItemPart.fromValues(id, participant.id!, share);
    });

    return item.copyWith(id: id);
  }

  Future<List<ItemPart>> getParts() async {
    final db = await SharedDatabase.instance.database;
    return (await db.query(
      tableItemParts,
      columns: ItemPartFields.values,
      where: "${ItemPartFields.itemId} = ?",
      whereArgs: [id],
    ))
        .map((e) => ItemPart.fromJson(e))
        .toList();
  }
}
