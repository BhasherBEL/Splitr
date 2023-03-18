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

  double shareOf(Participant participant) {
    double totalRate = 0;
    ItemPart? pip;
    if (itemParts.isNotEmpty) {
      for (ItemPart ip in itemParts) {
        if (ip.participant == participant) pip = ip;
        totalRate += ip.rate ?? 0;
      }
    }

    if (pip == null || pip.amount == null && pip.rate == null) {
      return emitter == participant ? amount : 0;
    }
    // return (emitter == participant ? amount : 0) - rate * amount / totalRate;
    return (emitter == participant ? amount : 0) -
        (pip.amount ?? pip.rate! * amount / totalRate);
  }

  String toParticipantsString() {
    List<Participant> participants =
        itemParts.map((e) => e.participant).toList();

    if (itemParts.length < 4) {
      return itemParts.map((e) => e.participant.pseudo).join(", ");
    }
    if (itemParts.length == project.participants.length) return 'All';

    List<String> possibilites = [
      itemParts.map((e) => e.participant.pseudo).join(", "),
      'All except ${project.participants.where((element) => !participants.contains(element)).map((e) => e.pseudo).join(', ')}',
    ];

    possibilites.sort();

    return possibilites.first;
  }

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
        where: '${ItemFields.id} = ?',
        whereArgs: [item.id],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableItems,
          item.toJson(),
          where: '${ItemFields.id} = ?',
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

  Future delete() async {
    await AppData.db.delete(
      tableItems,
      where: '${ItemFields.id} = ?',
      whereArgs: [item.id],
    );

    for (final ItemPart ip in item.itemParts) {
      await ip.db.delete();
    }
  }
}
