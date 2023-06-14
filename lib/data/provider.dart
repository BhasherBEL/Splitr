import '../models/instance.dart';
import '../models/project.dart';
import 'local/provider.dart';
import 'pocketbase/provider.dart';

abstract class Provider {
  Provider(this.project, this.instance);

  final Project project;
  final Instance instance;

  Future<bool> checkConnection();

  Future<bool> sync();

  Future<bool> connect();

  bool hasSync();

  Future<bool> joinWithTitle();

  static String getNameFromId(int id) {
    switch (id) {
      case 0:
        return 'local';
      case 1:
        return 'pocketbase';
      default:
        throw UnimplementedError();
    }
  }

  static Provider initFromInstance(Project project, Instance instance) {
    switch (instance.type) {
      case 'local':
        return LocalProvider(project, instance);
      case 'pocketbase':
        return PocketBaseProvider(project, instance);
      default:
        throw UnimplementedError();
    }
  }

  static Future<bool> checkCredentials(Instance instance) async {
    switch (instance.type) {
      case 'local':
        return LocalProvider.checkCredentials(instance);
      case 'pocketbase':
        return PocketBaseProvider.checkCredentials(instance);
      default:
        throw UnimplementedError();
    }
  }
}
