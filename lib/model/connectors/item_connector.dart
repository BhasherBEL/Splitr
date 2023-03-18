import '../item.dart';
import '../item_part.dart';

abstract class ItemConnector {
  ItemConnector(this.item);

  final Item item;

  Future loadParts();

  Future save();

  Future saveRecursively() async {
    await save();
    for (final ItemPart ip in item.itemParts) {
      await ip.conn.save();
    }
  }

  Future delete();
}
