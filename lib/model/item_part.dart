import 'participant.dart';
import 'item.dart';

import 'connectors/local/item_part.dart';

class ItemPartFields {
  static const values = [
    localId,
    remoteId,
    itemId,
    participantId,
    rate,
    amount,
    lastUpdate,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String itemId = 'item';
  static const String participantId = 'participant';
  static const String rate = 'rate';
  static const String amount = 'amount';
  static const String lastUpdate = 'last_update';
}

class ItemPart {
  ItemPart({
    this.localId,
    this.remoteId,
    required this.item,
    required this.participant,
    this.rate,
    this.amount,
    DateTime? lastUpdate,
  }) {
    conn = LocalItemPart(this);
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }

  int? localId;
  String? remoteId;
  Item item;
  Participant participant;
  double? rate;
  double? amount;
  late LocalItemPart conn;
  late DateTime lastUpdate;

  Map<String, Object?> toJson() => {
        ItemPartFields.localId: localId,
        ItemPartFields.remoteId: remoteId,
        ItemPartFields.itemId: item.localId,
        ItemPartFields.participantId: participant.localId,
        ItemPartFields.rate: rate,
        ItemPartFields.amount: amount,
        ItemPartFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
      };

  static ItemPart fromJson(Map<String, Object?> json, Item item) {
    return ItemPart(
      localId: json[ItemPartFields.localId] as int?,
      remoteId: json[ItemPartFields.remoteId] as String?,
      item: item,
      participant: item.project.participants.firstWhere(
          (e) => e.localId == json[ItemPartFields.participantId] as int),
      rate: json[ItemPartFields.rate] as double?,
      amount: json[ItemPartFields.amount] as double?,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[ItemPartFields.lastUpdate] as int),
    );
  }
}
