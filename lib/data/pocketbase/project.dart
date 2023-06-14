import 'package:pocketbase/pocketbase.dart';
import 'package:splitr/utils/ext/datetime.dart';
import 'package:splitr/utils/ext/record_service.dart';

import '../../models/project.dart';

class PocketBaseProjectFields {
  static const String name = 'name';
  static const String code = 'code';
  static const String deleted = 'deleted';
}

class PocketBaseProject {
  static Future<bool> sync(PocketBase pb, Project project) async {
    RecordService collection = pb.collection('projects');

    if (project.remoteId != null) {
      RecordModel record = await collection.getOne(project.remoteId!);

      DateTime lastUpdate = DateTime.parse(record.updated);

      if (lastUpdate > project.lastSync && lastUpdate > project.lastUpdate) {
        project.name = record.getStringValue(PocketBaseProjectFields.name);
        project.code = record.getStringValue(PocketBaseProjectFields.code);
        project.lastUpdate = lastUpdate;
        project.deleted = record.getBoolValue(PocketBaseProjectFields.deleted);
      } else if (lastUpdate < project.lastUpdate) {
        await collection.updateOrCreate(
          id: project.remoteId,
          body: toJson(project),
        );
        project.lastUpdate = DateTime.now();
      }
    } else {
      RecordModel rm = await collection.updateOrCreate(body: toJson(project));
      project.remoteId = rm.id;
      project.lastUpdate = DateTime.now();
    }

    return true;
  }

  static Map<String, dynamic> toJson(Project project) {
    return {
      PocketBaseProjectFields.name: project.name,
      PocketBaseProjectFields.code: project.code,
      PocketBaseProjectFields.deleted: project.deleted,
    };
  }

  static Future<bool> join(PocketBase pb, Project project) async {
    RecordService collection = pb.collection('projects');
    RecordModel record =
        await collection.getFirstListItem('code = "${project.name}"');
    project.code = project.name;
    project.name = record.getStringValue(PocketBaseProjectFields.name);
    project.remoteId = record.id;
    project.lastUpdate = DateTime.parse(record.updated);
    project.deleted = false;
    await project.conn.save();
    return true;
  }
}
