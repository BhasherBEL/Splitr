import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/project.dart';
import 'package:shared/utils/time.dart';

import '../../participant.dart';

class PocketBaseParticipantFields {
  static const String id = "id";
  static const String pseudo = "pseudo";
  static const String firstname = "firstname";
  static const String lastname = "lastname";
}

class PocketBaseParticipant {
  PocketBaseParticipant(this.lastSync, this.participant, this.pb) {
    collection = pb.collection("participants");
  }

  final PocketBase pb;
  final Participant participant;
  final DateTime lastSync;
  late final RecordService collection;

  Future delete() async {
    if (participant.remoteId != null) {
      await collection.delete(participant.remoteId!);
    }
  }

  Future<bool> sync() async {
    if (participant.remoteId == null ||
        participant.lastUpdate.difference(lastSync).inMilliseconds > 0) {
      await push();
    } else {
      await pullIf();
    }
    return true;
  }

  Future push() async {
    if (participant.remoteId == null) {
      await create();
    } else {
      await update();
    }
  }

  Future create() async {
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseParticipantFields.pseudo: participant.pseudo,
        PocketBaseParticipantFields.lastname: participant.lastname,
        PocketBaseParticipantFields.firstname: participant.firstname,
      },
    );
    participant.remoteId = recordModel.id;
    await participant.conn.save();
  }

  Future update() async {
    await collection.update(
      participant.remoteId!,
      body: <String, dynamic>{
        PocketBaseParticipantFields.pseudo: participant.pseudo,
        PocketBaseParticipantFields.lastname: participant.lastname,
        PocketBaseParticipantFields.firstname: participant.firstname,
      },
    );
  }

  Future pullIf() async {
    RecordModel record = await collection.getOne(participant.remoteId!);
    DateTime updated = DateTime.parse(record.updated);
    if (updated.millisecondsSinceEpoch >
        participant.lastUpdate.millisecondsSinceEpoch) {
      participant.pseudo =
          record.getStringValue(PocketBaseParticipantFields.pseudo);
      participant.firstname =
          record.getStringValue(PocketBaseParticipantFields.firstname);
      participant.lastname =
          record.getStringValue(PocketBaseParticipantFields.lastname);
      participant.lastUpdate = updated;
    }
    await participant.conn.save();
  }

  static Future<List<Participant>> pullNewFrom(
      PocketBase pb, Project project) async {
    print(project.lastSync.toPocketTime());
    List<RecordModel> records = await pb.collection("participants").getFullList(
          filter: 'updated > "${project.lastSync}"',
        );

    return records
        .map(
          (e) => Participant(
            project: project,
            pseudo: e.getStringValue(PocketBaseParticipantFields.pseudo),
            firstname: e.getStringValue(PocketBaseParticipantFields.firstname),
            lastname: e.getStringValue(PocketBaseParticipantFields.lastname),
            remoteId: e.id,
          ),
        )
        .toList();
  }
}
