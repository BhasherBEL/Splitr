import 'package:pocketbase/pocketbase.dart';
import 'package:splitr/models/group.dart';
import 'package:splitr/utils/ext/datetime.dart';
import 'package:splitr/utils/ext/list.dart';
import 'package:splitr/utils/ext/record_service.dart';
import 'package:tuple/tuple.dart';

import '../../models/project.dart';
import 'item_part.dart';

class PocketBaseGroupFields {
  static const String id = 'id';
  static const String projectId = 'project_id';
  static const String name = 'name';
  static const String deleted = 'deleted';
}

class PocketBaseGroup {
  static Map<String, dynamic> toJson(Group g) {
    return {
      PocketBaseGroupFields.projectId: g.project.remoteId,
      PocketBaseGroupFields.name: g.name,
      PocketBaseItemPartsFields.deleted: g.deleted,
    };
  }

  static Tuple2<bool, Group> fromRecord(RecordModel e, Project project) {
    Group? g = project.groupByRemoteId(e.id);

    String name = e.getStringValue(PocketBaseGroupFields.name);
    DateTime lastUpdate = DateTime.parse(e.updated);
    bool deleted = e.getBoolValue(PocketBaseItemPartsFields.deleted);

    if (g == null) {
      g = Group(
        project: project,
        name: name,
        lastUpdate: lastUpdate,
        remoteId: e.id,
        deleted: deleted,
      );
      return Tuple2(true, g);
    }
    if (lastUpdate > g.lastUpdate) {
      g.name = name;
      g.lastUpdate = lastUpdate;
      g.deleted = deleted;
      return Tuple2(true, g);
    }

    return Tuple2(false, g);
  }

  static Future<bool> sync(PocketBase pb, Project project) async {
    RecordService collection = pb.collection('groups');

    // Get new dist records
    List<RecordModel> records = await collection.getFullList(
      filter:
          'updated > "${project.lastSync.toUtc()}" && ${PocketBaseGroupFields.projectId} = "${project.remoteId}"',
    );

    // Apply new dist records if newer
    Set<Group> distUpdated = {};
    for (RecordModel e in records) {
      Tuple2<bool, Group> res = fromRecord(e, project);
      if (res.item1) {
        project.groups.setPresence(!res.item2.deleted, res.item2);
        distUpdated.add(res.item2);
        await res.item2.conn.save();
      }
    }

    // Send local new records
    for (Group g in project.groups.toSet()) {
      if (distUpdated.contains(g)) continue;

      if (g.lastUpdate > project.lastSync) {
        RecordModel rm =
            await collection.updateOrCreate(id: g.remoteId, body: toJson(g));
        g.remoteId = rm.id;
        project.groups.setPresence(!g.deleted, g);
      }
    }

    return true;
  }
}
