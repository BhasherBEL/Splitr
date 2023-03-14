import 'package:shared/model/item.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';

class ProjectData {
  final Project project;
  bool isLoaded = false;
  List<Item> items = [];
  List<Participant> participants = [];

  ProjectData(this.project);

  Future load() async {
    items = await project.getItems();
    // TODO project specific participants
    participants = await Participant.getAll();
  }
}
