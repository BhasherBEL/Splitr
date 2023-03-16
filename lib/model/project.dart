import 'package:shared/model/participant.dart';
import 'package:shared/model/item.dart';
import 'package:shared/model/app_data.dart';
import 'package:shared/model/project_participant.dart';

const String tableProjects = 'projects';

class ProjectFields {
  static const values = [
    id,
    name,
  ];

  static const String id = '_id';
  static const String name = 'name';
}

class Project {
  Project({
    this.id,
    required this.name,
  }) {
    db = _ProjectDB(this);
    AppData.projects.add(this);
  }

  int? id;
  String name;
  late _ProjectDB db;
  final List<Item> items = [];
  final List<Participant> participants = [];

  Map<String, Object?> toJson() => {
        ProjectFields.id: id,
        ProjectFields.name: name,
      };

  void addParticipant(Participant participant) {
    participants.add(participant);
  }

  static Project fromJson(Map<String, Object?> json) {
    return Project(
      id: json[ProjectFields.id] as int?,
      name: json[ProjectFields.name] as String,
    );
  }

  static Project? fromId(int id) {
    return AppData.projects.firstWhere((element) => element.id == id);
  }

  static Future<Set<Project>> getAllProjects() async {
    final res = await AppData.db.query(
      tableProjects,
      columns: ProjectFields.values,
    );
    return res.map((e) => fromJson(e)).toSet();
  }

  @override
  bool operator ==(Object other) {
    return other is Project && name == other.name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  void addItem(Item item) {
    items.add(item);
    items.sort((a, b) => -a.date.compareTo(b.date));
  }

  void deleteItem(Item item) {
    items.remove(item);
  }

  static Project? fromName(String s) {
    return AppData.projects.isEmpty
        ? null
        : AppData.projects.firstWhere((element) => element.name == s);
  }
}

class _ProjectDB {
  _ProjectDB(this.project);

  Project project;

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
      await item.db.loadParts();
    }
  }

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

  Future<bool> delete() async {
    bool res = await AppData.db.delete(
          tableProjects,
          where: '${ProjectFields.id} = ?',
          whereArgs: [project.id],
        ) >
        0;
    if (res) {
      for (Item item in project.items) {
        await item.db.delete();
      }
    }
    return res;
  }
}
