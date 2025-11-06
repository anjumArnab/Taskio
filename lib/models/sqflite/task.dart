import 'package:taskio/models/sqflite/subtask.dart';

class Task {
  int? id;
  String title;
  String? description;
  String dueDate;
  String dueTime;
  String priority;
  List<SubTask> subTasks;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    this.subTasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'priority': priority,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'],
      dueTime: map['dueTime'],
      priority: map['priority'],
    );
  }
}