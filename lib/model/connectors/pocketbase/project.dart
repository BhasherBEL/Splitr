import 'package:pocketbase/pocketbase.dart';

import '../../project.dart';

class PocketBaseProjectFields {
  static const String id = "id";
  static const String name = "name";
}

class PocketBaseProject {
  PocketBaseProject(this.project, this.pb) {
    collection = pb.collection("projects");
  }

  final PocketBase pb;
  final Project project;
  late final RecordService collection;

  Future delete() async {
    if (project.remoteId != null) await collection.delete(project.remoteId!);
  }

  Future<bool> sync() async {
    if (project.remoteId == null ||
        project.lastUpdate.difference(project.lastSync).inMilliseconds > 0) {
      await push();
    } else {
      await pullIf();
    }
    return true;
  }

  Future push() async {
    if (project.remoteId == null) {
      await create();
    } else {
      await update();
    }
  }

  Future create() async {
    RecordModel recordModel = await collection.create(
      body: <String, dynamic>{
        PocketBaseProjectFields.name: project.name,
      },
    );
    project.remoteId = recordModel.id;
    await project.conn.save();
  }

  Future update() async {
    await collection.update(project.remoteId!, body: {
      PocketBaseProjectFields.name: project.name,
    });
  }

  Future pullIf() async {
    RecordModel record = await collection.getOne(project.remoteId!);
    DateTime updated = DateTime.parse(record.updated);
    if (updated.millisecondsSinceEpoch >
        project.lastUpdate.millisecondsSinceEpoch) {
      project.setName(record.getStringValue(PocketBaseProjectFields.name));
      project.lastUpdate = updated;
    }
    await project.conn.save();
  }

  @override
  Future saveParticipants() {
    throw UnimplementedError();
  }
}
