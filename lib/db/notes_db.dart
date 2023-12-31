import 'dart:async';
import 'package:flutter_desktop_sqlite/model/note.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:path/path.dart' as p;

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  Future<Database> get database async {
    // open a connection

    // this will run when you call instance.database
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
    // - on android - /data/user/0/com.example.flutter_desktop_sqlite/databases/notes.db
    // on windows - .dart_tool/sqflite_common_ffi/databases/notes.db

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
CREATE TABLE $notesTableName(
  ${NoteFields.id} $idType,
  ${NoteFields.title} $textType,
  ${NoteFields.description} $textType,
  ${NoteFields.createdAt} $textType,
  ${NoteFields.isImportant} $boolType     
  )
''');

// you can create diff tables here
  }

  Future<Note> create(Note note) async {
    // initialize db
    final db = await instance.database;

    final id = await db.insert(notesTableName, note.toMap());
    // returns the id of the inserted row. Which is auto_genrated or specified.
    // you can also use raw sql
    // final noteMap = note.toMap()
    // final $columns = '${NoteFields.title},${NoteFields.desc}';
    // final values = "${noteMap[NoteFields.title]},${noteMap[NoteFields.desc]}";
    // int id1 = await database.rawInsert(
    // 'INSERT INTO table_name($columns) VALUES($values)');
    return note.copyWith(id: id);
  }

  Future<Note> readNote(int id) async {
    // initialize db
    final db = await instance.database;

    final List maps = await db.query(notesTableName,
        columns: NoteFields.retrieveValues,
        where: "${NoteFields.id} = ?",
        whereArgs: [id]);

    // using whereArgs prevents sql injection attack, more secure.
    // also you can add
    // where: "${NoteFields.id} = ?, ${Notefield.title} = ?",
    // whereArgs: [id, title]
    // there are also other parameters you can add, orderBy, distinct e.t.c
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    throw Exception("ID $id not found");
  }

  Future<List<Note>> readAllNotes() async {
    // initialize db
    final db = await instance.database;

    const orderBy = "${NoteFields.createdAt} ASC";

    final List notes = await db.query(notesTableName, orderBy: orderBy);

    return notes.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> update(Note note) async {
    final db = await instance.database;

    int id = await db.update(
      notesTableName,
      note.toMap(),
      where: "${NoteFields.id} = ?",
      whereArgs: [note.id],
    );

    return id;
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      notesTableName,
      where: "${NoteFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
  }
}
