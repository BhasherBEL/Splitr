import 'package:pocketbase/pocketbase.dart';
import 'package:splitr/utils/extenders/datetime.dart';
import 'package:splitr/utils/extenders/collections.dart';
import 'package:splitr/utils/extenders/pocketbase.dart';
import 'package:tuple/tuple.dart';

import '../../item.dart';
import '../../item_part.dart';
import '../../participant.dart';
import '../../project.dart';

class PocketBaseItemPartsFields {
  static const String id = "id";
  static const String itemId = "item_id";
  static const String participantId = "participant_id";
  static const String rate = "rate";
  static const String amount = "amount";
  static const String deleted = "deleted";
}

class PocketBaseItemPart {
  static Map<String, dynamic> toJson(ItemPart i) {
    return {
      PocketBaseItemPartsFields.itemId: i.item.remoteId,
      PocketBaseItemPartsFields.participantId: i.participant.remoteId,
      PocketBaseItemPartsFields.amount: i.amount,
      PocketBaseItemPartsFields.rate: i.rate,
      PocketBaseItemPartsFields.deleted: i.deleted,
    };
  }

  static Tuple2<bool, ItemPart> fromRecord(RecordModel e, Item item) {
    ItemPart? i = item.partByRemoteId(e.id);

    Participant participant = item.project.participantByRemoteId(
        e.getStringValue(PocketBaseItemPartsFields.participantId))!;
    double? amount = e.getDoubleOrNullValue(PocketBaseItemPartsFields.amount);
    double? rate = e.getDoubleOrNullValue(PocketBaseItemPartsFields.rate);
    DateTime lastUpdate = DateTime.parse(e.updated);
    bool deleted = e.getBoolValue(PocketBaseItemPartsFields.deleted);

    if (i == null) {
      i = ItemPart(
        item: item,
        participant: participant,
        amount: amount,
        rate: rate,
        lastUpdate: lastUpdate,
        remoteId: e.id,
        deleted: deleted,
      );
      return Tuple2(true, i);
    }
    if (lastUpdate > i.lastUpdate) {
      i.participant = participant;
      i.amount = amount;
      i.rate = rate;
      i.lastUpdate = lastUpdate;
      i.deleted;
      return Tuple2(true, i);
    }
    return Tuple2(false, i);
  }

  static Future<bool> sync(PocketBase pb, Item item) async {
    RecordService collection = pb.collection("itemParts");

    // Get new dist records
    List<RecordModel> records = await collection.getFullList(
      filter:
          'updated > "${item.project.lastSync.toUtc()}" && ${PocketBaseItemPartsFields.itemId} = "${item.remoteId}"',
    );

    // Apply new dist records if newer
    Set<ItemPart> distUpdated = {};
    for (RecordModel e in records) {
      Tuple2<bool, ItemPart> res = fromRecord(e, item);
      if (res.item1) {
        item.itemParts.setPresence(!res.item2.deleted, res.item2);
        distUpdated.add(res.item2);
        await res.item2.conn.save();
      }
    }

    // Send local new records
    for (ItemPart ip in item.itemParts.toList()) {
      if (distUpdated.contains(ip)) continue;

      if (ip.lastUpdate > item.project.lastSync) {
        RecordModel rm =
            await collection.updateOrCreate(id: ip.remoteId, body: toJson(ip));
        ip.remoteId = rm.id;
        item.itemParts.setPresence(!ip.deleted, ip);
      }
    }

    return true;
  }
}
