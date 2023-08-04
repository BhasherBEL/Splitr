import 'app_data.dart';
import '../data/local/instance.dart';

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

  static Instance? fromId(int localId) {
    try {
      return AppData.instances
          .firstWhere((element) => element.localId == localId);
    } catch (e) {
      return null;
    }
  }

  static Instance? fromName(String s) {
    return AppData.instances.isEmpty
        ? null
        : AppData.instances.firstWhere((element) => element.name == s);
  }
}
