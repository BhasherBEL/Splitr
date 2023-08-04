import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:splitr/data/local/group.dart';
import 'package:splitr/data/local/group_membership.dart';
import 'package:sqflite/sqflite.dart';

import '../data/local/instance.dart';
import '../data/local/item.dart';
import '../data/local/item_part.dart';
import '../data/local/participant.dart';
import '../data/local/project.dart';

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
      version: 5,
      onCreate: _createDB,
      onUpgrade: _updateDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE $tableProjects (
  ${LocalProjectFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalProjectFields.remoteId} TEXT,
  ${LocalProjectFields.name} TEXT NOT NULL,
  ${LocalProjectFields.code} TEXT NOT NULL,
  ${LocalProjectFields.currentParticipant} INTEGER,
  ${LocalProjectFields.instance} INTEGER NOT NULL,
  ${LocalProjectFields.lastSync} INTEGER,
  ${LocalProjectFields.lastUpdate} INTEGER,
  ${LocalProjectFields.deleted} INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableParticipants (
  ${LocalParticipantFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalParticipantFields.remoteId} TEXT,
  ${LocalParticipantFields.projectId} INTEGER,
  ${LocalParticipantFields.pseudo} TEXT NOT NULL,
  ${LocalParticipantFields.lastname} TEXT,
  ${LocalParticipantFields.firstname} TEXT,
  ${LocalParticipantFields.lastUpdate} INTEGER,
  ${LocalParticipantFields.deleted} INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableItems (
  ${LocalItemFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalItemFields.remoteId} TEXT,
  ${LocalItemFields.projectId} INTEGER NOT NULL,
  ${LocalItemFields.title} TEXT NOT NULL,
  ${LocalItemFields.emitter} INTEGER NOT NULL,
  ${LocalItemFields.amount} REAL NOT NULL,
  ${LocalItemFields.date} INTEGER NOT NULL,
  ${LocalItemFields.lastUpdate} INTEGER,
  ${LocalItemFields.deleted} INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableItemParts (
  ${LocalItemPartFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalItemPartFields.remoteId} TEXT,
  ${LocalItemPartFields.itemId} INTEGER NOT NULL,
  ${LocalItemPartFields.participantId} INTEGER NOT NULL,
  ${LocalItemPartFields.rate} REAL,
  ${LocalItemPartFields.amount} REAL,
  ${LocalItemPartFields.lastUpdate} INTEGER,
  ${LocalItemPartFields.deleted} INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableInstances (
  ${LocalInstanceFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalInstanceFields.type} TEXT NOT NULL,
  ${LocalInstanceFields.name} TEXT NOT NULL,
  ${LocalInstanceFields.data} TEXT
)
''');

    await db.insert(tableInstances, {
      LocalInstanceFields.type: 'local',
      LocalInstanceFields.name: 'local',
      LocalInstanceFields.data: json.encode({}),
    });

    await db.execute('''
CREATE TABLE $tableGroup (
  ${LocalGroupFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalGroupFields.remoteId} TEXT,
  ${LocalGroupFields.projectId} INTEGER NOT NULL,
  ${LocalGroupFields.name} TEXT NOT NULL,
  ${LocalGroupFields.lastUpdate} INTEGER,
  ${LocalGroupFields.deleted} INTEGER NOT NULL
)
''');

    await db.execute('''
CREATE TABLE $tableGroupMembership (
  ${LocalGroupMembershipFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalGroupMembershipFields.remoteId} TEXT,
  ${LocalGroupMembershipFields.groupId} INTEGER NOT NULL,
  ${LocalGroupMembershipFields.participantId} INTEGER NOT NULL,
  ${LocalGroupMembershipFields.lastUpdate} INTEGER,
  ${LocalGroupMembershipFields.deleted} INTEGER NOT NULL
)
''');
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
  ${LocalInstanceFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalInstanceFields.name} TEXT NUL NULL,
  ${LocalInstanceFields.data} JSON
)
''');

      await db.insert(tableInstances, {
        LocalInstanceFields.type: 'local',
        LocalInstanceFields.name: 'local',
        LocalInstanceFields.data: json.encode({}),
      });
    }

    if (oldVersion < 5) {
      await db.execute('''
CREATE TABLE $tableGroup (
  ${LocalGroupFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalGroupFields.remoteId} TEXT,
  ${LocalGroupFields.projectId} INTEGER NOT NULL,
  ${LocalGroupFields.name} TEXT NOT NULL,
  ${LocalGroupFields.lastUpdate} INTEGER,
  ${LocalGroupFields.deleted} INTEGER NOT NULL
)
''');

      await db.execute('''
CREATE TABLE $tableGroupMembership (
  ${LocalGroupMembershipFields.localId} INTEGER PRIMARY KEY AUTOINCREMENT,
  ${LocalGroupMembershipFields.remoteId} TEXT,
  ${LocalGroupMembershipFields.groupId} INTEGER NOT NULL,
  ${LocalGroupMembershipFields.participantId} INTEGER NOT NULL,
  ${LocalGroupMembershipFields.lastUpdate} INTEGER,
  ${LocalGroupMembershipFields.deleted} INTEGER NOT NULL
)
''');
    }
  }
}
