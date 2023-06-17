import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/participant.dart';
import '../../models/project.dart';
import 'generic.dart';

const String tableParticipants = 'participants';

class LocalParticipantFields {
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

class LocalParticipant extends LocalGeneric {
  LocalParticipant(this.participant);

  final Participant participant;

  @override
  Future<bool> save() async {
    participant.localId = await AppData.db.insert(
      tableParticipants,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    participant.project.notSyncCount++;
    return true;
  }

  Map<String, Object?> toJson() => {
        LocalParticipantFields.localId: participant.localId,
        LocalParticipantFields.remoteId: participant.remoteId,
        LocalParticipantFields.projectId: participant.project.localId,
        LocalParticipantFields.pseudo: participant.pseudo,
        LocalParticipantFields.lastUpdate:
            DateTime.now().millisecondsSinceEpoch,
        LocalParticipantFields.deleted: participant.deleted ? 1 : 0,
      };

  static Participant fromJson(Project p, Map<String, Object?> json) {
    return Participant(
      localId: json[LocalParticipantFields.localId] as int?,
      remoteId: json[LocalParticipantFields.remoteId] as String?,
      project: p,
      pseudo: json[LocalParticipantFields.pseudo] as String,
      lastUpdate: DateTime.fromMillisecondsSinceEpoch(
          json[LocalParticipantFields.lastUpdate] as int),
      deleted: (json[LocalParticipantFields.deleted] as int) == 1,
    );
  }
}
