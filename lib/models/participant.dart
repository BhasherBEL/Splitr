import 'package:splitr/models/data.dart';

import '../data/local/participant.dart';
import 'project.dart';

class ParticipantFields {
  static const values = [
    localId,
    remoteId,
    projectId,
    pseudo,
    lastname,
    firstname,
    lastUpdate,
    deleted,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String projectId = 'project_id';
  static const String pseudo = 'pseudo';
  static const String lastname = 'lastname';
  static const String firstname = 'firstname';
  static const String lastUpdate = 'last_update';
  static const String deleted = 'deleted';
}

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

  Map<String, Object?> toJson() => {
        ParticipantFields.localId: localId,
        ParticipantFields.remoteId: remoteId,
        ParticipantFields.projectId: project.localId,
        ParticipantFields.pseudo: pseudo,
        ParticipantFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
        ParticipantFields.deleted: deleted ? 1 : 0,
      };

  static Participant fromJson(Project p, Map<String, Object?> json) {
    return Participant(
      localId: json[ParticipantFields.localId] as int?,
      remoteId: json[ParticipantFields.remoteId] as String?,
      project: p,
      pseudo: json[ParticipantFields.pseudo] as String,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[ParticipantFields.lastUpdate] as int),
      deleted: (json[ParticipantFields.deleted] as int) == 1,
    );
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
