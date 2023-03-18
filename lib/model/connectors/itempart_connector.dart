import '../item_part.dart';

abstract class ItemPartConnector {
  ItemPartConnector(this.itemPart);

  final ItemPart itemPart;

  Future save();

  Future delete();
}
