import '../../app_data.dart';
import '../../item.dart';
import '../../participant.dart';
import '../../project.dart';
import 'item.dart';
import 'participant.dart';

const String tableProjects = 'projects';

class LocalProject {
  LocalProject(this.project);

  final Project project;

  Future loadEntries() async {
    final rawItems = await AppData.db.query(
      tableItems,
      where: '${ItemFields.project} = ?',
      whereArgs: [project.localId],
      orderBy: '${ItemFields.date} DESC',
    );

    project.items.clear();

    for (Map<String, Object?> e in rawItems) {
      Item item = Item.fromJson(e, project: project);
      project.items.add(item);
      await item.conn.loadParts();
    }
  }

  Future loadParticipants() async {
    final rawParticipants = await AppData.db.query(
      tableParticipants,
      columns: ParticipantFields.values,
      where: '${ParticipantFields.projectId} = ${project.localId}',
    );

    project.participants.clear();

    for (Map<String, Object?> e in rawParticipants) {
      project.participants.add(Participant.fromJson(project, e));
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
        return;
      }
    }

    project.localId = await AppData.db.insert(tableProjects, project.toJson());
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
    }
    return res;
  }
}
