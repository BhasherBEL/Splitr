import '../project.dart';

abstract class ProjectConnector {
  ProjectConnector(this.project);

  final Project project;

  Future save();

  Future delete();

  Future saveParticipants();

  Future loadParticipants();

  Future loadEntries();
}
