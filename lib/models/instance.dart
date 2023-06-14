import 'dart:convert';

import 'app_data.dart';
import '../data/local/instance.dart';

class InstanceFields {
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

class Instance {
  Instance({
    this.localId,
    required this.type,
    required this.name,
    required this.data,
  }) {
    conn = LocalInstance(this);
  }

  int? localId;
  String type;
  String name;
  Map<String, dynamic> data;
  late LocalInstance conn;

  Map<String, Object?> toJson() {
    return {
      InstanceFields.localId: localId,
      InstanceFields.type: type,
      InstanceFields.name: name,
      InstanceFields.data: json.encode(data),
    };
  }

  static Instance fromJson(Map<String, Object?> jsonMap) {
    return Instance(
      localId: jsonMap[InstanceFields.localId] as int?,
      type: jsonMap[InstanceFields.type] as String,
      name: jsonMap[InstanceFields.name] as String,
      data: json.decode(jsonMap[InstanceFields.data] as String)
          as Map<String, dynamic>,
    );
  }

  static Instance? fromId(int localId) {
    return AppData.instances
        .firstWhere((element) => element.localId == localId);
  }

  static Future<Set<Instance>> getAllInstances() async {
    final res = await AppData.db.query(
      tableInstances,
      columns: InstanceFields.values,
    );
    return res.map((e) => fromJson(e)).toSet();
  }

  static Instance? fromName(String s) {
    return AppData.instances.isEmpty
        ? null
        : AppData.instances.firstWhere((element) => element.name == s);
  }
}
