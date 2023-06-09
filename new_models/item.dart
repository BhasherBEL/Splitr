import 'package:objectbox/objectbox.dart';
import 'package:splitr/model/participant.dart';

import 'item_part.dart';
import 'project.dart';

@Entity()
class Item {
  @Id()
  int id;

  @Index()
  String? remoteId;

  String title;
  DateTime date;
  DateTime lastUpdate;

  final project = ToOne<Project>();
  final emitter = ToOne<Participant>();
  final itemParts = ToMany<ItemPart>();

  Item(
      {this.id = 0,
      this.remoteId,
      required this.title,
      required this.date,
      DateTime? lastUpdate})
      : lastUpdate = lastUpdate ?? DateTime.now();
}
