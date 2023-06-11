import 'package:splitr/model/connectors/local/generic.dart';
import 'package:sqflite/sqflite.dart';

import '../../app_data.dart';
import '../../item.dart';
import '../../participant.dart';
import '../../project.dart';
import 'item.dart';
import 'participant.dart';

const String tableProjects = 'projects';

class LocalProject extends LocalGeneric {
  LocalProject(this.project);

  final Project project;

  Future<int> loadEntries() async {
    final rawItems = await AppData.db.query(
      tableItems,
      where:
          '${ItemFields.project} = ? AND (${ItemFields.deleted} == 0 OR ${ItemFields.lastUpdate} > ?)',
      whereArgs: [project.localId, project.lastSync.millisecondsSinceEpoch],
      orderBy: '${ItemFields.date} DESC',
    );

    project.items.clear();
    int err = 0;

    for (Map<String, Object?> e in rawItems) {
      try {
        Item item = Item.fromJson(e, project: project);
        project.items.add(item);
        await (item.conn as LocalItem).loadParts();
      } on StateError {
        err++;
      }
    }
    return err;
  }

  Future loadParticipants() async {
    final rawParticipants = await AppData.db.query(
      tableParticipants,
      columns: ParticipantFields.values,
      where:
          '${ParticipantFields.projectId} = ? AND (${ParticipantFields.deleted} == 0 OR ${ParticipantFields.lastUpdate} > ?)',
      whereArgs: [project.localId, project.lastSync.millisecondsSinceEpoch],
    );

    project.participants.clear();

    for (Map<String, Object?> e in rawParticipants) {
      Participant participant = Participant.fromJson(project, e);
      if (project.currentParticipant == null &&
          project.currentParticipantId == participant.localId) {
        project.currentParticipant = participant;
      }
      project.participants.add(participant);
    }
  }

  @override
  Future<bool> save() async {
    project.lastUpdate = DateTime.now();
    project.localId = await AppData.db.insert(
      tableProjects,
      project.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    project.notSyncCount++;
    return true;
  }
}
