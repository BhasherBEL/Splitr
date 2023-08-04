import 'package:splitr/models/data.dart';
import 'package:splitr/models/group.dart';
import 'package:splitr/utils/ext/set.dart';
import 'package:tuple/tuple.dart';

import 'app_data.dart';
import '../data/local/project.dart';
import '../data/provider.dart';
import 'instance.dart';
import 'item.dart';
import 'item_part.dart';
import 'participant.dart';

class Project extends Data {
  Project({
    super.localId,
    super.remoteId,
    required String name,
    String? code,
    this.currentParticipantId,
    required Instance instance,
    DateTime? lastSync,
    super.lastUpdate,
    super.deleted,
  }) {
    _name = name;
    _code = code;
    super.conn = LocalProject(this);
    provider = Provider.initFromInstance(this, instance);
    AppData.projects.add(this);
    this.lastSync = lastSync ?? DateTime(1970);
    try {
      currentParticipant = participants
          .firstWhere((element) => element.localId == currentParticipantId);
      // ignore: empty_catches
    } on StateError {}
  }

  late String _name;

  late String? _code;

  int? currentParticipantId;
  Participant? currentParticipant;
  late Provider provider;
  final List<Item> items = [];
  final List<Participant> participants = [];
  final List<Group> groups = [];
  late DateTime lastSync;
  int notSyncCount = 0;

  String get name => _name;
  String? get code => _code;

  set name(String v) {
    _name = v;
    lastUpdate = DateTime.now();
  }

  set code(String? v) {
    _code = v;
    lastUpdate = DateTime.now();
  }

  double shareOf(Participant participant) {
    return ([0.0] + items.map((e) => e.shareOf(participant)).toList())
        .reduce((a, b) => a + b);
  }

  static Project? fromId(int localId) {
    return AppData.projects
        .enabled()
        .firstWhere((element) => element.localId == localId);
  }

  @override
  bool operator ==(Object other) {
    return other is Project &&
        (localId != null ? localId == other.localId : name == other.name);
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
    return AppData.projects.enabled().isEmpty
        ? null
        : AppData.projects.enabled().firstWhere((element) => element.name == s);
  }

  Future<Tuple2<bool, String>> sync() async {
    try {
      DateTime st = DateTime.now();
      bool res = await provider.sync();
      notSyncCount = 0;
      return Tuple2(res,
          (DateTime.now().difference(st).inMilliseconds / 1000).toString());
    } catch (e) {
      return Tuple2(false, e.toString());
    }
  }

  Participant? participantByRemoteId(String id) {
    try {
      return participants.firstWhere((element) => element.remoteId == id);
    } catch (e) {
      return null;
    }
  }

  Participant? participantByPseudo(String pseudo) {
    try {
      return participants.firstWhere((element) => element.pseudo == pseudo);
    } catch (e) {
      return null;
    }
  }

  Item? itemByRemoteId(String id) {
    try {
      return items.firstWhere((element) => element.remoteId == id);
    } catch (e) {
      return null;
    }
  }

  Future deleteParticipant(Participant participant) async {
    participant.deleted = true;
    for (int i = 0; i < items.length; i++) {
      Item item = items[i];
      for (ItemPart ip in List.of(item.itemParts)) {
        if (ip.participant == participant) {
          if (ip.amount != null) {
            item.amount -= ip.amount!;
          } else if (ip.rate != null) {
            item.amount += item.shareOf(participant);
          }
          ip.deleted = true;
          item.itemParts.remove(ip);
          await ip.conn.save();
        }
      }
      if (item.emitter == participant || item.itemParts.isEmpty) {
        item.deleted = true;
        items.remove(item);
        await item.conn.save();
      } else {
        await item.conn.save();
      }
    }

    await participant.conn.save();
  }

  Group? groupByRemoteId(String id) {
    try {
      return groups.firstWhere((element) => element.remoteId == id);
    } catch (e) {
      return null;
    }
  }

  void clear() {
    currentParticipant = null;
    participants.clear();
    items.clear();
    name = '';
    groups.clear();
    lastSync = DateTime(1970);
    notSyncCount = 0;
  }
}
