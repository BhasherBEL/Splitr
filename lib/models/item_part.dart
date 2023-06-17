import 'data.dart';
import 'participant.dart';
import 'item.dart';

import '../data/local/item_part.dart';

class ItemPart extends Data {
  ItemPart({
    super.localId,
    super.remoteId,
    required this.item,
    required this.participant,
    double? rate,
    double? amount,
    super.lastUpdate,
    super.deleted,
  }) {
    _rate = rate;
    _amount = amount;
    super.conn = LocalItemPart(this);
  }

  Item item;
  Participant participant;
  double? _rate;
  double? _amount;

  double? get rate => _rate;
  double? get amount => _amount;

  set rate(double? rate) {
    _rate = rate;
    lastUpdate = DateTime.now();
  }

  set amount(double? amount) {
    _amount = amount;
    lastUpdate = DateTime.now();
  }
}
