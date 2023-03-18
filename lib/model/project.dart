import 'app_data.dart';
import 'connectors/local/project.dart';
import 'item.dart';
import 'participant.dart';

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
    db = LocalProject(this);
    AppData.projects.add(this);
  }

  int? id;
  String name;
  late LocalProject db;
  final List<Item> items = [];
  final List<Participant> participants = [];

  Map<String, Object?> toJson() => {
        ProjectFields.id: id,
        ProjectFields.name: name,
      };

  void addParticipant(Participant participant) {
    participants.add(participant);
  }

  double shareOf(Participant participant) {
    return ([0.0] + items.map((e) => e.shareOf(participant)).toList())
        .reduce((a, b) => a + b);
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
