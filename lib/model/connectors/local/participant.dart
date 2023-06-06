import 'package:shared/model/app_data.dart';
import 'package:shared/model/connectors/local/deleted.dart';

import '../../participant.dart';

const String tableParticipants = 'participants';

class LocalParticipant {
  LocalParticipant(this.participant);

  final Participant participant;

  Future save() async {
    if (participant.localId != null) {
      final results = await AppData.db.query(
        tableParticipants,
        where: '${ParticipantFields.localId} = ?',
        whereArgs: [participant.localId],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableParticipants,
          participant.toJson(),
          where: '${ParticipantFields.localId} = ?',
          whereArgs: [participant.localId],
        );
        participant.project.notSyncCount++;
        return;
      }
    }

    participant.localId =
        await AppData.db.insert(tableParticipants, participant.toJson());
    participant.project.notSyncCount++;
  }

  Future delete() async {
    await AppData.db.delete(
      tableParticipants,
      where: '${ParticipantFields.localId} = ?',
      whereArgs: [participant.localId],
    );

    if (participant.remoteId != null) {
      await LocalDeleted.add(
        'participants',
        participant.remoteId!,
        participant.project,
        DateTime.now(),
      );
    }
  }
}
