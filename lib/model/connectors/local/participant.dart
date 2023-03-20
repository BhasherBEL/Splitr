import 'package:shared/model/app_data.dart';

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
        return;
      }
    }

    participant.localId =
        await AppData.db.insert(tableParticipants, participant.toJson());
  }

  Future delete() {
    throw UnimplementedError();
  }
}
