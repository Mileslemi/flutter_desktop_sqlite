import 'package:flutter/material.dart';

import 'db/notes_db.dart';
import 'model/note.dart';

class AddorEditNote extends StatefulWidget {
  const AddorEditNote({super.key, this.note = const Note()});

  final Note? note;

  @override
  State<AddorEditNote> createState() => _AddorEditNoteState();
}

class _AddorEditNoteState extends State<AddorEditNote> {
  final formKey = GlobalKey<FormState>();
  var title = "Add Note";
  var btnText = "Save";

  final TextEditingController _title = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  bool isImportant = false;

  @override
  void initState() {
    if (widget.note?.id != null) {
      _title.text = widget.note?.title ?? '';
      _desc.text = widget.note?.description ?? '';
      isImportant = widget.note?.isImportant ?? false;
      btnText = "Update";
      title = "Edit Note";
    }
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
        ),
        actions: [
          IconButton(
              onPressed: widget.note?.id == null
                  ? null
                  : () async {
                      await NotesDatabase.instance.delete(widget.note!.id!);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Form(
        key: formKey,
        child: Column(children: [
          TextInputWidget(
            title: "Title",
            controller: _title,
          ),
          TextInputWidget(
            title: "Description",
            controller: _desc,
          ),
          SwitchListTile(
            title: const Text("Important"),
            value: isImportant,
            onChanged: (value) {
              setState(() {
                isImportant = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                if (widget.note?.id == null) {
                  await NotesDatabase.instance.create(
                    Note(
                      title: _title.text,
                      description: _desc.text,
                      createdAt: DateTime.now(),
                      isImportant: isImportant,
                    ),
                  );
                } else {
                  await NotesDatabase.instance.update(
                    Note(
                      id: widget.note?.id,
                      title: _title.text,
                      description: _desc.text,
                      createdAt: widget.note?.createdAt,
                      isImportant: isImportant,
                    ),
                  );
                }
              }
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: Text(btnText),
          )
        ]),
      ),
    );
  }
}

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    super.key,
    required String title,
    required this.controller,
  }) : _title = title;

  final String _title;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_title),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: TextFormField(
              controller: controller,
              validator: (value) {
                if (value == null) {
                  return "Invalid";
                }
                return null;
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
