import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:taskio/models/sqflite/subtask.dart';
import 'package:taskio/models/sqflite/task.dart';

/// Service class for managing tasks and subtasks in SQLite database
/// Implements singleton pattern to ensure single database instance
class TaskService {
  // Database configuration constants
  static const String _databaseName = 'taskio.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _taskTable = 'tasks';
  static const String _subtaskTable = 'subtasks';

  // Singleton instance and database reference
  static TaskService? _instance;
  static Database? _database;

  // Private constructor to prevent direct instantiation
  TaskService._();

  /// Returns the singleton instance of TaskService
  static TaskService get instance {
    _instance ??= TaskService._();
    return _instance!;
  }

  /// Gets the database instance, initializing it if necessary
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and returns the database instance
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  /// Configures database settings (enables foreign key constraints)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates database tables when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    // Create tasks table
    await db.execute('''
      CREATE TABLE $_taskTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL, 
        dueTime TEXT NOT NULL,
        priority TEXT NOT NULL
      )
    ''');

    // Create subtasks table with foreign key relationship
    await db.execute('''
      CREATE TABLE $_subtaskTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        taskId INTEGER NOT NULL,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (taskId) REFERENCES $_taskTable (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Initializes the database (useful for ensuring database is ready at app startup)
  Future<void> init() async {
    await database;
  }

  /// Adds a new task to the database
  /// 
  /// [task] - The task object to be added
  /// Note: If a task with the same ID exists, it will be replaced
  Future<void> addTask(Task task) async {
    final db = await database;
    await db.insert(
      _taskTable,
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Adds a new subtask to an existing task
  /// 
  /// [taskId] - The ID of the parent task
  /// [subtaskTitle] - The title of the subtask to be added
  /// Throws an exception if the task doesn't exist
  Future<void> addSubTaskToTask(int taskId, String subtaskTitle) async {
    final db = await database;

    // Verify that the parent task exists
    final taskExists = await db.query(
      _taskTable,
      where: 'id = ?',
      whereArgs: [taskId],
    );

    if (taskExists.isEmpty) {
      throw Exception('Task with id $taskId does not exist');
    }

    // Create and insert the subtask
    final SubTask subTask = SubTask(taskId: taskId, title: subtaskTitle);

    await db.insert(
      _subtaskTable,
      subTask.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Retrieves all tasks from the database along with their subtasks
  /// 
  /// Returns a list of Task objects, each populated with its subtasks
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_taskTable);

    List<Task> tasks = [];
    for (var map in maps) {
      final task = Task.fromMap(map);
      task.subTasks = await _getSubtasksForTasks(task.id!);
      tasks.add(task);
    }
    return tasks;
  }

  /// Retrieves all subtasks for a specific task
  /// 
  /// [taskId] - The ID of the parent task
  /// Returns a list of SubTask objects
  Future<List<SubTask>> _getSubtasksForTasks(int taskId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _subtaskTable,
      where: 'taskId = ?',
      whereArgs: [taskId],
    );

    return maps.map((map) => SubTask.fromMap(map)).toList();
  }

  /// Updates an existing task in the database
  /// 
  /// [id] - The ID of the task to update
  /// [updatedTask] - The task object with updated values
  Future<void> updateTask(int id, Task updatedTask) async {
    final db = await database;

    await db.update(
      _taskTable,
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes a task by its ID
  /// 
  /// [id] - The ID of the task to delete
  /// Note: All associated subtasks will be automatically deleted due to CASCADE constraint
  Future<void> deleteTask(int id) async {
    final db = await database;

    await db.delete(
      _taskTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes all tasks from the database
  /// 
  /// Note: All subtasks will be automatically deleted due to CASCADE constraint
  Future<void> deleteAllTasks() async {
    final db = await database;
    await db.delete(_taskTable);
  }

  /// Updates an existing subtask
  /// 
  /// [taskId] - The ID of the parent task (used for verification)
  /// [subtaskId] - The ID of the subtask to update
  /// [updatedSubtask] - The subtask object with updated values
  /// Throws an exception if the subtask doesn't exist or doesn't belong to the specified task
  Future<void> updateSubTaskInTask(
      int taskId, int subtaskId, SubTask updatedSubtask) async {
    final db = await database;

    // Verify the subtask exists and belongs to the specified task
    final existingSubtask = await db.query(
      _subtaskTable,
      where: 'id = ? AND taskId = ?',
      whereArgs: [subtaskId, taskId],
    );

    if (existingSubtask.isEmpty) {
      throw Exception(
          'Subtask with id $subtaskId does not exist for task $taskId');
    }

    await db.update(
      _subtaskTable,
      updatedSubtask.toMap(),
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  /// Retrieves a single task by its ID along with its subtasks
  /// 
  /// [id] - The ID of the task to retrieve
  /// Returns the Task object if found, null otherwise
  Future<Task?> getTaskByKey(int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      _taskTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    final task = Task.fromMap(maps.first);
    task.subTasks = await _getSubtasksForTasks(task.id!);

    return task;
  }

  /// Deletes a specific subtask by its ID
  /// 
  /// [subtaskId] - The ID of the subtask to delete
  Future<void> deleteSubTask(int subtaskId) async {
    final db = await database;

    await db.delete(
      _subtaskTable,
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }

  /// Closes the database connection
  /// Should be called when the app is terminated
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}