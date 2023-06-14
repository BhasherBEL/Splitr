import 'package:splitr/data/local/generic.dart';
import 'package:sqflite/sqlite_api.dart';

import '../../models/app_data.dart';
import '../../models/item.dart';
import '../../models/item_part.dart';
import 'item_part.dart';

const String tableItems = 'items';

class LocalItem extends LocalGeneric {
  LocalItem(this.item);

  final Item item;

  Future loadParts() async {
    item.itemParts = (await AppData.db.query(
      tableItemParts,
      columns: ItemPartFields.values,
      where: "${ItemPartFields.itemId} = ?",
      whereArgs: [item.localId],
    ))
        .map((e) => ItemPart.fromJson(e, item))
        .toList();
  }

  @override
  Future<bool> save() async {
    item.localId = await AppData.db.insert(
      tableItems,
      item.toJson(),
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
}
