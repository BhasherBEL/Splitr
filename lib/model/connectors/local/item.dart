import '../../app_data.dart';
import '../../item.dart';
import '../../item_part.dart';
import 'deleted.dart';
import 'item_part.dart';

const String tableItems = 'items';

class LocalItem {
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

  Future save() async {
    if (item.localId != null) {
      final results = await AppData.db.query(
        tableItems,
        where: '${ItemFields.localId} = ?',
        whereArgs: [item.localId],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableItems,
          item.toJson(),
          where: '${ItemFields.localId} = ?',
          whereArgs: [item.localId],
        );
        item.project.notSyncCount++;
        return;
      }
    }
    item.localId = await AppData.db.insert(tableItems, item.toJson());
    item.project.notSyncCount++;
  }

  Future delete() async {
    await AppData.db.delete(
      tableItems,
      where: '${ItemFields.localId} = ?',
      whereArgs: [item.localId],
    );

    if (item.remoteId != null) {
      await LocalDeleted.add(
        'items',
        item.remoteId!,
        item.project,
        DateTime.now(),
      );
    }

    for (final ItemPart ip in item.itemParts) {
      await ip.conn.delete();
    }
  }

  Future saveRecursively() async {
    await save();
    for (final ItemPart ip in item.itemParts) {
      await ip.conn.save();
    }
  }
}
