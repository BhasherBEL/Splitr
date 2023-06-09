import 'item_part.dart';
import 'participant.dart';
import 'project.dart';

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

  bool? allParticipants() {
    int n =
        shares.values.where((e) => e.fixed != null || e.share != null).length;

    if (n == 0) {
      return false;
    } else if (n == shares.length) {
      return true;
    } else {
      return null;
    }
  }

  double getTotalShares() {
    return shares.values.map((e) => e.share ?? 0).fold(0, (a, b) => a + b);
  }

  double getTotalFixed() {
    return shares.values.map((e) => e.fixed ?? 0).fold(0, (a, b) => a + b);
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
    await item!.conn.save();
    for (var a in shares.entries) {
      Participant p = a.key;
      BillPart s = a.value;
      if (s.fixed != null || s.share != null) {
        ItemPart ip = ItemPart(
            item: item!, participant: p, rate: s.share, amount: s.fixed);
        item!.itemParts.add(ip);
        await ip.conn.save();
      }
    }

    return item!;
  }
}

class BillPart {
  BillPart({this.share, this.fixed});

  double? share;
  double? fixed;
}
