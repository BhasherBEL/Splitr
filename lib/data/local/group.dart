import 'package:splitr/data/local/group_membership.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/group.dart';
import '../../models/project.dart';
import 'generic.dart';

String tableGroup = 'groups';

class LocalGroupFields {
  static const values = [
    localId,
    remoteId,
    projectId,
    lastUpdate,
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String projectId = 'project_id';
  static const String name = 'name';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

class LocalGroup extends LocalGeneric {
  LocalGroup(this.group);

  final Group group;

  @override
  Future<bool> save() async {
    group.localId = await AppData.db.insert(
      tableGroup,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return true;
  }

  Map<String, Object?> toJson() => {
        LocalGroupFields.localId: group.localId,
        LocalGroupFields.remoteId: group.remoteId,
        LocalGroupFields.projectId: group.project.localId,
        LocalGroupFields.name: group.name,
        LocalGroupFields.lastUpdate: group.lastUpdate,
        LocalGroupFields.deleted: group.deleted,
      };

  static Group fromJson(Project p, Map<String, Object?> json) {
    return Group(
      localId: json[LocalGroupFields.localId] as int?,
      remoteId: json[LocalGroupFields.remoteId] as String?,
      project: p,
      name: json[LocalGroupFields.name] as String,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[LocalGroupFields.lastUpdate] as int),
      deleted: (json[LocalGroupFields.deleted] as int) == 1,
    );
  }

  Future loadMembers() async {
    group.members = (await AppData.db.query(
      tableGroupMembership,
      columns: LocalGroupMembershipFields.values,
      where: '${LocalGroupMembershipFields.groupId} = ?',
      whereArgs: [group.localId],
    ))
        .map((e) => LocalGroupMembership.fromJson(group, e))
        .toSet();
  }
}
