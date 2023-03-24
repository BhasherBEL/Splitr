import 'package:pocketbase/pocketbase.dart';
import 'package:shared/model/connectors/external_connector.dart';
import 'package:shared/model/connectors/pocketbase/deleted.dart';
import 'package:shared/screens/new_project_screen.dart';

import '../../project.dart';

class PocketBaseProjectFields {
  static const String name = "name";
  static const String code = "code";
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
    await project.provider.checkConnection();
    if (project.code == null && project.remoteId == null) {
      try {
        RecordModel record =
            await collection.getFirstListItem("code = \"${project.name}\"");
        project.name = record.getStringValue(PocketBaseProjectFields.name);
        project.code = record.getStringValue(PocketBaseProjectFields.code);
        project.lastUpdate = DateTime.parse(record.updated);
        await project.conn.save();
        return true;
      } on ClientException {
        project.code ??= getRandom(5);
      }
    }

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
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseProjectFields.name: project.name,
        PocketBaseProjectFields.code: project.code,
      },
    );
    project.remoteId = recordModel.id;
    await project.conn.save();
    return true;
  }

  @override
  Future<bool> update() async {
    await collection.update(project.remoteId!, body: {
      PocketBaseProjectFields.name: project.name,
      PocketBaseProjectFields.code: project.code,
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
      project.code = record.getStringValue(PocketBaseProjectFields.code);
      project.lastUpdate = updated;
    }
    await project.conn.save();
    return true;
  }
}
