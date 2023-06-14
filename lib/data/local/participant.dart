import 'package:splitr/data/local/generic.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/participant.dart';

const String tableParticipants = 'participants';

class LocalParticipant extends LocalGeneric {
  LocalParticipant(this.participant);

  final Participant participant;

  @override
  Future<bool> save() async {
    participant.localId = await AppData.db.insert(
      tableParticipants,
      participant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    participant.project.notSyncCount++;
    return true;
  }
}
