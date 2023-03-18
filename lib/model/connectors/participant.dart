import '../participant.dart';

abstract class ParticipantConnector {
  ParticipantConnector(this.participant);

  final Participant participant;

  static Future<Set<Participant>> getAll() async {
    throw UnimplementedError();
  }

  Future save();

  Future delete();
}
