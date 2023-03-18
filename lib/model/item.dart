import 'package:shared/model/item_part.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';

import 'connectors/item_connector.dart';
import 'connectors/local/item.dart';

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
  Item({
    this.id,
    required this.project,
    required this.title,
    required this.emitter,
    required this.amount,
    required this.date,
  }) {
    conn = LocalItem(this);
  }

  int? id;
  Project project;
  String title;
  Participant emitter;
  double amount;
  DateTime date;
  List<ItemPart> itemParts = [];
  late ItemConnector conn;

  Map<String, Object?> toJson() => {
        ItemFields.id: id,
        ItemFields.project: project.id,
        ItemFields.title: title,
        ItemFields.emitter: emitter.id,
        ItemFields.amount: amount,
        ItemFields.date: date.millisecondsSinceEpoch,
      };

  double shareOf(Participant participant) {
    double totalRate = 0;
    ItemPart? pip;
    if (itemParts.isNotEmpty) {
      for (ItemPart ip in itemParts) {
        if (ip.participant == participant) pip = ip;
        totalRate += ip.rate ?? 0;
      }
    }

    if (pip == null || pip.amount == null && pip.rate == null) {
      return emitter == participant ? amount : 0;
    }
    // return (emitter == participant ? amount : 0) - rate * amount / totalRate;
    return (emitter == participant ? amount : 0) -
        (pip.amount ?? pip.rate! * amount / totalRate);
  }

  String toParticipantsString() {
    List<Participant> participants =
        itemParts.map((e) => e.participant).toList();

    if (itemParts.length < 4) {
      return itemParts.map((e) => e.participant.pseudo).join(", ");
    }
    if (itemParts.length == project.participants.length) return 'All';

    List<String> possibilites = [
      itemParts.map((e) => e.participant.pseudo).join(", "),
      'All except ${project.participants.where((element) => !participants.contains(element)).map((e) => e.pseudo).join(', ')}',
    ];

    possibilites.sort();

    return possibilites.first;
  }

  static Item fromJson(Map<String, Object?> json, {Project? project}) {
    Project p;
    if (project != null) {
      p = project;
    } else {
      p = Project.fromId(json[ItemFields.project] as int)!;
    }

    return Item(
      id: json[ItemFields.id] as int?,
      project: p,
      title: json[ItemFields.title] as String,
      emitter: p.participants.firstWhere(
          (participant) => participant.id == json[ItemFields.emitter] as int),
      amount: json[ItemFields.amount] as double,
      date: DateTime.fromMillisecondsSinceEpoch(json[ItemFields.date] as int),
    );
  }
}
