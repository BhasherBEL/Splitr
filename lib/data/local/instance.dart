import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../models/app_data.dart';
import '../../models/instance.dart';

const String tableInstances = 'instances';

class LocalInstanceFields {
  static const values = [
    localId,
    type,
    name,
    data,
  ];

  static const String localId = 'local_id';
  static const String type = 'type';
  static const String name = 'name';
  static const String data = 'data';
}

class LocalInstance {
  LocalInstance(this.instance);

  final Instance instance;

  Future save() async {
    instance.localId = await AppData.db.insert(
      tableInstances,
      toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future delete() async {
    return await AppData.db.delete(
          tableInstances,
          where: '${LocalInstanceFields.localId} = ?',
          whereArgs: [instance.localId],
        ) >
        0;
  }

  Map<String, Object?> toJson() {
    return {
      LocalInstanceFields.localId: instance.localId,
      LocalInstanceFields.type: instance.type,
      LocalInstanceFields.name: instance.name,
      LocalInstanceFields.data: json.encode(instance.data),
    };
  }

  static Instance fromJson(Map<String, Object?> jsonMap) {
    return Instance(
      localId: jsonMap[LocalInstanceFields.localId] as int?,
      type: jsonMap[LocalInstanceFields.type] as String,
      name: jsonMap[LocalInstanceFields.name] as String,
      data: json.decode(jsonMap[LocalInstanceFields.data] as String)
          as Map<String, dynamic>,
    );
  }

  static Future<Set<Instance>> getAllInstances() async {
    final res = await AppData.db.query(
      tableInstances,
      columns: LocalInstanceFields.values,
    );
    return res.map((e) => fromJson(e)).toSet();
  }
}
