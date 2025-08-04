import '../models/hive/subtask.dart';
import '../models/hive/task.dart';
import '../services/hive_db.dart';
import '../widgets/button.dart';
import '../widgets/subtask_item.dart';
import 'package:flutter/material.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final int taskKey;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.taskKey,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool isExpanded = false;
  late Task currentTask;
  final TaskService _taskService = TaskService();
  final TextEditingController _subtaskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Create a copy of the task to work with
    currentTask = widget.task;
  }

  // Method to get priority color
  Color _getPriorityColor() {
    switch (currentTask.priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  // Toggle subtask completion
  Future<void> _toggleSubtaskCompletion(int index) async {
    await _taskService.toggleSubTaskCompletion(widget.taskKey, index);
    // Refresh task data
    final updatedTask = await _taskService.getTaskByKey(widget.taskKey);
    if (updatedTask != null) {
      setState(() {
        currentTask = updatedTask;
      });
    }
  }

  // Add new subtask
  Future<void> _addSubtask() async {
    if (_subtaskController.text.isNotEmpty) {
      await _taskService.addSubTaskToTask(
          widget.taskKey, _subtaskController.text);
      _subtaskController.clear();
      // Refresh task data
      final updatedTask = await _taskService.getTaskByKey(widget.taskKey);
      if (updatedTask != null) {
        setState(() {
          currentTask = updatedTask;
        });
      }
    }
  }

  // Remove subtask
  Future<void> _removeSubtask(int index) async {
    await _taskService.removeSubTaskFromTask(widget.taskKey, index);
    // Refresh task data
    final updatedTask = await _taskService.getTaskByKey(widget.taskKey);
    if (updatedTask != null) {
      setState(() {
        currentTask = updatedTask;
      });
    }
  }

  // Delete task
  Future<void> _deleteTask() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              await _taskService.deleteTask(widget.taskKey);
              if (!mounted) return;
              Navigator.pop(context); // Close dialog
              Navigator.pop(context,
                  true); // Return to previous screen with refresh indicator
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  // Navigate to edit screen
  void _editTask() {
    // This would navigate to your task edit screen
    // For now, we'll just pop with a refresh signal
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Task Title
                Text(
                  currentTask.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Due Date
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      currentTask.dueDate.isNotEmpty
                          ? currentTask.dueDate
                          : 'No due date',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Priority
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: _getPriorityColor()),
                    const SizedBox(width: 4),
                    Text(
                      '${currentTask.priority} Priority',
                      style: TextStyle(
                        color: _getPriorityColor(),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentTask.description != null &&
                          currentTask.description!.isNotEmpty
                      ? currentTask.description!
                      : 'No description provided',
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 16),

                // Subtasks
                const Text(
                  'Subtasks',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 12),

                // Subtask List
                if (currentTask.subTasks.isEmpty) const Text('No subtasks yet'),

                ...List.generate(
                  currentTask.subTasks.length,
                  (index) =>
                      _buildSubtaskItem(currentTask.subTasks[index], index),
                ),

                const SizedBox(height: 24),
                // Add subtask input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _subtaskController,
                        decoration: const InputDecoration(
                          hintText: 'Add a subtask',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addSubtask,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                        child: ActionButton(
                      label: 'EDIT',
                      onPressed: _editTask,
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: ActionButton(
                      label: 'DELETE',
                      onPressed: _deleteTask,
                    )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtaskItem(SubTask subtask, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _toggleSubtaskCompletion(index),
              child: SubtaskItem(
                subtask: {
                  'title': subtask.title,
                  'isCompleted': subtask.isCompleted,
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: Colors.grey),
            onPressed: () => _removeSubtask(index),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }
}
