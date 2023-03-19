import 'package:shared/model/app_data.dart';

import '../../participant.dart';
import '../participant.dart';

const String tableParticipants = 'participants';

class LocalParticipant extends ParticipantConnector {
  LocalParticipant(super.participant);

  @override
  static Future<Set<Participant>> getAll() async {
    final res = await AppData.db.query(
      tableParticipants,
    );

    return res.map((e) => Participant.fromJson(e)).toSet();
  }

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

  @override
  Future delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }
}
