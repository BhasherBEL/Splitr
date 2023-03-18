import '../../app_data.dart';
import '../../item_part.dart';
import '../itempart_connector.dart';

const String tableItemParts = 'itemParts';

class LocalItemPart extends ItemPartConnector {
  LocalItemPart(super.itemPart);

  @override
  Future save() async {
    if (itemPart.id != null) {
      final results = await AppData.db.query(
        tableItemParts,
        where: 'id = ?',
        whereArgs: [itemPart.id],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableItemParts,
          itemPart.toJson(),
          where: 'id = ?',
          whereArgs: [itemPart.id],
        );
        return;
      }
    }
    itemPart.id = await AppData.db.insert(tableItemParts, itemPart.toJson());
  }

  @override
  Future delete() async {
    await AppData.db.delete(
      tableItemParts,
      where: '${ItemPartFields.id} = ?',
      whereArgs: [itemPart.id],
    );
  }
}
