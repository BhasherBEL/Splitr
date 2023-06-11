import 'package:splitr/model/data.dart';

import 'item_part.dart';
import 'participant.dart';
import 'project.dart';

import 'connectors/local/item.dart';

class ItemFields {
  static const values = [
    localId,
    remoteId,
    project,
    title,
    emitter,
    amount,
    date,
    lastUpdate,
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String project = 'project';
  static const String title = 'title';
  static const String emitter = 'emitter';
  static const String amount = 'amount';
  static const String date = 'date';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

class Item extends Data {
  Item({
    super.localId,
    super.remoteId,
    required this.project,
    required String title,
    required Participant emitter,
    required double amount,
    required DateTime date,
    super.lastUpdate,
    super.deleted,
  }) {
    _title = title;
    _emitter = emitter;
    _amount = amount;
    _date = date;
    super.conn = LocalItem(this);
  }

  Project project;
  late String _title;
  late Participant _emitter;
  late double _amount;
  late DateTime _date;
  List<ItemPart> itemParts = [];

  String get title => _title;
  Participant get emitter => _emitter;
  double get amount => _amount;
  DateTime get date => _date;

  set title(String title) {
    _title = title;
    lastUpdate = DateTime.now();
  }

  set emitter(Participant emitter) {
    _emitter = emitter;
    lastUpdate = DateTime.now();
  }

  set amount(double amount) {
    _amount = amount;
    lastUpdate = DateTime.now();
  }

  set date(DateTime date) {
    _date = date;
    lastUpdate = DateTime.now();
  }

  Map<String, Object?> toJson() => {
        ItemFields.localId: localId,
        ItemFields.remoteId: remoteId,
        ItemFields.project: project.localId,
        ItemFields.title: title,
        ItemFields.emitter: emitter.localId,
        ItemFields.amount: amount,
        ItemFields.date: date.millisecondsSinceEpoch,
        ItemFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
        ItemFields.deleted: deleted ? 1 : 0,
      };

  double shareOf(Participant participant) {
    double totalRate = 0;
    ItemPart? pip;
    double fixedTotal = 0;
    if (itemParts.isNotEmpty) {
      for (ItemPart ip in itemParts) {
        if (ip.participant == participant) pip = ip;
        totalRate += ip.rate ?? 0;
        fixedTotal += ip.amount ?? 0;
      }
    }

    if (pip == null || pip.amount == null && pip.rate == null) {
      return emitter == participant ? amount : 0;
    }
    return (emitter == participant ? amount : 0) -
        (pip.amount ?? pip.rate! * (amount - fixedTotal) / totalRate);
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

    possibilites.sort((a, b) => a.length - b.length);

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
      localId: json[ItemFields.localId] as int?,
      remoteId: json[ItemFields.remoteId] as String?,
      project: p,
      title: json[ItemFields.title] as String,
      emitter: p.participants.firstWhere((participant) =>
          participant.localId == json[ItemFields.emitter] as int),
      amount: json[ItemFields.amount] as double,
      date: DateTime.fromMillisecondsSinceEpoch(json[ItemFields.date] as int),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[ItemFields.lastUpdate] as int),
      deleted: (json[ItemFields.deleted] as int) == 1,
    );
  }

  ItemPart? partByRemoteId(String id) {
    try {
      return itemParts.firstWhere((element) => element.remoteId == id);
    } catch (e) {
      return null;
    }
  }

  ItemPart? partByParticipant(Participant p) {
    try {
      return itemParts.firstWhere((element) => element.participant == p);
    } catch (e) {
      return null;
    }
  }
}
