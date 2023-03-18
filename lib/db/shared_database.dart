import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/connectors/local/item.dart';
import '../model/connectors/local/item_part.dart';
import '../model/connectors/local/participant.dart';
import '../model/connectors/local/project.dart';
import '../model/item.dart';
import '../model/item_part.dart';
import '../model/participant.dart';
import '../model/project.dart';
import '../model/project_participant.dart';

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

    return await openDatabase(path, version: 2, onCreate: _createDB);
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
CREATE TABLE $tableProjectParticipants (
  ${ProjectParticipantFields.projectId} INTEGER NOT NULL,
  ${ProjectParticipantFields.participantId} INTEGER NOT NULL
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
  ${ItemPartFields.itemId} INTEGER NOT NULL,
  ${ItemPartFields.participantId} INTEGER NOT NULL,
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
