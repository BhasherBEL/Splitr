import 'package:pocketbase/pocketbase.dart';
import 'package:splitr/models/group.dart';
import 'package:splitr/models/group_membership.dart';
import 'package:splitr/utils/ext/datetime.dart';
import 'package:splitr/utils/ext/record_service.dart';
import 'package:tuple/tuple.dart';

import '../../models/participant.dart';
import 'item_part.dart';

class PocketBaseGroupMembershipFields {
  static const String id = 'id';
  static const String groupId = 'group_id';
  static const String participantId = 'participant_id';
  static const String deleted = 'deleted';
}

class PocketBaseGroupMembership {
  static Map<String, dynamic> toJson(GroupMembership gm) {
    return {
      PocketBaseGroupMembershipFields.groupId: gm.group.remoteId,
      PocketBaseGroupMembershipFields.participantId: gm.participant.remoteId,
      PocketBaseItemPartsFields.deleted: gm.deleted,
    };
  }

  static Tuple2<bool, GroupMembership> fromRecord(RecordModel e, Group group) {
    GroupMembership? g = group.memberByRemoteId(e.id);

    Participant participant = group.project.participantByRemoteId(
        e.getStringValue(PocketBaseGroupMembershipFields.participantId))!;
    DateTime lastUpdate = DateTime.parse(e.updated);
    bool deleted = e.getBoolValue(PocketBaseItemPartsFields.deleted);

    if (g == null) {
      g = GroupMembership(
        group: group,
        participant: participant,
        lastUpdate: lastUpdate,
        remoteId: e.id,
        deleted: deleted,
      );
      return Tuple2(true, g);
    }
    if (lastUpdate > g.lastUpdate) {
      g.participant = participant;
      g.lastUpdate = lastUpdate;
      g.deleted = deleted;
      return Tuple2(true, g);
    }

    return Tuple2(false, g);
  }

  static Future<bool> sync(PocketBase pb, Group group) async {
    RecordService collection = pb.collection('groupMemberships');

    // Get new dist records
    List<RecordModel> records = await collection.getFullList(
      filter:
          'updated > "${group.project.lastSync.toUtc()}" && ${PocketBaseGroupMembershipFields.groupId} = "${group.remoteId}"',
    );

    // Apply new dist records if newer
    Set<GroupMembership> distUpdated = {};
    for (RecordModel e in records) {
      Tuple2<bool, GroupMembership> res = fromRecord(e, group);
      if (res.item1) {
        if (!group.members.contains(res.item2)) group.members.add(res.item2);
        distUpdated.add(res.item2);
        await res.item2.conn.save();
      }
    }

    // Send local new records
    for (GroupMembership gm in group.members) {
      if (distUpdated.contains(gm)) continue;

      if (gm.lastUpdate > group.project.lastSync) {
        RecordModel rm =
            await collection.updateOrCreate(id: gm.remoteId, body: toJson(gm));
        gm.remoteId = rm.id;
      }
    }

    return true;
  }
}
