import 'package:shared/model/connectors/provider.dart';

import 'app_data.dart';
import 'connectors/local/project.dart';
import 'item.dart';
import 'participant.dart';

class ProjectFields {
  static const values = [
    localId,
    remoteId,
    name,
    currentParticipant,
    providerId,
    providerData,
    lastSync,
    lastUpdate,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String name = 'name';
  static const String currentParticipant = 'current_participant';
  static const String providerId = 'provider_id';
  static const String providerData = 'provider_data';
  static const String lastSync = 'last_sync';
  static const String lastUpdate = 'last_update';
}

class Project {
  Project({
    this.localId,
    this.remoteId,
    this.currentParticipant,
    required this.name,
    required int providerId,
    String providerData = '',
    DateTime? lastSync,
    DateTime? lastUpdate,
  }) {
    provider = Provider.initFromId(providerId, this, providerData);
    conn = LocalProject(this);
    AppData.projects.add(this);
    if (lastSync == null) {
      this.lastSync = DateTime(1970);
    } else {
      this.lastSync = lastSync;
    }
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }

  int? localId;
  String? remoteId;
  String name;
  Participant? currentParticipant;
  late Provider provider;
  late LocalProject conn;
  final List<Item> items = [];
  final List<Participant> participants = [];
  late DateTime lastSync;
  late DateTime lastUpdate;

  double shareOf(Participant participant) {
    return ([0.0] + items.map((e) => e.shareOf(participant)).toList())
        .reduce((a, b) => a + b);
  }

  Map<String, Object?> toJson() => {
        ProjectFields.localId: localId,
        ProjectFields.remoteId: remoteId,
        ProjectFields.name: name,
        ProjectFields.currentParticipant: currentParticipant?.localId,
        ProjectFields.providerId: provider.id,
        ProjectFields.providerData: provider.data,
        ProjectFields.lastSync: lastSync.millisecondsSinceEpoch,
        ProjectFields.lastUpdate: lastUpdate.millisecondsSinceEpoch,
      };

  static Project fromJson(Map<String, Object?> json) {
    return Project(
      localId: json[ProjectFields.localId] as int?,
      remoteId: json[ProjectFields.remoteId] as String?,
      name: json[ProjectFields.name] as String,
      providerId: json[ProjectFields.providerId] as int,
      providerData: json[ProjectFields.providerData] as String,
      lastSync: DateTime.fromMillisecondsSinceEpoch(
          json[ProjectFields.lastSync] as int),
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[ProjectFields.lastUpdate]
              as int //? ?? DateTime.now().millisecondsSinceEpoch
          ),
    );
  }

  static Project? fromId(int localId) {
    return AppData.projects.firstWhere((element) => element.localId == localId);
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

  Future<bool> sync() async {
    DateTime st = DateTime.now();
    bool res = await provider.sync();
    print('Synced in ${DateTime.now().difference(st).inMilliseconds / 1000}s');
    return res;
  }

  Participant? participantByRemoteId(String id) {
    try {
      return participants.firstWhere((element) => element.remoteId == id);
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
}
