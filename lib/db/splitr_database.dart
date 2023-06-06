import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/connectors/local/deleted.dart';
import '../model/connectors/local/instance.dart';
import '../model/connectors/local/item.dart';
import '../model/connectors/local/item_part.dart';
import '../model/connectors/local/participant.dart';
import '../model/connectors/local/project.dart';
import '../model/instance.dart';
import '../model/item.dart';
import '../model/item_part.dart';
import '../model/participant.dart';
import '../model/project.dart';

class SplitrDatabase {
  static final SplitrDatabase instance = SplitrDatabase._init();

  static Database? _database;

  SplitrDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('splitr.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _updateDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE $tableProjects (
  ${ProjectFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ProjectFields.remoteId} TEXT,
  ${ProjectFields.name} TEXT NOT NULL,
  ${ProjectFields.code} TEXT NOT NULL,
  ${ProjectFields.currentParticipant} INTEGER,
  ${ProjectFields.instance} INTEGER NOT NULL,
  ${ProjectFields.lastSync} INTEGER,
  ${ProjectFields.lastUpdate} INTEGER
)
''');

    await db.execute('''
CREATE TABLE $tableParticipants (
  ${ParticipantFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ParticipantFields.remoteId} TEXT,
  ${ParticipantFields.projectId} INTEGER,
  ${ParticipantFields.pseudo} TEXT NOT NULL,
  ${ParticipantFields.lastname} TEXT,
  ${ParticipantFields.firstname} TEXT,
  ${ParticipantFields.lastUpdate} INTEGER
)
''');

    await db.execute('''
CREATE TABLE $tableItems (
  ${ItemFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ItemFields.remoteId} TEXT,
  ${ItemFields.project} INTEGER NOT NULL,
  ${ItemFields.title} TEXT NOT NULL,
  ${ItemFields.emitter} INTEGER NOT NULL,
  ${ItemFields.amount} REAL NOT NULL,
  ${ItemFields.date} INTEGER NOT NULL,
  ${ItemFields.lastUpdate} INTEGER
)
''');

    await db.execute('''
CREATE TABLE $tableItemParts (
  ${ItemPartFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${ItemPartFields.remoteId} TEXT,
  ${ItemPartFields.itemId} INTEGER NOT NULL,
  ${ItemPartFields.participantId} INTEGER NOT NULL,
  ${ItemPartFields.rate} REAL,
  ${ItemPartFields.amount} REAL,
  ${ItemPartFields.lastUpdate} INTEGER
)
''');

    await db.execute('''
CREATE TABLE $tableDeleted (
  ${DeletedFields.collection} TEXT NOT NULL,
  ${DeletedFields.projectId} INTEGER NOT NULL,
  ${DeletedFields.uid} TEXT NOT NULL,
  ${DeletedFields.updated} INTEGER
)
''');

    await db.execute('''
CREATE TABLE $tableInstances (
  ${InstanceFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${InstanceFields.type} TEXT NOT NULL,
  ${InstanceFields.name} TEXT NOT NULL,
  ${InstanceFields.data} TEXT
)
''');

    await db.insert(tableInstances, {
      InstanceFields.type: "local",
      InstanceFields.name: "local",
      InstanceFields.data: json.encode({}),
    });
  }

  Future close() async {
    if (_database != null) {
      final db = await instance.database;
      db.close();
    }
  }

  Future _updateDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('''
CREATE TABLE $tableInstances (
  ${InstanceFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${InstanceFields.name} TEXT NUL NULL,
  ${InstanceFields.data} JSON
)
''');

      await db.insert(tableInstances, {
        InstanceFields.type: "local",
        InstanceFields.name: "local",
        InstanceFields.data: json.encode({}),
      });
    }
  }
}
