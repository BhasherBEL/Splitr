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
    for (Participant participant in project.participants) {
      PocketBaseParticipant(project.lastSync, participant, pb).sync();
    }
    project.lastSync = DateTime.now();
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
