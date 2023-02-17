import 'package:path/path.dart';
import 'package:shared/model/item.dart';
import 'package:shared/model/itemPart.dart';
import 'package:shared/model/participant.dart';
import 'package:shared/model/project.dart';
import 'package:sqflite/sqflite.dart';

class SharedDatabase {
  static final SharedDatabase instance = SharedDatabase._init();

  static Database? _database;

  SharedDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shared.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE $tableProjects (
  ${ProjectFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ProjectFields.name} TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableParticipants (
  ${ParticipantFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ParticipantFields.pseudo} TEXT NOT NULL,
  ${ParticipantFields.lastname} TEXT,
  ${ParticipantFields.firstname} TEXT
)
''');

    await db.execute('''
CREATE TABLE $tableItems (
  ${ItemFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ItemFields.project} INTEGER NOT NULL,
  ${ItemFields.title} TEXT NOT NULL,
  ${ItemFields.emitter} INTEGER NOT NULL,
  ${ItemFields.amount} REAL NOT NULL,
  ${ItemFields.date} INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableItemParts (
  ${ItemPartFields.id} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ItemPartFields.item} INTEGER NOT NULL,
  ${ItemPartFields.participant} INTEGER NOT NULL,
  ${ItemPartFields.rate} REAL,
  ${ItemPartFields.amount} REAL
)
''');
  }

  Future close() async {
    if (_database != null) {
      final db = await instance.database;
      db.close();
    }
  }
}
