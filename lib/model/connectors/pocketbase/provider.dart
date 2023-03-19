import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/pocketbase/participant.dart';
import 'package:shared/model/connectors/pocketbase/project.dart';
import 'package:shared/model/connectors/provider.dart';
import 'package:shared/model/participant.dart';

class PocketBaseProvider extends Provider {
  PocketBaseProvider(project, data)
      : super(
          project,
          1,
          'pocketbase',
          data,
        ) {
    dataList = super.data.split(';');
    pb = PocketBase(dataList.elementAt(0));
  }

  late List<String> dataList;
  late PocketBase pb;

  @override
  Future<bool> checkConnection() async {
    HealthCheck hc = await pb.health.check();
    return hc.code == 200;
  }

  @override
  Future<bool> sync() async {
    PocketBaseProject(project, pb).sync();
    print(project.lastSync);
    project.lastSync = DateTime(1970);
    for (Participant participant in project.participants) {
      print('LOCAL: ${participant.pseudo}');
      PocketBaseParticipant(project.lastSync, participant, pb).sync();
    }
    for (Participant participant
        in await PocketBaseParticipant.pullNewFrom(pb, project)) {
      project.addParticipant(participant);
      participant.conn.save();
      print('DIST: ${participant.pseudo}');
    }

    project.lastSync = DateTime.now();
    await project.conn.save();
    return true;
  }

  @override
  Future<bool> connect() async {
    await pb.collection('users').authWithPassword(
          dataList.elementAt(1),
          dataList.elementAt(2),
        );

    final bool isValid = pb.authStore.isValid;
    return isValid;
  }
}
