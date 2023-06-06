import 'package:shared/model/project.dart';

import '../../instance.dart';
import '../provider.dart';

class LocalProvider extends Provider {
  LocalProvider(Project project, Instance instance) : super(project, instance);

  static int pid = 0;

  @override
  Future<bool> checkConnection() async {
    return true;
  }

  @override
  Future<bool> sync() async {
    return true;
  }

  @override
  Future<bool> connect() async {
    return true;
  }

  @override
  bool hasSync() {
    return false;
  }

  @override
  Future<bool> joinWithTitle() async {
    return true;
  }

  @override
  String getInstance() {
    return "local";
  }

  static Future<bool> checkCredentials(Instance instance) async {
    return true;
  }
}
