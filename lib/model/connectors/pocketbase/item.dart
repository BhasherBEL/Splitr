import 'package:pocketbase/pocketbase.dart';
import 'package:splitr/model/participant.dart';
import 'package:splitr/utils/extenders/datetime.dart';
import 'package:splitr/utils/extenders/collections.dart';
import 'package:splitr/utils/extenders/pocketbase.dart';
import 'package:tuple/tuple.dart';

import '../../item.dart';
import '../../project.dart';
import 'item_part.dart';

class PocketBaseItemsFields {
  static const String id = "id";
  static const String title = "title";
  static const String emitterId = "emitter_id";
  static const String projectId = "project_id";
  static const String amount = "amount";
  static const String date = "date";
  static const String deleted = "deleted";
}

class PocketBaseItem {
  static Map<String, dynamic> toJson(Item i) {
    return {
      PocketBaseItemsFields.title: i.title,
      PocketBaseItemsFields.emitterId: i.emitter.remoteId,
      PocketBaseItemsFields.projectId: i.project.remoteId,
      PocketBaseItemsFields.amount: i.amount,
      PocketBaseItemsFields.date: i.date.toUtc().toString(),
      PocketBaseItemPartsFields.deleted: i.deleted,
    };
  }

  static Tuple2<bool, Item> fromRecord(RecordModel e, Project project) {
    Item? i = project.itemByRemoteId(e.id);

    double amount = e.getDoubleValue(PocketBaseItemsFields.amount);
    DateTime date =
        DateTime.parse(e.getStringValue(PocketBaseItemsFields.date));
    Participant emitter = project.participantByRemoteId(
        e.getStringValue(PocketBaseItemsFields.emitterId))!;
    String title = e.getStringValue(PocketBaseItemsFields.title);
    DateTime lastUpdate = DateTime.parse(e.updated);
    bool deleted = e.getBoolValue(PocketBaseItemPartsFields.deleted);

    if (i == null) {
      i = Item(
        project: project,
        amount: amount,
        date: date,
        emitter: emitter,
        title: title,
        lastUpdate: lastUpdate,
        remoteId: e.id,
        deleted: deleted,
      );
      return Tuple2(true, i);
    }
    if (lastUpdate > i.lastUpdate) {
      i.amount = amount;
      i.date = date;
      i.emitter = emitter;
      i.title = title;
      i.lastUpdate = lastUpdate;
      i.deleted = deleted;
      return Tuple2(true, i);
    }

    return Tuple2(false, i);
  }

  static Future<bool> sync(PocketBase pb, Project project) async {
    RecordService collection = pb.collection("items");

    // Get new dist records
    List<RecordModel> records = await collection.getFullList(
      filter:
          'updated > "${project.lastSync.toUtc()}" && ${PocketBaseItemsFields.projectId} = "${project.remoteId}"',
    );

    // Apply new dist records if newer
    Set<Item> distUpdated = {};
    for (RecordModel e in records) {
      Tuple2<bool, Item> res = fromRecord(e, project);
      if (res.item1) {
        project.items.setPresence(!res.item2.deleted, res.item2);
        distUpdated.add(res.item2);
        await res.item2.conn.save();
      }
    }

    // Send local new records
    for (Item i in project.items.toList()) {
      if (distUpdated.contains(i)) continue;

      if (i.lastUpdate > project.lastSync) {
        RecordModel rm =
            await collection.updateOrCreate(id: i.remoteId, body: toJson(i));
        i.remoteId = rm.id;
        project.items.setPresence(!i.deleted, i);
      }
    }

    project.items.sort((a, b) => -a.date.compareTo(b.date));

    return true;
  }
}
