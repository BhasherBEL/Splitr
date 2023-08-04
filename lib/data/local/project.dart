import 'package:splitr/data/local/group.dart';
import 'package:splitr/models/group.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/instance.dart';
import '../../models/item.dart';
import '../../models/participant.dart';
import '../../models/project.dart';
import '../../utils/helper/random.dart';
import 'generic.dart';
import 'item.dart';
import 'participant.dart';

const String tableProjects = 'projects';

class LocalProjectFields {
  static const values = [
    localId,
    remoteId,
    name,
    code,
    currentParticipant,
    instance,
    lastSync,
    lastUpdate,
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String name = 'name';
  static const String code = 'code';
  static const String currentParticipant = 'current_participant';
  static const String instance = 'instance';
  static const String lastSync = 'last_sync';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

class LocalProject extends LocalGeneric {
  LocalProject(this.project);

  final Project project;

  static Future<Set<Project>> getAllProjects() async {
    final res = await AppData.db.query(
      tableProjects,
      columns: LocalProjectFields.values,
    );
    return res.map((e) => fromJson(e)).toSet();
  }

  Future loadParticipants() async {
    final rawParticipants = await AppData.db.query(
      tableParticipants,
      columns: LocalParticipantFields.values,
      where:
          '${LocalParticipantFields.projectId} = ? AND (${LocalParticipantFields.deleted} == 0 OR ${LocalParticipantFields.lastUpdate} > ?)',
      whereArgs: [project.localId, project.lastSync.millisecondsSinceEpoch],
    );

    project.participants.clear();

    for (Map<String, Object?> e in rawParticipants) {
      Participant participant = LocalParticipant.fromJson(project, e);
      if (project.currentParticipant == null &&
          project.currentParticipantId == participant.localId) {
        project.currentParticipant = participant;
      }
      project.participants.add(participant);
    }
  }

  Future<int> loadEntries() async {
    final rawItems = await AppData.db.query(
      tableItems,
      where:
          '${LocalItemFields.projectId} = ? AND (${LocalItemFields.deleted} == 0 OR ${LocalItemFields.lastUpdate} > ?)',
      whereArgs: [project.localId, project.lastSync.millisecondsSinceEpoch],
      orderBy: '${LocalItemFields.date} DESC',
    );

    project.items.clear();
    int err = 0;

    for (Map<String, Object?> e in rawItems) {
      try {
        Item item = LocalItem.fromJson(e, project: project);
        project.items.add(item);
        await (item.conn as LocalItem).loadParts();
      } on StateError {
        err++;
      }
    }
    return err;
  }

  Future loadGroups() async {
    final rawGroups = await AppData.db.query(
      tableGroup,
      where:
          '${LocalGroupFields.projectId} = ? AND (${LocalGroupFields.deleted} == 0 OR ${LocalGroupFields.lastUpdate} > ?)',
      whereArgs: [project.localId, project.lastSync.millisecondsSinceEpoch],
    );

    project.groups.clear();

    for (Map<String, Object?> e in rawGroups) {
      Group group = LocalGroup.fromJson(project, e);
      project.groups.add(group);
      await (group.conn as LocalGroup).loadMembers();
    }
  }

  @override
  Future<bool> save() async {
    project.lastUpdate = DateTime.now();
    project.localId = await AppData.db.insert(
      tableProjects,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    project.notSyncCount++;
    return true;
  }

  Map<String, Object?> toJson() {
    return {
      LocalProjectFields.localId: project.localId,
      LocalProjectFields.remoteId: project.remoteId,
      LocalProjectFields.name: project.name,
      LocalProjectFields.code: project.code ?? getRandom(5),
      LocalProjectFields.currentParticipant:
          project.currentParticipant?.localId,
      LocalProjectFields.instance: project.provider.instance.localId,
      LocalProjectFields.lastSync: project.lastSync.millisecondsSinceEpoch,
      LocalProjectFields.lastUpdate: project.lastUpdate.millisecondsSinceEpoch,
      LocalProjectFields.deleted: project.deleted ? 1 : 0,
    };
  }

  static Project fromJson(Map<String, Object?> json) {
    return Project(
      localId: json[LocalProjectFields.localId] as int?,
      remoteId: json[LocalProjectFields.remoteId] as String?,
      name: json[LocalProjectFields.name] as String,
      code: json[LocalProjectFields.code] as String?,
      currentParticipantId: json[LocalProjectFields.currentParticipant] as int?,
      instance: Instance.fromId(json[LocalProjectFields.instance] as int) ??
          Instance.fromName('local')!,
      lastSync: DateTime.fromMillisecondsSinceEpoch(
          json[LocalProjectFields.lastSync] as int),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[LocalProjectFields.lastUpdate]
              as int //? ?? DateTime.now().millisecondsSinceEpoch
          ),
      deleted: (json[LocalProjectFields.deleted] as int) == 1,
    );
  }

  Future<bool> delete() async {
    int a = await AppData.db.delete(tableProjects,
        where: '${LocalProjectFields.localId} = ?',
        whereArgs: [project.localId]);
    a += await AppData.db.delete(tableParticipants,
        where: '${LocalParticipantFields.projectId} = ?',
        whereArgs: [project.localId]);
    a += await AppData.db.delete(tableItems,
        where: '${LocalItemFields.projectId} = ?',
        whereArgs: [project.localId]);
    // await AppData.db.query(tableItemParts, where: '${LocalItemPartFields.itemId} = ?', whereArgs: [project.localId]);
    a += await AppData.db.delete(tableGroup,
        where: '${LocalGroupFields.projectId} = ?',
        whereArgs: [project.localId]);
    // await AppData.db.query(tableGroupMembership, where: '${LocalGroupMembershipFields.groupId} = ?', whereArgs: [project.localId]);
    return a > 0;
  }
}
