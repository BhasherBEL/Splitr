import 'package:shared/model/item.dart';
import 'package:shared/model/participant.dart';

const String tableItemParts = 'itemParts';

class ItemPartFields {
  static const values = [
    id,
    item,
    participant,
    rate,
    amount,
  ];

  static const String id = '_id';
  static const String item = 'item';
  static const String participant = 'participant';
  static const String rate = 'rate';
  static const String amount = 'amount';
}

class ItemPart {
  const ItemPart({
    this.id,
    required this.item,
    required this.participant,
    this.rate,
    this.amount,
  });

  final int? id;
  final Item item;
  final Participant participant;
  final double? rate;
  final double? amount;

  Map<String, Object?> toJson() => {
        ItemPartFields.id: id,
        ItemPartFields.item: item.id,
        ItemPartFields.participant: participant.id,
        ItemPartFields.rate: rate,
        ItemPartFields.amount: amount,
      };

  // static ItemPart fromJson(Map<String, Object?> json) {
  //   return ItemPart(
  //     id: json[ItemPartFields.id] as int?,
  //     item: Item.fromId(json[ItemPartFields.item as int]),
  //     participant: Participant.fromId(json[ItemPartFields.participant as int]),
  //     rate: json[ItemPartFields.rate] as double?,
  //     amount: json[ItemPartFields.amount] as double?,
  //   );
  // }
}
