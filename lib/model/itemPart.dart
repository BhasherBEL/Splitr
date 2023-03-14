import 'package:shared/model/item.dart';

import '../db/shared_database.dart';

const String tableItemParts = 'itemParts';

class ItemPartFields {
  static const values = [
    id,
    itemId,
    participantId,
    rate,
    amount,
  ];

  static const String id = '_id';
  static const String itemId = 'item';
  static const String participantId = 'participant';
  static const String rate = 'rate';
  static const String amount = 'amount';
}

class ItemPart {
  const ItemPart({
    this.id,
    required this.itemId,
    required this.participantId,
    required this.rate,
    // this.amount,
  });

  final int? id;
  final int itemId;
  final int participantId;
  final double rate;
  // final double? amount;

  Map<String, Object?> toJson() => {
        ItemPartFields.id: id,
        ItemPartFields.itemId: itemId,
        ItemPartFields.participantId: participantId,
        ItemPartFields.rate: rate,
      };

  ItemPart copyWith({
    final int? id,
    final int? itemId,
    final int? participantId,
    final double? rate,
  }) {
    return ItemPart(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      participantId: participantId ?? this.participantId,
      rate: rate ?? this.rate,
    );
  }

  static Future<ItemPart> fromValues(
    int itemId,
    int participantId,
    int rate,
  ) async {
    final db = await SharedDatabase.instance.database;
    ItemPart itemPart = ItemPart(
        itemId: itemId, participantId: participantId, rate: rate.toDouble());
    final id = await db.insert(
      tableItemParts,
      itemPart.toJson(),
    );
    return itemPart.copyWith(id: id);
  }

  static ItemPart fromJson(Map<String, Object?> json) {
    return ItemPart(
      id: json[ItemPartFields.id] as int?,
      itemId: json[ItemPartFields.itemId] as int,
      participantId: json[ItemPartFields.participantId] as int,
      rate: json[ItemPartFields.rate] as double,
    );
  }
}
