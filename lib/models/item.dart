import 'package:splitr/models/data.dart';
import 'package:splitr/utils/ext/list.dart';

import 'item_part.dart';
import 'participant.dart';
import 'project.dart';

import '../data/local/item.dart';

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

  double shareOf(Participant participant) {
    double totalRate = 0;
    ItemPart? pip;
    double fixedTotal = 0;
    if (itemParts.isNotEmpty) {
      for (ItemPart ip in itemParts.enabled()) {
        if (ip.participant == participant) pip = ip;
        // print("${ip.participant.pseudo} ${ip.rate}");
        totalRate += ip.rate ?? 0;
        fixedTotal += ip.amount ?? 0;
      }
    }

    // print('$title - ${pip?.participant.pseudo}: $amount ${pip?.amount} ${pip?.rate} $totalRate $fixedTotal');

    if (pip == null || pip.amount == null && pip.rate == null) {
      return emitter == participant ? amount : 0;
    }
    return (emitter == participant ? amount : 0) -
        (pip.amount ?? pip.rate! * (amount - fixedTotal) / totalRate);
  }

  String toParticipantsString() {
    List<Participant> participants =
        itemParts.enabled().map((e) => e.participant).toList();

    if (participants.length < 4) {
      return participants.map((e) => e.pseudo).join(', ');
    }
    if (participants.length == project.participants.length) return 'All';

    List<String> possibilites = [
      participants.map((e) => e.pseudo).join(', '),
      'All except ${project.participants.where((element) => !participants.contains(element)).map((e) => e.pseudo).join(', ')}',
    ];

    possibilites.sort((a, b) => a.length - b.length);

    return possibilites.first;
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
