import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/external_connector.dart';
import 'package:shared/model/connectors/pocketbase/deleted.dart';
import 'package:shared/model/item_part.dart';
import 'package:shared/model/project.dart';

import '../../item.dart';

class PocketBaseItemPartsFields {
  static const String id = "id";
  static const String itemId = "item_id";
  static const String participantId = "participant_id";
  static const String rate = "rate";
  static const String amount = "amount";
}

class PocketBaseItemPart implements ExternalConnector {
  PocketBaseItemPart(this.project, this.itemPart, this.pb) {
    collection = pb.collection("itemParts");
  }

  final PocketBase pb;
  final ItemPart itemPart;
  final Project project;
  late final RecordService collection;

  @override
  Future<bool> delete() async {
    if (itemPart.remoteId != null) {
      await collection.delete(itemPart.remoteId!);
      await PocketBaseDeleted.delete(
        pb,
        project,
        "itemParts",
        itemPart.remoteId!,
      );
    }
    return true;
  }

  @override
  Future<bool> pushIfChange() async {
    if (itemPart.remoteId == null) {
      await create();
    } else if (itemPart.lastUpdate.difference(project.lastSync).inMilliseconds >
        0) {
      await update();
    }
    return true;
  }

  @override
  Future<bool> create() async {
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseItemPartsFields.itemId: itemPart.item.remoteId,
        PocketBaseItemPartsFields.participantId: itemPart.participant.remoteId,
        PocketBaseItemPartsFields.amount: itemPart.amount,
        PocketBaseItemPartsFields.rate: itemPart.rate,
      },
    );
    itemPart.remoteId = recordModel.id;
    await itemPart.conn.save();
    return true;
  }

  @override
  Future<bool> update() async {
    await collection.update(
      itemPart.remoteId!,
      body: <String, dynamic>{
        PocketBaseItemPartsFields.itemId: itemPart.item.remoteId,
        PocketBaseItemPartsFields.participantId: itemPart.participant.remoteId,
        PocketBaseItemPartsFields.amount: itemPart.amount,
        PocketBaseItemPartsFields.rate: itemPart.rate,
      },
    );
    return true;
  }

  static Future<bool> checkNews(
    PocketBase pb,
    Project project,
    Item item,
  ) async {
    List<RecordModel> records = await pb.collection("itemParts").getFullList(
          filter:
              'updated > "${project.lastSync.toUtc()}" && ${PocketBaseItemPartsFields.itemId} = "${item.remoteId}"',
        );
    for (RecordModel e in records) {
      ItemPart? i = item.partByRemoteId(e.id);
      if (i == null) {
        i = ItemPart(
          item: item,
          participant: project.participantByRemoteId(
              e.getStringValue(PocketBaseItemPartsFields.participantId))!,
          amount: e.getStringValue(PocketBaseItemPartsFields.amount).isEmpty
              ? null
              : e.getDoubleValue(PocketBaseItemPartsFields.amount),
          rate: e.getDoubleValue(PocketBaseItemPartsFields.rate),
          lastUpdate: DateTime.parse(e.updated),
          remoteId: e.id,
        );
        item.itemParts.add(i);
      } else {
        i.participant = project.participantByRemoteId(
            e.getStringValue(PocketBaseItemPartsFields.participantId))!;
        i.amount = e.getStringValue(PocketBaseItemPartsFields.amount).isEmpty
            ? null
            : e.getDoubleValue(PocketBaseItemPartsFields.amount);
        i.rate = e.getDoubleValue(PocketBaseItemPartsFields.rate);
        i.lastUpdate = DateTime.parse(e.updated);
      }
      await i.conn.save();
    }
    return true;
  }
}
