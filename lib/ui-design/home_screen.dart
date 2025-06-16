
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolistleap/blocs/auth_bloc.dart';
import 'package:todolistleap/blocs/auth_event.dart';
import 'package:todolistleap/blocs/auth_state.dart';
import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/blocs/task_event.dart';
import 'package:todolistleap/blocs/task_state.dart';


import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/models/task_model.dart';
import 'package:todolistleap/ui-widgets/custom_app_bar.dart';
import 'package:todolistleap/ui-widgets/custom_drawer.dart';
import 'package:todolistleap/ui-widgets/task_modals.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('email')?.split('@')[0]; // Use email prefix as username
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!state.isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          username: _username,
          onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        endDrawer: CustomDrawer(
          username: _username,
          onLogout: () {
            context.read<AuthBloc>().add(const LogoutEvent());
            _scaffoldKey.currentState?.closeEndDrawer();
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                'Hello, ${_username ?? "User"}!',
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                semanticsLabel: 'Greeting for ${_username ?? "User"}',
              ),
            ),
            // Filter section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tasks', style: AppTypography.headlineMedium),
                  BlocBuilder<TaskBloc, TaskState>(
                    buildWhen: (previous, current) =>
                    previous.filterDate != current.filterDate || previous.showCompleted != current.showCompleted,
                    builder: (context, state) {
                      return Row(
                        children: [
                          // Date filter
                          GestureDetector(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: state.filterDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                print('Selected date: ${pickedDate.toIso8601String().split('T')[0]}');
                                context.read<TaskBloc>().add(FilterTasksEvent(filterDate: pickedDate));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.text.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    state.filterDate != null
                                        ? state.filterDate!.toIso8601String().split('T')[0]
                                        : 'Select Date',
                                    style: AppTypography.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Completion filter
                          DropdownButton<String>(
                            key: ValueKey(state.showCompleted),
                            value: state.showCompleted == null
                                ? 'all'
                                : (state.showCompleted! ? 'completed' : 'not_completed'),
                            style: AppTypography.bodyMedium,
                            items: const [
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                              DropdownMenuItem(value: 'not_completed', child: Text('Not Completed')),
                              DropdownMenuItem(value: 'all', child: Text('All')),
                            ],
                            onChanged: (value) {
                              print('Selected value: $value');
                              context.read<TaskBloc>().add(FilterTasksEvent(
                                showCompleted: value == 'all' ? null : value == 'completed',
                              ));
                            },
                          )


                          // DropdownButton<bool?>(
                          //   value: state.showCompleted,
                          //   style: AppTypography.bodyMedium,
                          //   items: const [
                          //     DropdownMenuItem(value: true, child: Text('Completed')),
                          //     DropdownMenuItem(value: false, child: Text('Not Completed')),
                          //     DropdownMenuItem(value: null, child: Text('All')),
                          //   ],
                          //   onChanged: (value) {
                          //     context.read<TaskBloc>().add(FilterTasksEvent(showCompleted: value));
                          //   },
                          // ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Task list
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  // if (state.error != null) {
                  //   WidgetsBinding.instance.addPostFrameCallback((_) {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(content: Text(state.error!)),
                  //     );
                  //   });
                  // }
                  if (state.filteredTasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 64, color: AppColors.text.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks found. Add a new task!',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.text.withOpacity(0.5)),
                            semanticsLabel: 'No tasks available',
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return Dismissible(
                        key: Key(task.id.toString()),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red, Colors.red.withOpacity(0.7)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Task'),
                              content: Text('Are you sure you want to delete "${task.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          context.read<TaskBloc>().add(DeleteTaskEvent(index));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${task.title} deleted')),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            leading: Checkbox(
                              value: task.isCompleted,
                              activeColor: AppColors.primary,
                              onChanged: (value) {
                                if (value != null) {
                                  print('jj');
                                  context.read<TaskBloc>().add(ToggleTaskCompletionEvent(index));
                                }
                              },
                              semanticLabel: task.isCompleted ? 'Unmark task as completed' : 'Mark task as completed',
                            ),
                            title: Row(
                              children: [
                                // Category tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(task.category ?? 'University'),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    task.category ?? 'University',
                                    style: AppTypography.labelSmall.copyWith(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: AppTypography.bodyMedium.copyWith(
                                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                      color: task.isCompleted ? AppColors.text.withOpacity(0.5) : AppColors.text,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              '${task.date.toIso8601String().split('T')[0]} ${task.time}',
                              style: AppTypography.labelSmall,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.edit, color: AppColors.primary),
                              onPressed: () {
                                showEditTaskModal(
                                  context,
                                  task: task,
                                  index: state.tasks.indexWhere((t) => t.id == task.id),
                                  categories: ['University', 'Home', 'Work'],
                                  defaultCategory: 'University',
                                );
                              },
                              tooltip: 'Edit task',
                            ),
                            onTap: () {
                              context.read<TaskBloc>().add(ToggleTaskCompletionEvent(index));
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        // BottomAppBar with FAB
        bottomNavigationBar: BottomAppBar(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.list, color: AppColors.primary),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: AppColors.text),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/calendar');
                  },
                ),
                BlocBuilder<TaskBloc, TaskState>(
                  buildWhen: (previous, current) => previous.filterDate != current.filterDate,
                  builder: (context, state) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          print('Opening add task modal with initialDate: ${state.filterDate}');
                          showAddTaskModal(
                            context,
                            initialDate: state.filterDate,
                            categories: ['University', 'Home', 'Work'],
                            defaultCategory: 'University',
                          );
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.watch_later, color: AppColors.text),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/chart');
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person, color: AppColors.text),
                  onPressed: () {
                    _scaffoldKey.currentState?.openEndDrawer();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to assign colors to categories
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'University':
        return Colors.blue;
      case 'Home':
        return Colors.green;
      case 'Work':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}

