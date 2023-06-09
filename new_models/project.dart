import 'package:objectbox/objectbox.dart';

import 'item.dart';
import 'participant.dart';

@Entity()
class Project {
  @Id()
  int id;

  @Index()
  String? remoteId;

  String name;

  String? code;

  final currentParticipant = ToOne<Participant?>();

  @Backlink('project')
  final items = ToMany<Item>();

  @Backlink('project')
  final participants = ToMany<Participant>();

  @Property(type: PropertyType.date)
  DateTime? lastSync;

  @Property(type: PropertyType.date)
  DateTime lastUpdate;

  Project({
    this.id = 0,
    this.remoteId,
    required this.name,
    this.code,
    this.lastSync,
    DateTime? lastUpdate,
  }) : lastUpdate = lastUpdate ?? DateTime.now();
}

void a() {
  Project project = Project(name: "Hello world");
  Item item = Item(
    title: "Breakfast",
    date: DateTime.now(),
  );
  project.items.add(item);
}
