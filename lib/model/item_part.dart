import 'data.dart';
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
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String itemId = 'item';
  static const String participantId = 'participant';
  static const String rate = 'rate';
  static const String amount = 'amount';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

class ItemPart extends Data {
  ItemPart({
    super.localId,
    super.remoteId,
    required this.item,
    required this.participant,
    double? rate,
    double? amount,
    super.lastUpdate,
    super.deleted,
  }) {
    _rate = rate;
    _amount = amount;
    super.conn = LocalItemPart(this);
  }

  Item item;
  Participant participant;
  double? _rate;
  double? _amount;

  double? get rate => _rate;
  double? get amount => _amount;

  set rate(double? rate) {
    _rate = rate;
    lastUpdate = DateTime.now();
  }

  set amount(double? amount) {
    _amount = amount;
    lastUpdate = DateTime.now();
  }

  Map<String, Object?> toJson() => {
        ItemPartFields.localId: localId,
        ItemPartFields.remoteId: remoteId,
        ItemPartFields.itemId: item.localId,
        ItemPartFields.participantId: participant.localId,
        ItemPartFields.rate: rate,
        ItemPartFields.amount: amount,
        ItemPartFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
        ItemPartFields.deleted: deleted ? 1 : 0,
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
      deleted: (json[ItemPartFields.deleted] as int) == 1,
    );
  }
}
