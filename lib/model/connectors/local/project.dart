import '../../app_data.dart';
import '../../item.dart';
import '../../participant.dart';
import '../../project.dart';
import '../../project_participant.dart';
import '../project.dart';
import 'item.dart';
import 'participant.dart';

const String tableProjects = 'projects';

class LocalProject extends ProjectConnector {
  LocalProject(super.project);

  @override
  Future loadEntries() async {
    final rawItems = await AppData.db.query(
      tableItems,
      where: '${ItemFields.project} = ?',
      whereArgs: [project.id],
      orderBy: '${ItemFields.date} DESC',
    );

    project.items.clear();

    for (Map<String, Object?> e in rawItems) {
      Item item = Item.fromJson(e, project: project);
      project.items.add(item);
      await item.conn.loadParts();
    }
  }

  @override
  Future loadParticipants() async {
    final rawParticipants = await AppData.db.rawQuery('''
SELECT * FROM $tableProjectParticipants 
LEFT JOIN $tableParticipants ON $tableParticipants.${ParticipantFields.id} = ${ProjectParticipantFields.participantId}
WHERE ${ProjectParticipantFields.projectId} = ${project.id};
''');

    project.participants.clear();

    for (Map<String, Object?> e in rawParticipants) {
      project.participants.add(Participant.fromJson(e));
    }
  }

  @override
  Future save() async {
    if (project.id != null) {
      final results = await AppData.db.query(
        tableProjects,
        where: '${ProjectFields.id} = ?',
        whereArgs: [project.id],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableProjects,
          project.toJson(),
          where: '${ProjectFields.id} = ?',
          whereArgs: [project.id],
        );
        return;
      }
    }

    project.id = await AppData.db.insert(tableProjects, project.toJson());
  }

  @override
  Future saveParticipants() async {
    if (project.id == null) await save();
    for (Participant participant in project.participants) {
      if (participant.id == null) await participant.db.save();
      final results = await AppData.db.query(
        tableProjectParticipants,
        where:
            '${ProjectParticipantFields.participantId} = ? AND ${ProjectParticipantFields.projectId} = ?',
        whereArgs: [participant.id, project.id],
      );
      if (results.isEmpty) {
        await AppData.db.insert(
          tableProjectParticipants,
          {
            ProjectParticipantFields.participantId: participant.id,
            ProjectParticipantFields.projectId: project.id,
          },
        );
      }
    }
  }

  @override
  Future<bool> delete() async {
    bool res = await AppData.db.delete(
          tableProjects,
          where: '${ProjectFields.id} = ?',
          whereArgs: [project.id],
        ) >
        0;
    if (res) {
      for (Item item in project.items) {
        await item.conn.delete();
      }
    }
    return res;
  }
}
