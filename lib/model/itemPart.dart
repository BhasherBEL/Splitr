import 'package:shared/model/participant.dart';
import 'package:shared/model/item.dart';

import '../db/shared_database.dart';
import 'app_data.dart';

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
  ItemPart({
    this.id,
    required this.item,
    required this.participant,
    this.rate,
    this.amount,
  }) {
    db = _ItemPartDB(this);
  }

  int? id;
  Item item;
  Participant participant;
  double? rate;
  double? amount;
  late _ItemPartDB db;

  Map<String, Object?> toJson() => {
        ItemPartFields.id: id,
        ItemPartFields.itemId: item.id,
        ItemPartFields.participantId: participant.id,
        ItemPartFields.rate: rate,
        ItemPartFields.amount: amount,
      };

  static ItemPart fromJson(Map<String, Object?> json, Item item) {
    return ItemPart(
      id: json[ItemPartFields.id] as int?,
      item: item,
      participant: item.project.participants
          .firstWhere((e) => e.id == json[ItemPartFields.participantId] as int),
      rate: json[ItemPartFields.rate] as double?,
      amount: json[ItemPartFields.amount] as double?,
    );
  }
}

class _ItemPartDB {
  _ItemPartDB(this.itemPart);

  final ItemPart itemPart;

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

  Future delete() async {
    await AppData.db.delete(
      tableItemParts,
      where: '${ItemPartFields.id} = ?',
      whereArgs: [itemPart.id],
    );
  }
}
