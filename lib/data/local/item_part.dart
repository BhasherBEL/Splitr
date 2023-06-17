import 'package:splitr/data/local/generic.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/item.dart';
import '../../models/item_part.dart';

const String tableItemParts = 'itemParts';

class LocalItemPartFields {
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

class LocalItemPart extends LocalGeneric {
  LocalItemPart(this.itemPart);

  final ItemPart itemPart;

  @override
  Future<bool> save() async {
    itemPart.localId = await AppData.db.insert(
      tableItemParts,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    itemPart.item.project.notSyncCount++;
    return true;
  }

  Map<String, Object?> toJson() => {
        LocalItemPartFields.localId: itemPart.localId,
        LocalItemPartFields.remoteId: itemPart.remoteId,
        LocalItemPartFields.itemId: itemPart.item.localId,
        LocalItemPartFields.participantId: itemPart.participant.localId,
        LocalItemPartFields.rate: itemPart.rate,
        LocalItemPartFields.amount: itemPart.amount,
        LocalItemPartFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
        LocalItemPartFields.deleted: itemPart.deleted ? 1 : 0,
      };

  static ItemPart fromJson(Map<String, Object?> json, Item item) {
    return ItemPart(
      localId: json[LocalItemPartFields.localId] as int?,
      remoteId: json[LocalItemPartFields.remoteId] as String?,
      item: item,
      participant: item.project.participants.firstWhere(
          (e) => e.localId == json[LocalItemPartFields.participantId] as int),
      rate: json[LocalItemPartFields.rate] as double?,
      amount: json[LocalItemPartFields.amount] as double?,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[LocalItemPartFields.lastUpdate] as int),
      deleted: (json[LocalItemPartFields.deleted] as int) == 1,
    );
  }
}
