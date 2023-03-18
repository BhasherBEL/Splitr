import '../../app_data.dart';
import '../../item.dart';
import '../../item_part.dart';
import '../item_connector.dart';
import 'item_part.dart';

const String tableItems = 'items';

class LocalItem extends ItemConnector {
  LocalItem(super.item);

  @override
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

  @override
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

  @override
  Future delete() async {
    await AppData.db.delete(
      tableItems,
      where: '${ItemFields.id} = ?',
      whereArgs: [item.id],
    );

    for (final ItemPart ip in item.itemParts) {
      await ip.conn.delete();
    }
  }
}
