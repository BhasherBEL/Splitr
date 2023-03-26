import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/external_connector.dart';
import 'package:shared/model/connectors/pocketbase/deleted.dart';
import 'package:shared/model/connectors/pocketbase/item_part.dart';
import 'package:shared/model/project.dart';

import '../../item.dart';

class PocketBaseItemsFields {
  static const String id = "id";
  static const String title = "title";
  static const String emitterId = "emitter_id";
  static const String projectId = "project_id";
  static const String amount = "amount";
  static const String date = "date";
}

class PocketBaseItem implements ExternalConnector {
  PocketBaseItem(this.project, this.item, this.pb) {
    collection = pb.collection("items");
  }

  final PocketBase pb;
  final Item item;
  final Project project;
  late final RecordService collection;

  @override
  Future<bool> delete() async {
    if (item.remoteId != null) {
      await collection.delete(item.remoteId!);
      await PocketBaseDeleted.delete(
        pb,
        project,
        "items",
        item.remoteId!,
      );
    }
    return true;
  }

  @override
  Future<bool> pushIfChange() async {
    if (item.remoteId == null) {
      await create();
    } else if (item.lastUpdate.difference(project.lastSync).inMilliseconds >
        0) {
      await update();
    }
    return true;
  }

  @override
  Future<bool> create() async {
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseItemsFields.title: item.title,
        PocketBaseItemsFields.emitterId: item.emitter.remoteId,
        PocketBaseItemsFields.projectId: item.project.remoteId,
        PocketBaseItemsFields.amount: item.amount,
        PocketBaseItemsFields.date: item.date.toUtc().toString(),
      },
    );
    item.remoteId = recordModel.id;
    await item.conn.save();
    return true;
  }

  @override
  Future<bool> update() async {
    await collection.update(
      item.remoteId!,
      body: <String, dynamic>{
        PocketBaseItemsFields.title: item.title,
        PocketBaseItemsFields.emitterId: item.emitter.remoteId,
        PocketBaseItemsFields.projectId: item.project.remoteId,
        PocketBaseItemsFields.amount: item.amount,
        PocketBaseItemsFields.date: item.date.toUtc().toString(),
      },
    );
    return true;
  }

  static Future<bool> checkNews(PocketBase pb, Project project) async {
    List<RecordModel> records = await pb.collection("items").getFullList(
          filter:
              'updated > "${project.lastSync.toUtc()}" && ${PocketBaseItemsFields.projectId} = "${project.remoteId}"',
        );
    for (RecordModel e in records) {
      Item? i = project.itemByRemoteId(e.id);
      if (i == null) {
        i = Item(
          project: project,
          amount: e.getDoubleValue(PocketBaseItemsFields.amount),
          date: DateTime.parse(e.getStringValue(PocketBaseItemsFields.date)),
          emitter: project.participantByRemoteId(
              e.getStringValue(PocketBaseItemsFields.emitterId))!,
          title: e.getStringValue(PocketBaseItemsFields.title),
          lastUpdate: DateTime.parse(e.updated),
          remoteId: e.id,
        );
        project.items.add(i);
      } else {
        i.amount = e.getDoubleValue(PocketBaseItemsFields.amount);
        i.date = DateTime.parse(e.getStringValue(PocketBaseItemsFields.date));
        i.emitter = project.participantByRemoteId(
            e.getStringValue(PocketBaseItemsFields.emitterId))!;
        i.title = e.getStringValue(PocketBaseItemsFields.title);
        i.lastUpdate = DateTime.parse(e.updated);
      }
      await i.conn.save();
      await PocketBaseItemPart.checkNews(pb, project, i);
    }
    return true;
  }
}
