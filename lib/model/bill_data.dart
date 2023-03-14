import 'package:shared/model/participant.dart';

class BillData {
  String title = "";
  DateTime date = DateTime.now();
  Participant emitter = Participant.me!;
  double amount = 0;
  Map<Participant, int> shares = {};

  int get totalShares {
    return shares.values.reduce((value, element) => value + element);
  }

  @override
  String toString() {
    return """title: $title
date: ${date.day}/${date.month}/${date.year}
emitter: ${emitter.pseudo}
amount: $amount
shares: ${shares.entries.map((e) => "${e.key.pseudo}:${e.value}").join(",")}""";
  }
}
