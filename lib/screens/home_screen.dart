import '../models/hive/subtask.dart';
import '../models/hive/task.dart';
import '../screens/add_task_screen.dart';
import '../screens/task_details_screen.dart';
import '../services/hive_db.dart';
import '../widgets/app_drawer.dart';
import '../widgets/task_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskService.getAllTasks();
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $e')),
        );
      }
    }
  }

  void _navToAddTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );

    // Refresh the task list when returning from add task screen
    if (result == true || result == null) {
      _loadTasks();
    }
  }

  void _navToTaskDetailsScreen(
      BuildContext context, Task task, int taskKey) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task, taskKey: taskKey),
      ),
    );

    // Refresh the task list when returning from details screen
    if (result == true || result == null) {
      _loadTasks();
    }
  }

  // Helper method to get completion status of a task
  bool isTaskCompleted(Task task) {
    if (task.subTasks.isEmpty) return false;
    return task.subTasks.every((subtask) => subtask.isCompleted);
  }

  // Helper method to check if a task is due today
  bool isTaskDueToday(Task task) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return task.dueDate == today;
  }

  // Helper method to check if a task is upcoming (future date, not today)
  bool isTaskUpcoming(Task task) {
    final today = DateTime.now();
    final dueDate = DateFormat('yyyy-MM-dd').parse(task.dueDate);
    return dueDate.isAfter(today) && !isTaskDueToday(task);
  }

  // Helper to format the subtitle text
  String getSubtitleText(Task task) {
    if (isTaskCompleted(task)) {
      return 'Completed';
    }

    final dueDate = DateFormat('yyyy-MM-dd').parse(task.dueDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    String dateText;
    if (dueDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (dueDate.isAtSameMomentAs(tomorrow)) {
      dateText = 'Tomorrow';
    } else {
      dateText = DateFormat('MMM d').format(dueDate);
    }

    return '$dateText, ${task.dueTime}';
  }

  // Toggle task completion status by toggling all subtasks
  Future<void> _toggleTaskCompletion(Task task, int taskKey) async {
    final isCurrentlyCompleted = isTaskCompleted(task);

    // Create a new updated task with toggled subtasks
    Task updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      dueTime: task.dueTime,
      priority: task.priority,
      subTasks: task.subTasks.map((subtask) {
        return SubTask(
          id: subtask.id,
          title: subtask.title,
          isCompleted:
              !isCurrentlyCompleted, // Toggle all subtasks to the same state
        );
      }).toList(),
    );

    try {
      await _taskService.updateTask(taskKey, updatedTask);
      _loadTasks(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating task: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Taskio"),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _navToAddTask(context)),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          tabs: const [
            Tab(text: "All todos"),
            Tab(text: "Today"),
            Tab(text: "Upcoming"),
            Tab(text: "Completed"),
          ],
          onTap: (_) {
            // Force a rebuild when tab changes
            setState(() {});
          },
        ),
      ),
      drawer: AppDrawer(refreshTasks: _loadTasks),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // All todos tab
                buildTaskList(_tasks, 0),
                // Today tab
                buildTaskList(
                    _tasks.where((task) => isTaskDueToday(task)).toList(), 1),
                // Upcoming tab
                buildTaskList(
                    _tasks.where((task) => isTaskUpcoming(task)).toList(), 2),
                // Completed tab
                buildTaskList(
                    _tasks.where((task) => isTaskCompleted(task)).toList(), 3),
              ],
            ),
    );
  }

  Widget buildTaskList(List<Task> tasks, int tabIndex) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              tabIndex == 0
                  ? 'No tasks yet'
                  : tabIndex == 1
                      ? 'No tasks due today'
                      : tabIndex == 2
                          ? 'No upcoming tasks'
                          : 'No completed tasks',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (tabIndex == 0)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: () => _navToAddTask(context),
                child: const Text('Add your first task',
                    style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, i) {
        final task = tasks[i];
        // Get the actual Hive box key for this task
        // In a real app you might need to store and track keys differently
        final taskKey =
            i; // This assumes tasks are in order of keys, which may not be accurate

        return TaskTile(
          title: task.title,
          subtitle: getSubtitleText(task),
          completed: isTaskCompleted(task),
          onTap: () => _toggleTaskCompletion(task, taskKey),
          onDoubleTap: () => _navToTaskDetailsScreen(context, task, taskKey),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
