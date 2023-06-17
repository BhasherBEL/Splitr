import 'package:splitr/models/data.dart';
import 'package:splitr/models/group_membership.dart';

import '../data/local/group.dart';
import 'project.dart';

class Group extends Data {
  Group({
    super.localId,
    super.remoteId,
    required this.project,
    required String name,
    super.lastUpdate,
    super.deleted,
  }) {
    _name = name;
    super.conn = LocalGroup(this);
  }

  Project project;
  late String _name;
  Set<GroupMembership> members = {};

  String get name => _name;

  set name(String v) {
    _name = v;
    lastUpdate = DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    return other is Group && remoteId != null && other.remoteId != null
        ? remoteId == other.remoteId
        : name == (other as Group).name;
  }

  @override
  int get hashCode {
    return name.hashCode;
  }

  GroupMembership? memberByRemoteId(String id) {
    try {
      return members.firstWhere((element) => element.remoteId == id);
    } catch (e) {
      return null;
    }
  }
}
