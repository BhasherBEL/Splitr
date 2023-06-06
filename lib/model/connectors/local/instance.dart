import '../../app_data.dart';
import '../../instance.dart';

const String tableInstances = 'instances';

class LocalInstance {
  LocalInstance(this.instance);

  final Instance instance;

  Future save() async {
    if (instance.localId != null) {
      final results = await AppData.db.query(
        tableInstances,
        where: '${InstanceFields.localId} = ?',
        whereArgs: [instance.localId],
      );
      if (results.isNotEmpty) {
        await AppData.db.update(
          tableInstances,
          instance.toJson(),
          where: '${InstanceFields.localId} = ?',
          whereArgs: [instance.localId],
        );
        return;
      }
    }

    instance.localId =
        await AppData.db.insert(tableInstances, instance.toJson());
  }

  Future delete() async {
    return await AppData.db.delete(
          tableInstances,
          where: '${InstanceFields.localId} = ?',
          whereArgs: [instance.localId],
        ) >
        0;
  }
}
