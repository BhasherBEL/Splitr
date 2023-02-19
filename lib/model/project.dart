import 'package:shared/db/shared_database.dart';

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
  const Project({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  Map<String, Object?> toJson() => {
        ProjectFields.id: id,
        ProjectFields.name: name,
      };

  static Project fromJson(Map<String, Object?> json) {
    return Project(
      id: json[ProjectFields.id] as int,
      name: json[ProjectFields.name] as String,
    );
  }

  static Future<Project> fromValues(String name) async {
    final db = await SharedDatabase.instance.database;
    final id = await db.insert(tableProjects, {ProjectFields.name: name});
    return Project(id: id, name: name);
  }

  static Future<Project?> fromId(int id) async {
    final db = await SharedDatabase.instance.database;
    final projects = await db.query(
      tableProjects,
      columns: ProjectFields.values,
      where: '${ProjectFields.id} = ?',
      whereArgs: [id],
    );

    if (projects.isNotEmpty) return Project.fromJson(projects.first);
    return null;
  }

  static Future<List<Project>> getAllProjects() async {
    final db = await SharedDatabase.instance.database;
    final projects = await db.query(
      tableProjects,
      columns: ProjectFields.values,
    );

    return projects.map((e) => Project.fromJson(e)).toList();
  }

  Future<bool> delete() async {
    final db = await SharedDatabase.instance.database;
    return await db.delete(
          tableProjects,
          where: '${ProjectFields.id} = ?',
          whereArgs: [id],
        ) >
        0;
  }
}
