import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/external_connector.dart';
import 'package:shared/model/connectors/pocketbase/deleted.dart';

import '../../project.dart';

class PocketBaseProjectFields {
  static const String id = "id";
  static const String name = "name";
}

class PocketBaseProject extends ExternalConnector<Project> {
  PocketBaseProject(this.project, this.pb) {
    collection = pb.collection("projects");
  }

  final PocketBase pb;
  final Project project;
  late final RecordService collection;

  @override
  Future<bool> delete() async {
    if (project.remoteId != null) {
      await collection.delete(project.remoteId!);
      await PocketBaseDeleted.delete(
        pb,
        project,
        "projects",
        project.remoteId!,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> sync() async {
    if (project.remoteId == null ||
        project.lastUpdate.difference(project.lastSync).inMilliseconds > 0) {
      await pushIfChange();
    } else {
      await checkUpdate();
    }
    return true;
  }

  @override
  Future<bool> pushIfChange() async {
    if (project.remoteId == null) {
      await create();
    } else {
      await update();
    }
    return true;
  }

  @override
  Future<bool> create() async {
    print('CREATE');
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseProjectFields.name: project.name,
      },
    );
    project.remoteId = recordModel.id;
    await project.conn.save();
    print(project.remoteId);
    return true;
  }

  @override
  Future<bool> update() async {
    await collection.update(project.remoteId!, body: {
      PocketBaseProjectFields.name: project.name,
    });
    return true;
  }

  @override
  Future<bool> checkUpdate() async {
    RecordModel record = await collection.getOne(project.remoteId!);
    DateTime updated = DateTime.parse(record.updated);
    if (updated.millisecondsSinceEpoch >
        project.lastUpdate.millisecondsSinceEpoch) {
      project.name = record.getStringValue(PocketBaseProjectFields.name);
      project.lastUpdate = updated;
    }
    await project.conn.save();
    return true;
  }
}
