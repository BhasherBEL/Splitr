import 'package:shared/model/connectors/participant.dart';

import '../db/shared_database.dart';
import 'app_data.dart';
import 'connectors/local/item_part.dart';
import 'connectors/local/participant.dart';

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
    db = LocalParticipant(this);
    AppData.participants.add(this);
  }

  int? id;
  String pseudo;
  String? lastname;
  String? firstname;
  late ParticipantConnector db;

  static Participant? fromId(int id) {
    return AppData.participants.isEmpty
        ? null
        : AppData.participants.firstWhere((element) => element.id == id);
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
