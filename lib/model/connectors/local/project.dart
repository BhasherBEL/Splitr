import '../../app_data.dart';
import '../../item.dart';
import '../../participant.dart';
import '../../project.dart';
import 'deleted.dart';
import 'item.dart';
import 'participant.dart';

const String tableProjects = 'projects';

class LocalProject {
  LocalProject(this.project);

  final Project project;

  Future<int> loadEntries() async {
    final rawItems = await AppData.db.query(
      tableItems,
      where: '${ItemFields.project} = ?',
      whereArgs: [project.localId],
      orderBy: '${ItemFields.date} DESC',
    );

    project.items.clear();
    int err = 0;

    for (Map<String, Object?> e in rawItems) {
      try {
        Item item = Item.fromJson(e, project: project);
        project.items.add(item);
        await item.conn.loadParts();
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
      where: '${ParticipantFields.projectId} = ${project.localId}',
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

  Future save() async {
    project.lastUpdate = DateTime.now();
    if (project.localId != null) {
      final results = await AppData.db.query(
        tableProjects,
        where: '${ProjectFields.localId} = ?',
        whereArgs: [project.localId],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableProjects,
          project.toJson(),
          where: '${ProjectFields.localId} = ?',
          whereArgs: [project.localId],
        );
        project.notSyncCount++;
        return;
      }
    }

    project.localId = await AppData.db.insert(tableProjects, project.toJson());
    project.notSyncCount++;
  }

  Future delete() async {
    bool res = await AppData.db.delete(
          tableProjects,
          where: '${ProjectFields.localId} = ?',
          whereArgs: [project.localId],
        ) >
        0;
    if (res) {
      for (Item item in project.items) {
        await item.conn.delete();
      }

      await AppData.db.delete(
        tableDeleted,
        where: '${DeletedFields.projectId} = ?',
        whereArgs: [project.remoteId],
      );
    }
    return res;
  }
}
