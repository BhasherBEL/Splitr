import 'package:splitr/data/local/generic.dart';

abstract class Data {
  Data({
    required this.localId,
    required this.remoteId,
    DateTime? lastUpdate,
    bool deleted = false,
  }) {
    _deleted = deleted;
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }

  int? localId;
  String? remoteId;
  late LocalGeneric conn;
  late DateTime lastUpdate;
  late bool _deleted;

  bool get deleted => _deleted;

  set deleted(bool deleted) {
    _deleted = deleted;
    lastUpdate = DateTime.now();
  }
}
