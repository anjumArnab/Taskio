class SubTask {
  int? id;
  int taskId; // foreign key from Task table
  String title;
  int isCompleted; // use 0/1 for boolean storage

  SubTask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      id: map['id'],
      taskId: map['taskId'],
      title: map['title'],
      isCompleted: map['isCompleted'],
    );
  }
}