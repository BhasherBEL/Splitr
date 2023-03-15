import 'package:shared/model/app_data.dart';
import 'package:shared/model/itemPart.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';

import 'item.dart';

class BillData {
  BillData({this.item}) {
    title = item?.title ?? "";
    date = item?.date ?? DateTime.now();
    emitter = item?.emitter ?? AppData.me;
    amount = item?.amount ?? 0;
    if (item != null) {
      for (ItemPart ip in item!.itemParts) {
        shares[ip.participant] = ip.rate.toInt();
      }
    }
    print(shares);
  }

  Item? item;

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
    if (item == null) {
      item = Item(
        amount: amount,
        date: date,
        emitter: emitter,
        project: project,
        title: title,
      );
      project.addItem(item!);
    } else {
      item!.amount = amount;
      item!.date = date;
      item!.emitter = emitter;
      item!.title = title;
      for (var element in item!.itemParts) {
        element.db.delete();
      }
      item!.itemParts = [];
    }
    shares.forEach((p, s) {
      if (s > 0) {
        item!.itemParts
            .add(ItemPart(item: item!, participant: p, rate: s.toDouble()));
      }
    });

    return item!;
  }
}
