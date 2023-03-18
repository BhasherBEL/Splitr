import 'package:shared/model/participant.dart';
import 'package:shared/model/item.dart';

import 'connectors/itempart_connector.dart';
import 'connectors/local/item_part.dart';

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
    conn = LocalItemPart(this);
  }

  int? id;
  Item item;
  Participant participant;
  double? rate;
  double? amount;
  late ItemPartConnector conn;

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
