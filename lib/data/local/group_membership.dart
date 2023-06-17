import 'package:splitr/models/group.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/group_membership.dart';
import 'generic.dart';

String tableGroupMembership = 'groupMemberships';

class LocalGroupMembershipFields {
  static const values = [
    localId,
    remoteId,
    groupId,
    participantId,
    lastUpdate,
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String groupId = 'group_id';
  static const String participantId = 'participant_id';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

class LocalGroupMembership extends LocalGeneric {
  LocalGroupMembership(this.groupMembership);

  final GroupMembership groupMembership;

  @override
  Future<bool> save() async {
    groupMembership.localId = await AppData.db.insert(
      tableGroupMembership,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  Map<String, Object?> toJson() => {
        LocalGroupMembershipFields.localId: groupMembership.localId,
        LocalGroupMembershipFields.remoteId: groupMembership.remoteId,
        LocalGroupMembershipFields.groupId: groupMembership.group.localId,
        LocalGroupMembershipFields.lastUpdate: groupMembership.lastUpdate,
        LocalGroupMembershipFields.deleted: groupMembership.deleted,
      };

  static GroupMembership fromJson(Group group, Map<String, Object?> json) {
    return GroupMembership(
      localId: json[LocalGroupMembershipFields.localId] as int?,
      remoteId: json[LocalGroupMembershipFields.remoteId] as String?,
      group: group,
      participant: group.project.participants.firstWhere((e) =>
          e.localId == json[LocalGroupMembershipFields.participantId] as int),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[LocalGroupMembershipFields.lastUpdate] as int),
      deleted: (json[LocalGroupMembershipFields.deleted] as int) == 1,
    );
  }
}
