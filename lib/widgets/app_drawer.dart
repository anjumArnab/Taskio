import '../screens/settings.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import '../screens/add_task_screen.dart';
import '../screens/calendar_view_screen.dart';

class AppDrawer extends StatefulWidget {
  final Function refreshTasks;

  const AppDrawer({
    super.key,
    required this.refreshTasks,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _isLoggedIn = false;
  String _username = 'Guest';
  String _email = '';

  void _navToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Taskio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your tasks with ease',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isLoggedIn ? _username : 'Guest',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (_isLoggedIn && _email.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Main Navigation Items

          ListTile(
            leading: const Icon(Icons.add_task, color: Colors.deepPurple),
            title: const Text('Add New Task'),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTaskScreen(),
                ),
              );
              if (result == true || result == null) {
                widget.refreshTasks();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month, color: Colors.deepPurple),
            title: const Text('Calendar View'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalendarScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Task Filters
          ListTile(
            leading: const Icon(Icons.filter_list, color: Colors.deepPurple),
            title: const Text('Priority Filters'),
            onTap: () {
              Navigator.pop(context);
              _showPriorityFilterDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics, color: Colors.deepPurple),
            title: const Text('Task Analytics'),
            onTap: () {
              Navigator.pop(context);

              showSnackBar(context, 'Analytics feature coming soon!');
            },
          ),

          const Divider(),

          // Authentication Section
          if (!_isLoggedIn) ...[
            ListTile(
              leading: const Icon(Icons.login, color: Colors.deepPurple),
              title: const Text('Login'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignInScreen(),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _isLoggedIn = result['isLoggedIn'] ?? false;
                    _username = result['username'] ?? 'User';
                    _email = result['email'] ?? '';
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.deepPurple),
              title: const Text('Sign Up'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _isLoggedIn = result['isLoggedIn'] ?? false;
                    _username = result['username'] ?? 'User';
                    _email = result['email'] ?? '';
                  });
                }
              },
            ),
          ] else ...[
            ListTile(
              leading:
                  const Icon(Icons.account_circle, color: Colors.deepPurple),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);

                showSnackBar(context, 'Profile feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.deepPurple),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _isLoggedIn = false;
                  _username = 'Guest';
                  _email = '';
                });

                showSnackBar(context, 'Logged out successfully');
              },
            ),
          ],

          // Settings and Help
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.deepPurple),
            title: const Text('Settings'),
            onTap: () => _navToSettingsScreen(context),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Taskio v1.0.0',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPriorityFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter by Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.red),
              title: const Text('High Priority'),
              onTap: () {
                Navigator.of(ctx).pop();
                showSnackBar(
                    context, 'Filtering by hign priority coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.orange),
              title: const Text('Medium Priority'),
              onTap: () {
                Navigator.of(ctx).pop();
                showSnackBar(
                    context, 'Filtering by medium priority coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag, color: Colors.green),
              title: const Text('Low Priority'),
              onTap: () {
                Navigator.of(ctx).pop();
                showSnackBar(context, 'Filtering by low priority coming soon!');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
