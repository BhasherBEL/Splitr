import 'package:splitr/models/data.dart';
import 'package:splitr/models/group.dart';
import 'package:splitr/models/participant.dart';

import '../data/local/group_membership.dart';

class GroupMembership extends Data {
  GroupMembership({
    super.localId,
    super.remoteId,
    required this.group,
    required this.participant,
    super.lastUpdate,
    super.deleted,
  }) {
    super.conn = LocalGroupMembership(this);
  }

  Group group;
  Participant participant;

  @override
  bool operator ==(Object other) {
    return other is GroupMembership &&
            remoteId != null &&
            other.remoteId != null
        ? remoteId == other.remoteId
        : group == (other as GroupMembership).group &&
            participant == other.participant;
  }

  @override
  int get hashCode {
    return group.hashCode + participant.hashCode;
  }
}
