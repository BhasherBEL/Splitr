import 'package:splitr/data/local/generic.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../models/app_data.dart';
import '../../models/item.dart';
import '../../models/item_part.dart';
import '../../models/project.dart';
import 'item_part.dart';

const String tableItems = 'items';

class LocalItemFields {
  static const values = [
    localId,
    remoteId,
    projectId,
    title,
    emitter,
    amount,
    date,
    lastUpdate,
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String projectId = 'project';
  static const String title = 'title';
  static const String emitter = 'emitter';
  static const String amount = 'amount';
  static const String date = 'date';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

class LocalItem extends LocalGeneric {
  LocalItem(this.item);

  final Item item;

  Future loadParts() async {
    item.itemParts = (await AppData.db.query(
      tableItemParts,
      columns: LocalItemPartFields.values,
      where: '${LocalItemPartFields.itemId} = ?',
      whereArgs: [item.localId],
    ))
        .map((e) => LocalItemPart.fromJson(e, item))
        .toList();
  }

  @override
  Future<bool> save() async {
    item.localId = await AppData.db.insert(
      tableItems,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    item.project.notSyncCount++;
    return true;
  }

  Future saveRecursively() async {
    await save();
    for (final ItemPart ip in item.itemParts) {
      await ip.conn.save();
    }
  }

  Map<String, Object?> toJson() => {
        LocalItemFields.localId: item.localId,
        LocalItemFields.remoteId: item.remoteId,
        LocalItemFields.projectId: item.project.localId,
        LocalItemFields.title: item.title,
        LocalItemFields.emitter: item.emitter.localId,
        LocalItemFields.amount: item.amount,
        LocalItemFields.date: item.date.millisecondsSinceEpoch,
        LocalItemFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
        LocalItemFields.deleted: item.deleted ? 1 : 0,
      };

  static Item fromJson(Map<String, Object?> json, {Project? project}) {
    Project p;
    if (project != null) {
      p = project;
    } else {
      p = Project.fromId(json[LocalItemFields.projectId] as int)!;
    }

    return Item(
      localId: json[LocalItemFields.localId] as int?,
      remoteId: json[LocalItemFields.remoteId] as String?,
      project: p,
      title: json[LocalItemFields.title] as String,
      emitter: p.participants.firstWhere((participant) =>
          participant.localId == json[LocalItemFields.emitter] as int),
      amount: json[LocalItemFields.amount] as double,
      date: DateTime.fromMillisecondsSinceEpoch(
          json[LocalItemFields.date] as int),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[LocalItemFields.lastUpdate] as int),
      deleted: (json[LocalItemFields.deleted] as int) == 1,
    );
  }
}
