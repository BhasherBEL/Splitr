import '../../item.dart';
import '../../item_part.dart';
import '../../participant.dart';
import '../../project.dart';
import '../provider.dart';
import 'item.dart';
import 'item_part.dart';
import 'participant.dart';
import 'project.dart';

class LocalProvider extends Provider {
  LocalProvider(project) : super(project, 0, "local", "");

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
}
