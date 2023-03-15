import 'package:shared/model/app_data.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';

import 'item.dart';

class BillData {
  String title = "";
  DateTime date = DateTime.now();
  Participant emitter = AppData.me;
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

  Item toItemOf(Project project) {
    Item item = Item(
      amount: amount,
      date: date,
      emitter: emitter,
      project: project,
      title: title,
    );

    project.addItem(item);

    return item;
  }
}
