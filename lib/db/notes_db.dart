import 'dart:async';
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
  }

  FutureOr<void> _createDB(Database db, int version) {
    // defining the db schema
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
