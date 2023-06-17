import '../data/local/participant.dart';
import 'data.dart';
import 'project.dart';

class Participant extends Data {
  Participant({
    super.localId,
    super.remoteId,
    required this.project,
    required String pseudo,
    super.lastUpdate,
    super.deleted,
  }) {
    _pseudo = pseudo;
    super.conn = LocalParticipant(this);
  }

  Project project;
  late String _pseudo;

  String get pseudo => _pseudo;

  set pseudo(String v) {
    _pseudo = v;
    lastUpdate = DateTime.now();
  }

  @override
  bool operator ==(Object other) {
    return other is Participant && pseudo == other.pseudo;
  }

  @override
  int get hashCode {
    return pseudo.hashCode;
  }
}
