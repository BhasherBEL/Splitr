import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/instance.dart';

const String tableInstances = 'instances';

class LocalInstance {
  LocalInstance(this.instance);

  final Instance instance;

  Future save() async {
    instance.localId = await AppData.db.insert(
      tableInstances,
      instance.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
