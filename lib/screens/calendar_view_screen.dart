import '../models/hive/task.dart';
import '../screens/add_task_screen.dart';
import '../screens/task_details_screen.dart';
import '../services/hive_db.dart';
import '../widgets/snack_bar.dart';
import '../widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final TaskService _taskService = TaskService();

  // Map to store tasks by date for efficient lookup
  Map<String, List<Map<String, dynamic>>> _tasksByDate = {};

  // All tasks from database
  List<Map<String, dynamic>> _allTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadTasks();
  }

  // Load all tasks from database
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get all tasks from the database
      final tasks = await _taskService.getAllTasks();

      // Create list of tasks with their keys
      List<Map<String, dynamic>> taskData = [];

      // We'll enumerate tasks and use the index as the key
      // This assumes tasks are stored with sequential keys starting from 0
      for (int i = 0; i < tasks.length; i++) {
        final task = tasks[i];

        // Only add tasks that have due dates
        if (task.dueDate.isNotEmpty) {
          taskData.add({
            'task': task,
            'key': i, // Use index as key
          });
        }
      }

      // Organize tasks by date for efficient lookup
      _tasksByDate = _groupTasksByDate(taskData);
      _allTasks = taskData;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error if needed
      showSnackBar(context, 'Error loading tasks: $e');
    }
  }

  // Group tasks by their dates for faster lookup
  Map<String, List<Map<String, dynamic>>> _groupTasksByDate(
      List<Map<String, dynamic>> tasks) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var taskData in tasks) {
      final task = taskData['task'] as Task;

      // Parse the date string into a DateTime object
      DateTime? taskDate = _parseDateString(task.dueDate);

      if (taskDate != null) {
        // Create a consistent date key in format 'yyyy-MM-dd'
        String dateKey = DateFormat('yyyy-M-d').format(taskDate);

        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }

        grouped[dateKey]!.add(taskData);
      }
    }

    return grouped;
  }

  // Parse the date string into a DateTime object
  DateTime? _parseDateString(String dateStr) {
    // Handle "Today" and "Tomorrow" cases
    final now = DateTime.now();

    if (dateStr.startsWith('Today')) {
      return DateTime(now.year, now.month, now.day);
    } else if (dateStr.startsWith('Tomorrow')) {
      return now.add(const Duration(days: 1));
    }

    // Try standard date formats
    try {
      // Try to parse as ISO date (yyyy-MM-dd)
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (_) {
      try {
        // Try to parse as "Apr 15, 2023" format
        return DateFormat('MMM d, yyyy').parse(dateStr);
      } catch (_) {
        try {
          // Try to parse just "Apr 15" (assume current year)
          final parsed = DateFormat('MMM d').parse(dateStr);
          return DateTime(now.year, parsed.month, parsed.day);
        } catch (_) {
          // Return null if no format matches
          return null;
        }
      }
    }
  }

  // Get tasks for a specific day
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateFormat('yyyy-M-d').format(day);
    return _tasksByDate[dateKey] ?? [];
  }

  void _navToAddTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    // Reload tasks if a new task was added
    if (result == true) {
      _loadTasks();
    }
  }

  void _navToTaskDetails(BuildContext context, Task task, int taskKey) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task, taskKey: taskKey),
      ),
    );

    // Reload tasks if the task was updated or deleted
    if (result == true) {
      _loadTasks();
    }
  }

  // Check if a task is completed based on its subtasks
  bool _isTaskCompleted(Task task) {
    // If task has no subtasks, it's not completed
    if (task.subTasks.isEmpty) return false;

    // If all subtasks are completed, the task is completed
    return task.subTasks.every((subtask) => subtask.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _navToAddTask(context),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.purple,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            // Optionally mark days that have tasks
            eventLoader: (day) {
              final dateKey = DateFormat('yyyy-M-d').format(day);
              return _tasksByDate[dateKey]?.isNotEmpty == true ? [1] : [];
            },
          ),
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedTasks.isEmpty
                    ? const Center(child: Text('No tasks for this day'))
                    : ListView.builder(
                        itemCount: selectedTasks.length,
                        itemBuilder: (context, index) {
                          final taskData = selectedTasks[index];
                          final task = taskData['task'] as Task;
                          final taskKey = taskData['key'] as int;

                          return InkWell(
                            onTap: () =>
                                _navToTaskDetails(context, task, taskKey),
                            child: TaskTile(
                              title: task.title,
                              subtitle: '${task.dueTime} - ${task.priority}',
                              completed: _isTaskCompleted(task),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
