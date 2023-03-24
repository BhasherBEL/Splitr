import '../../app_data.dart';
import '../../project.dart';

const String tableDeleted = 'deleted';

class DeletedFields {
  static const values = [
    collection,
    uid,
    updated,
  ];

  static const String collection = 'collection';
  static const String uid = 'uid';
  static const String projectId = 'project_id';
  static const String updated = 'updated';
}

class LocalDeleted {
  static Future<bool> add(
    String collection,
    String uid,
    Project project,
    DateTime dateTime,
  ) async {
    await AppData.db.insert(
      tableDeleted,
      {
        DeletedFields.collection: collection,
        DeletedFields.uid: uid,
        DeletedFields.projectId: project.remoteId,
        DeletedFields.updated: dateTime.millisecondsSinceEpoch,
      },
    );
    project.notSyncCount++;
    return true;
  }

  static Future<Map<String, List<String>>> getSince(
    Project project,
    DateTime dateTime,
  ) async {
    if (project.remoteId == null) return {};
    final res = await AppData.db.query(
      tableDeleted,
      columns: DeletedFields.values,
      where: '${DeletedFields.projectId} = ? AND ${DeletedFields.updated} > ?',
      whereArgs: [project.remoteId, dateTime.millisecondsSinceEpoch],
    );

    final Map<String, List<String>> deleteds = {
      "projects": [],
      "participants": [],
      "items": [],
      "itemParts": [],
    };

    for (Map<String, Object?> elem in res) {
      String a = elem[DeletedFields.collection] as String;
      deleteds[a]!.add(elem[DeletedFields.uid] as String);
    }

    return deleteds;
  }
}
