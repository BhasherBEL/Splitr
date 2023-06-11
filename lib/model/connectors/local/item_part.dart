import 'package:splitr/model/connectors/local/generic.dart';
import 'package:sqflite/sqflite.dart';

import '../../app_data.dart';
import '../../item_part.dart';

const String tableItemParts = 'itemParts';

class LocalItemPart extends LocalGeneric {
  LocalItemPart(this.itemPart);

  final ItemPart itemPart;

  @override
  Future<bool> save() async {
    itemPart.localId = await AppData.db.insert(
      tableItemParts,
      itemPart.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    itemPart.item.project.notSyncCount++;
    return true;
  }
}
