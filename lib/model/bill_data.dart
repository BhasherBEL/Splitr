import 'package:shared/model/item_part.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';

import 'item.dart';

class BillData {
  BillData({
    this.item,
    required this.project,
  }) {
    title = item?.title ?? "";
    date = item?.date ?? DateTime.now();
    emitter = item?.emitter ??
        project.currentParticipant ??
        project.participants.first;
    amount = item?.amount ?? 0;
    if (item != null) {
      for (ItemPart ip in item!.itemParts) {
        shares[ip.participant] = BillPart(share: ip.rate, fixed: ip.amount);
      }
    }
  }

  Item? item;
  Project project;

  String title = "";
  DateTime date = DateTime.now();
  late Participant emitter;
  double amount = 0;
  Map<Participant, BillPart> shares = {};

  @override
  String toString() {
    return """title: $title
date: ${date.day}/${date.month}/${date.year}
emitter: ${emitter.pseudo}
amount: $amount
shares: ${shares.entries.map((e) => "${e.key.pseudo}:${e.value}").join(",")}""";
  }

  double get totalShares {
    return (shares.values
                .where((element) => element.share != null)
                .map((e) => e.share)
                .toList() +
            [0])
        .reduce((a, b) => a! + b!)!;
  }

  double get totalFixed {
    return (shares.values
                .where((element) => element.fixed != null)
                .map((e) => e.fixed)
                .toList() +
            [0])
        .reduce((a, b) => a! + b!)!;
  }

  Future<Item> toItemOf(Project project) async {
    if (item == null) {
      item = Item(
        amount: amount,
        date: date,
        emitter: emitter,
        project: project,
        title: title.isEmpty ? 'No title' : title,
      );
      project.addItem(item!);
    } else {
      item!.amount = amount;
      item!.date = date;
      item!.emitter = emitter;
      item!.title = title.isEmpty ? 'No title' : title;
      for (var element in item!.itemParts) {
        await element.conn.delete();
      }
      item!.itemParts = [];
    }
    shares.forEach((p, s) {
      if (s.fixed != null || s.share != null) {
        item!.itemParts.add(ItemPart(
            item: item!, participant: p, rate: s.share, amount: s.fixed));
      }
    });

    return item!;
  }
}

class BillPart {
  BillPart({this.share, this.fixed});

  double? share;
  double? fixed;
}
