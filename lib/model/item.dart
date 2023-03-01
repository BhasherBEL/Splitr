import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';

const String tableItems = 'items';

class ItemFields {
  static const values = [
    id,
    project,
    title,
    emitter,
    amount,
    date,
  ];

  static const String id = '_id';
  static const String project = 'project';
  static const String title = 'title';
  static const String emitter = 'emitter';
  static const String amount = 'amount';
  static const String date = 'date';
}

class Item {
  const Item({
    this.id,
    required this.projectId,
    required this.title,
    required this.emitterId,
    required this.amount,
    required this.date,
  });

  final int? id;
  final int projectId;
  final String title;
  final int emitterId;
  final double amount;

  final DateTime date;
  Map<String, Object?> toJson() => {
        ItemFields.id: id,
        ItemFields.project: projectId,
        ItemFields.title: title,
        ItemFields.emitter: emitterId,
        ItemFields.amount: amount,
        ItemFields.date: date.millisecondsSinceEpoch,
      };

  static Item fromJson(Map<String, Object?> json) {
    return Item(
      id: json[ItemFields.id] as int?,
      projectId: json[ItemFields.project] as int,
      title: json[ItemFields.title] as String,
      emitterId: json[ItemFields.emitter] as int,
      amount: json[ItemFields.amount] as double,
      date: DateTime.fromMillisecondsSinceEpoch(json[ItemFields.date] as int),
    );
  }
}
