import '../../app_data.dart';
import '../../item_part.dart';

const String tableItemParts = 'itemParts';

class LocalItemPart {
  LocalItemPart(this.itemPart);

  final ItemPart itemPart;

  Future save() async {
    if (itemPart.localId != null) {
      final results = await AppData.db.query(
        tableItemParts,
        where: '${ItemPartFields.localId} = ?',
        whereArgs: [itemPart.localId],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableItemParts,
          itemPart.toJson(),
          where: '${ItemPartFields.localId} = ?',
          whereArgs: [itemPart.localId],
        );
        return;
      }
    }
    itemPart.localId =
        await AppData.db.insert(tableItemParts, itemPart.toJson());
  }

  Future delete() async {
    await AppData.db.delete(
      tableItemParts,
      where: '${ItemPartFields.localId} = ?',
      whereArgs: [itemPart.localId],
    );
  }
}
