import 'package:pocketbase/pocketbase.dart';

import '../../project.dart';

class PocketBaseDeletedFields {
  static const String id = "id";
  static const String collection = "collection";
  static const String projectId = "project_id";
  static const String uid = "uid";
}

class PocketBaseDeleted {
  static Future<Map<String, List<String>>> checkNewDeleted(
    PocketBase pb,
    Project project,
  ) async {
    List<RecordModel> records = await pb.collection("deleted").getFullList(
          filter:
              'updated > "${project.lastSync.toUtc()}" && ${PocketBaseDeletedFields.projectId} = "${project.remoteId}"',
        );

    final Map<String, List<String>> deleteds = {
      "projects": [],
      "participants": [],
      "items": [],
      "itemParts": [],
    };

    for (RecordModel model in records) {
      deleteds[model.getStringValue("collection")]!
          .add(model.getStringValue("uid"));
    }

    return deleteds;
  }

  static Future<bool> delete(
    PocketBase pb,
    Project project,
    String collection,
    String uid,
  ) async {
    await pb.collection("deleted").create(body: {
      PocketBaseDeletedFields.collection: collection,
      PocketBaseDeletedFields.projectId: project.remoteId,
      PocketBaseDeletedFields.uid: uid,
    });
    return true;
  }
}
