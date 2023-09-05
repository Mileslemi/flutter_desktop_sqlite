import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_desktop_sqlite/add_note.dart';
import 'package:flutter_desktop_sqlite/db/notes_db.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'model/note.dart';

void main() async {
  if (Platform.isLinux || Platform.isWindows) {
    // Use the ffi version on linux and windows
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Desktop SQLite Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Note> allNotes = [];

  bool isFetching = false;

  @override
  void initState() {
    fetchNotes();
    super.initState();
  }

  @override
  void dispose() {
    NotesDatabase.instance.close();
    super.dispose();
  }

  void fetchNotes() async {
    setState(() {
      isFetching = true;
    });

    allNotes = await NotesDatabase.instance.readAllNotes();

    setState(() {
      isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
              onPressed: () {
                // for autamatic refresh, you'd have to employ Bloc State mngt or getX
                fetchNotes();
              },
              child: Row(
                children: const [
                  Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  Text(
                    "Refresh",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ))
        ],
      ),

      body: allNotes.isEmpty
          ? const Center(
              child: Text("No notes..."),
            )
          : buildNotes(allNotes),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddorEditNote(),
              ));
        },
        child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Widget buildNotes(List<Note> notes) => GridView.custom(
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: [
          const QuiltedGridTile(2, 2),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 2),
        ],
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        childCount: notes.length,
        (context, index) {
          final Note note = notes[index];
          return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddorEditNote(
                        note: note,
                      ),
                    ));
              },
              child: noteTile(note));
        },
      ),
    );

Widget noteTile(Note note) => Card(
      elevation: 1,
      color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              note.title ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Text(
              note.description ?? '',
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
