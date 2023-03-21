import 'package:shared/model/project.dart';

import 'connectors/local/participant.dart';

class ParticipantFields {
  static const values = [
    localId,
    remoteId,
    projectId,
    pseudo,
    lastname,
    firstname,
    lastUpdate,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String projectId = 'project_id';
  static const String pseudo = 'pseudo';
  static const String lastname = 'lastname';
  static const String firstname = 'firstname';
  static const String lastUpdate = 'last_update';
}

class Participant {
  Participant({
    this.localId,
    this.remoteId,
    required this.project,
    required this.pseudo,
    this.lastname,
    this.firstname,
    DateTime? lastUpdate,
  }) {
    conn = LocalParticipant(this);
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }

  int? localId;
  String? remoteId;
  Project project;
  String pseudo;
  String? lastname;
  String? firstname;
  late LocalParticipant conn;
  late DateTime lastUpdate;

  Map<String, Object?> toJson() => {
        ParticipantFields.localId: localId,
        ParticipantFields.remoteId: remoteId,
        ParticipantFields.projectId: project.localId,
        ParticipantFields.pseudo: pseudo,
        ParticipantFields.lastname: lastname,
        ParticipantFields.firstname: firstname,
        ParticipantFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
      };

  static Participant fromJson(Project p, Map<String, Object?> json) {
    return Participant(
      localId: json[ParticipantFields.localId] as int?,
      remoteId: json[ParticipantFields.remoteId] as String?,
      project: p,
      pseudo: json[ParticipantFields.pseudo] as String,
      lastname: json[ParticipantFields.lastname] as String?,
      firstname: json[ParticipantFields.firstname] as String?,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[ParticipantFields.lastUpdate] as int),
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
