import 'package:shared/model/connectors/participant.dart';

import 'app_data.dart';
import 'connectors/local/participant.dart';

class ParticipantFields {
  static const values = [
    localId,
    remoteId,
    pseudo,
    lastname,
    firstname,
    lastUpdate,
  ];

  static const String localId = 'local_id';
  static const String remoteId = 'remote_id';
  static const String pseudo = 'pseudo';
  static const String lastname = 'lastname';
  static const String firstname = 'firstname';
  static const String lastUpdate = 'last_update';
}

class Participant {
  Participant({
    this.localId,
    this.remoteId,
    required this.pseudo,
    this.lastname,
    this.firstname,
    DateTime? lastUpdate,
  }) {
    conn = LocalParticipant(this);
    AppData.participants.add(this);
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }

  int? localId;
  String? remoteId;
  String pseudo;
  String? lastname;
  String? firstname;
  late ParticipantConnector conn;
  late DateTime lastUpdate;

  static Participant? fromId(int localId) {
    return AppData.participants.isEmpty
        ? null
        : AppData.participants
            .firstWhere((element) => element.localId == localId);
  }

  Map<String, Object?> toJson() => {
        ParticipantFields.localId: localId,
        ParticipantFields.remoteId: remoteId,
        ParticipantFields.pseudo: pseudo,
        ParticipantFields.lastname: lastname,
        ParticipantFields.firstname: firstname,
        ParticipantFields.lastUpdate: DateTime.now().millisecondsSinceEpoch,
      };

  static Participant fromJson(Map<String, Object?> json) {
    return Participant(
      localId: json[ParticipantFields.localId] as int?,
      remoteId: json[ParticipantFields.remoteId] as String?,
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
