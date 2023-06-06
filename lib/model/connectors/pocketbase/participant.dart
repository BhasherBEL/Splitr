import 'package:pocketbase/pocketbase.dart';

import '../../participant.dart';
import '../../project.dart';
import '../external_connector.dart';
import 'deleted.dart';

class PocketBaseParticipantFields {
  static const String id = "id";
  static const String pseudo = "pseudo";
  static const String firstname = "firstname";
  static const String lastname = "lastname";
  static const String projectId = "project_id";
}

class PocketBaseParticipant implements ExternalConnector {
  PocketBaseParticipant(this.project, this.participant, this.pb) {
    collection = pb.collection("participants");
  }

  final PocketBase pb;
  final Participant participant;
  final Project project;
  late final RecordService collection;

  @override
  Future<bool> delete() async {
    if (participant.remoteId != null) {
      await collection.delete(participant.remoteId!);
      await PocketBaseDeleted.delete(
        pb,
        project,
        "participants",
        participant.remoteId!,
      );
    }
    return true;
  }

  @override
  Future<bool> pushIfChange() async {
    if (participant.remoteId == null) {
      await create();
    } else if (participant.lastUpdate
            .difference(project.lastSync)
            .inMilliseconds >
        0) {
      await update();
    }
    return true;
  }

  @override
  Future<bool> create() async {
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseParticipantFields.projectId: project.remoteId,
        PocketBaseParticipantFields.pseudo: participant.pseudo,
        PocketBaseParticipantFields.lastname: participant.lastname,
        PocketBaseParticipantFields.firstname: participant.firstname,
      },
    );
    participant.remoteId = recordModel.id;
    await participant.conn.save();
    return true;
  }

  @override
  Future<bool> update() async {
    await collection.update(
      participant.remoteId!,
      body: <String, dynamic>{
        PocketBaseParticipantFields.projectId: project.remoteId,
        PocketBaseParticipantFields.pseudo: participant.pseudo,
        PocketBaseParticipantFields.lastname: participant.lastname,
        PocketBaseParticipantFields.firstname: participant.firstname,
      },
    );
    return true;
  }

  static Future<bool> checkNews(PocketBase pb, Project project) async {
    List<RecordModel> records = await pb.collection("participants").getFullList(
          filter:
              'updated > "${project.lastSync.toUtc()}" && ${PocketBaseParticipantFields.projectId} = "${project.remoteId}"',
        );
    for (RecordModel e in records) {
      Participant? p = project.participantByRemoteId(e.id);
      if (p == null) {
        p = Participant(
          project: project,
          pseudo: e.getStringValue(PocketBaseParticipantFields.pseudo),
          firstname: e.getStringValue(PocketBaseParticipantFields.firstname),
          lastname: e.getStringValue(PocketBaseParticipantFields.lastname),
          lastUpdate: DateTime.parse(e.updated),
          remoteId: e.id,
        );
        project.participants.add(p);
      } else {
        p.pseudo = e.getStringValue(PocketBaseParticipantFields.pseudo);
        p.firstname = e.getStringValue(PocketBaseParticipantFields.firstname);
        p.lastname = e.getStringValue(PocketBaseParticipantFields.lastname);
        p.lastUpdate = DateTime.parse(e.updated);
      }
      await p.conn.save();
    }
    ;
    return true;
  }
}
