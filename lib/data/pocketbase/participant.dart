import 'package:pocketbase/pocketbase.dart';
import 'package:splitr/utils/ext/datetime.dart';
import 'package:splitr/utils/ext/list.dart';
import 'package:splitr/utils/ext/record_service.dart';
import 'package:tuple/tuple.dart';

import '../../models/participant.dart';
import '../../models/project.dart';

class PocketBaseParticipantFields {
  static const String id = 'id';
  static const String pseudo = 'pseudo';
  static const String projectId = 'project_id';
  static const String deleted = 'deleted';
}

class PocketBaseParticipant {
  static Map<String, dynamic> toJson(Participant p) {
    return {
      PocketBaseParticipantFields.projectId: p.project.remoteId,
      PocketBaseParticipantFields.pseudo: p.pseudo,
      PocketBaseParticipantFields.deleted: p.deleted,
    };
  }

  static Tuple2<bool, Participant> fromRecord(RecordModel e, Project project) {
    Participant? p = project.participantByRemoteId(e.id);

    String pseudo = e.getStringValue(PocketBaseParticipantFields.pseudo);
    DateTime lastUpdate = DateTime.parse(e.updated);
    bool deleted = e.getBoolValue(PocketBaseParticipantFields.deleted);

    if (p == null) {
      p = Participant(
        project: project,
        pseudo: pseudo,
        lastUpdate: lastUpdate,
        remoteId: e.id,
        deleted: deleted,
      );
      return Tuple2(true, p);
    }
    if (lastUpdate > p.lastUpdate) {
      p.pseudo = pseudo;
      p.lastUpdate = lastUpdate;
      p.deleted = deleted;
      return Tuple2(true, p);
    }

    return Tuple2(false, p);
  }

  static Future<bool> sync(PocketBase pb, Project project) async {
    RecordService collection = pb.collection('participants');

    // Get new dist records
    List<RecordModel> records = await collection.getFullList(
      filter:
          'updated > "${project.lastSync.toUtc()}" && ${PocketBaseParticipantFields.projectId} = "${project.remoteId}"',
    );

    // Apply new dist records if newer
    Set<Participant> distUpdated = {};
    for (RecordModel e in records) {
      Tuple2<bool, Participant> res = fromRecord(e, project);
      if (res.item1) {
        project.participants.setPresence(!res.item2.deleted, res.item2);
        distUpdated.add(res.item2);
        await res.item2.conn.save();
      }
    }

    // Send local new records
    for (Participant p in project.participants.toList()) {
      if (distUpdated.contains(p)) continue;

      if (p.lastUpdate > project.lastSync) {
        RecordModel rm = await collection.updateOrCreate(
          id: p.remoteId,
          body: toJson(p),
        );
        p.remoteId = rm.id;
        await p.conn.save();
        project.participants.setPresence(!p.deleted, p);
      }
    }

    return true;
  }
}
