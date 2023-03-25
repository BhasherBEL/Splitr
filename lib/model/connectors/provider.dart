import 'package:shared/model/connectors/local/provider.dart';
import 'package:shared/model/project.dart';

import 'pocketbase/provider.dart';

abstract class Provider {
  Provider(this.project, this.id, this.name, this.data);

  final Project project;
  final int id;
  final String name;
  final String data;

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

  static Provider initFromId(int id, Project project, String data) {
    switch (id) {
      case 0:
        return LocalProvider(project);
      case 1:
        return PocketBaseProvider(project, data);
      default:
        throw UnimplementedError();
    }
  }
}
