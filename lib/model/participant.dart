import 'package:shared/model/project.dart';

import '../db/shared_database.dart';
import 'app_data.dart';

const String tableParticipants = 'participants';

class ParticipantFields {
  static const values = [
    id,
    pseudo,
    lastname,
    firstname,
  ];

  static const String id = '_id';
  static const String pseudo = 'pseudo';
  static const String lastname = 'lastname';
  static const String firstname = 'firstname';
}

class Participant {
  Participant({
    this.id,
    required this.pseudo,
    this.lastname,
    this.firstname,
  }) {
    db = _ParticipantDB(this);
    AppData.participants.add(this);
  }

  int? id;
  String pseudo;
  String? lastname;
  String? firstname;
  late _ParticipantDB db;

  static Participant? fromId(int id) {
    return AppData.participants.isEmpty
        ? null
        : AppData.participants.firstWhere((element) => element.id == id);
  }

  static Future<Set<Participant>> getAll() async {
    final db = await SharedDatabase.instance.database;
    final res = await db.query(
      tableParticipants,
    );

    return res.map((e) => fromJson(e)).toSet();
  }

  Map<String, Object?> toJson() => {
        ParticipantFields.id: id,
        ParticipantFields.pseudo: pseudo,
        ParticipantFields.lastname: lastname,
        ParticipantFields.firstname: firstname,
      };

  static Participant fromJson(Map<String, Object?> json) {
    return Participant(
      id: json[ParticipantFields.id] as int?,
      pseudo: json[ParticipantFields.pseudo] as String,
      lastname: json[ParticipantFields.lastname] as String?,
      firstname: json[ParticipantFields.firstname] as String?,
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

class _ParticipantDB {
  _ParticipantDB(this.participant);

  Participant participant;

  Future save() async {
    if (participant.id != null) {
      final results = await AppData.db.query(
        tableParticipants,
        where: 'id = ?',
        whereArgs: [participant.id],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableParticipants,
          participant.toJson(),
          where: 'id = ?',
          whereArgs: [participant.id],
        );
        return;
      }
    }

    participant.id =
        await AppData.db.insert(tableParticipants, participant.toJson());
  }
}
