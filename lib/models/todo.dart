// lib/models/todo.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String title;
  bool isCompleted;
  DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
  });

  factory Todo.fromMap(Map<String, dynamic> map, String documentId) {
    return Todo(
      id: documentId,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}