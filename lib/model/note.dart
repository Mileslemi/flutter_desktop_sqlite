import 'dart:convert';

const String notesTableName = 'notes';

class NoteFields {
  // columns to retrieve when reading db table
  static const List<String> retrieveValues = [
    id,
    title,
    description,
    createdAt,
    isImportant
  ];
  // our notes table column names
  static const String id = '_id';
  // an underscore before id
  static const String title = "title";
  static const String description = "description";
  static const String createdAt = "createdAt";
  static const String isImportant = "isImportant";
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Note {
  final int? id;
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isImportant;
  Note({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isImportant,
  });

  Note copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdAt,
    bool? isImportant,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      isImportant: isImportant ?? this.isImportant,
    );
  }

  Map<String, dynamic> toMap() {
    // since we use this method to change the object to a json like format
    // that'll be store in table, we need to change certain fields.
    // e.g. bool. If true we store as 1, else 0
    // e.g. timeField. We convert it to string object
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isImportant': isImportant ? 1 : 0,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] != null ? map['id'] as int : null,
      title: (map['title'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      createdAt: DateTime.parse((map['createdAt'] ?? '') as String),
      isImportant: map['isImportant'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Note(id: $id, title: $title, description: $description, createdAt: $createdAt, isImportant: $isImportant)';
  }
}
