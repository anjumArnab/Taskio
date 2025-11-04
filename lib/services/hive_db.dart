import '../models/hive/subtask.dart';
import '../models/hive/task.dart';
import 'package:hive/hive.dart';

/// Service class to handle all CRUD operations for Task model
/// Tasks contain embedded SubTask objects, so all operations are handled through this service
class TaskService {
  // Name of the Hive box for storing tasks
  static const String _taskBox = 'tasks';

  /// Open the Hive box for tasks (creates it if not already open)
  Future<Box<Task>> _openBox() async => await Hive.openBox<Task>(_taskBox);

  /// Add a new Task to the Hive box
  Future<void> addTask(Task task) async {
    final box = await _openBox(); // Open the box
    await box.add(task); // Add the task to the box
  }

  /// Retrieve all tasks from the Hive box
  Future<List<Task>> getAllTasks() async {
    final box = await _openBox(); // Open the box
    return box.values.toList(); // Convert values to list and return
  }

  /// Retrieve a specific task using its Hive key
  Future<Task?> getTaskByKey(int key) async {
    final box = await _openBox(); // Open the box
    return box.get(key); // Get the task by its key
  }

  /// Update a task at a specific key with new data
  Future<void> updateTask(int key, Task updatedTask) async {
    final box = await _openBox(); // Open the box
    await box.put(key, updatedTask); // Replace the task at the key
  }

  /// Delete a task by its Hive key
  Future<void> deleteTask(int key) async {
    final box = await _openBox(); // Open the box
    await box.delete(key); // Delete the task at the key
  }

  /// Delete all tasks from the box
  Future<void> deleteAllTasks() async {
    final box = await _openBox(); // Open the box
    await box.clear(); // Clear all entries
  }
  
  /// Add a subtask to an existing task
  Future<void> addSubTaskToTask(int taskKey, String subtaskTitle) async {
    final box = await _openBox();
    final task = box.get(taskKey);
    
    if (task != null) {
      task.subTasks.add(
        SubTask(title: subtaskTitle)
      );
      await box.put(taskKey, task);
    }
  }
  
  /// Update a subtask within a task
  Future<void> updateSubTaskInTask(int taskKey, int subtaskIndex, SubTask updatedSubtask) async {
    final box = await _openBox();
    final task = box.get(taskKey);
    
    if (task != null && subtaskIndex >= 0 && subtaskIndex < task.subTasks.length) {
      task.subTasks[subtaskIndex] = updatedSubtask;
      await box.put(taskKey, task);
    }
  }
  
  /// Toggle completion status of a subtask
  Future<void> toggleSubTaskCompletion(int taskKey, int subtaskIndex) async {
    final box = await _openBox();
    final task = box.get(taskKey);
    
    if (task != null && subtaskIndex >= 0 && subtaskIndex < task.subTasks.length) {
      task.subTasks[subtaskIndex].isCompleted = !task.subTasks[subtaskIndex].isCompleted;
      await box.put(taskKey, task);
    }
  }
  
  /// Remove a subtask from a task
  Future<void> removeSubTaskFromTask(int taskKey, int subtaskIndex) async {
    final box = await _openBox();
    final task = box.get(taskKey);
    
    if (task != null && subtaskIndex >= 0 && subtaskIndex < task.subTasks.length) {
      task.subTasks.removeAt(subtaskIndex);
      await box.put(taskKey, task);
    }
  }
}