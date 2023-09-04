import 'dart:async';
import 'package:flutter_desktop_sqlite/model/note.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    // open a connection
    if (_database != null) {
      //if already created
      return _database!;
    }
    // else
    _database = await _initDB('notes.db');

    return _database!;
  }

  Future<Database> _initDB(String filepath) async {
    final dbPath = await getDatabasesPath();
    // you can also use path provider to specify a directory

    final path = p.join(dbPath, filepath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
    // you can use onUpgrade with a diff version to update table
  }

  FutureOr<void> _createDB(Database db, int version) async {
    // defining the db schema
    // this function will only be executed if notes.db is not found in system

    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = "TEXT NOT NULL";
    const boolType = "BOOLEAN NOT NULL";
    // const intergerType = "INTEGER NOT NULL";

    // we'll store createdAt in a textformat utilizing Dateformat.parse

    await db.execute('''
CREATE TABLE $tableName(
  ${NoteFields.id} $idType,
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.createdAt} $textType,
  ${NoteFields.isImportant} $boolType     
  )
''');

// you can create diff tables here
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
