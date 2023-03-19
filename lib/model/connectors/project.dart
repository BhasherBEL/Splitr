import '../project.dart';

abstract class ProjectConnector {
  ProjectConnector(this.project);

  final Project project;

  Future save();

  Future delete();

  Future loadParticipants();

  Future loadEntries();
}
