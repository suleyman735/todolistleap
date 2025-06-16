import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todolistleap/blocs/auth_bloc.dart';
import 'package:todolistleap/blocs/auth_event.dart';


import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/blocs/task_event.dart';
import 'package:todolistleap/blocs/task_state.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/ui-widgets/custom_app_bar.dart';
import 'package:todolistleap/ui-widgets/custom_bottom_app_bar.dart';
import 'package:todolistleap/ui-widgets/custom_drawer.dart';
import 'package:todolistleap/ui-widgets/task_modals.dart';





class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now(); // June 16, 2025
  DateTime? _selectedDay;
  bool? _showCompleted = null;
  String? _username;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _selectedDay = _focusedDay;
    context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('email')?.split('@')[0]; // Use email prefix as username
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          // Calendar section
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
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                context.read<TaskBloc>().add(FilterTasksEvent(filterDate: selectedDay, showCompleted: _showCompleted));
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
                weekendTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.redAccent),
                defaultTextStyle: AppTypography.bodyMedium,
                tablePadding: const EdgeInsets.symmetric(horizontal: 8.0),
              ),
              headerStyle: HeaderStyle(
                formatButtonTextStyle: AppTypography.bodyMedium.copyWith(color: AppColors.primary),
                formatButtonDecoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                titleTextStyle: AppTypography.headlineMedium,
                leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
                rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final tasks = context.read<TaskBloc>().state.tasks;
                  if (tasks.any((task) =>
                  task.date.year == date.year &&
                      task.date.month == date.month &&
                      task.date.day == date.day)) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          // Filter section (scrollable)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedDay = DateTime.now();
                        _focusedDay = _selectedDay!;
                        _showCompleted = null;
                      });
                      context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    child: Text('Today', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Completed', style: AppTypography.bodyMedium),
                    selected: _showCompleted == true,
                    onSelected: (selected) {
                      setState(() {
                        _showCompleted = selected ? true : null;
                      });
                      context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
                    },
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Not Completed', style: AppTypography.bodyMedium),
                    selected: _showCompleted == false,
                    onSelected: (selected) {
                      setState(() {
                        _showCompleted = selected ? false : null;
                      });
                      context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
                    },
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('All Tasks', style: AppTypography.bodyMedium),
                    selected: _selectedDay == null && _showCompleted == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDay = null;
                          _showCompleted = null;
                        });
                        print('All Tasks button pressed: Clearing filters');
                        context.read<TaskBloc>().add(FilterTasksEvent(filterDate: null, showCompleted: null));
                      }
                    },
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          // Task list
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state.filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 64, color: AppColors.text.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for this date. Add a new task!',
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
                      key: Key(task.title + index.toString()),
                      direction: DismissDirection.endToStart,
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
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
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
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              task.priority,
                              style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                            ),
                          ),
                          title: Row(
                            children: [
                              // Category tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(task.category),
                                  borderRadius: BorderRadius.circular(6.0),
                                ),
                                child: Text(
                                  task.category,
                                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: AppTypography.bodyMedium.copyWith(
                                    decoration: task.isCompleted == true ? TextDecoration.lineThrough : null,
                                    color: task.isCompleted == true ? AppColors.text.withOpacity(0.5) : AppColors.text,
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
                                index: index,
                                categories: ['University', 'Home', 'Work'],
                                defaultCategory: 'University',
                              );
                              context.read<TaskBloc>().add(FilterTasksEvent(
                                filterDate: _selectedDay,
                                showCompleted: _showCompleted,
                              ));
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
      // Unchanged CustomBottomNavBar
      bottomNavigationBar: CustomBottomNavBar(
        currentRoute: '/calendar',
        scaffoldKey: _scaffoldKey,
        parentContext: context,
        initialDate: _selectedDay,
        showCompleted: _showCompleted,
      ),
    );
  }

  // Helper method to assign colors to categories
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'University':
        return Colors.blue;
      case 'Home':
        return Colors.red;
      case 'Work':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }
}
//
// class CalendarScreen extends StatefulWidget {
//   @override
//   _CalendarScreenState createState() => _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now(); // June 15, 2025
//   DateTime? _selectedDay;
//   bool? _showCompleted = null;
//   String? _username;
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUsername();
//     _selectedDay = _focusedDay;
//     context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
//   }
//
//
//
//   Future<void> _loadUsername() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _username = prefs.getString('email');
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//
//       backgroundColor: AppColors.background,
//       appBar: CustomAppBar(
//         username: _username,
//         onProfileTap: () => _scaffoldKey.currentState?.openEndDrawer(),
//       ),
//       // AppBar(
//       //   title: Text('Calendar', style: AppTypography.headlineMedium),
//       // ),
//       endDrawer: CustomDrawer(
//         username: _username,
//         onLogout: () {
//           context.read<AuthBloc>().add(const LogoutEvent());
//           _scaffoldKey.currentState?.closeEndDrawer();
//         },
//       ),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             focusedDay: _focusedDay,
//             calendarFormat: _calendarFormat,
//             selectedDayPredicate: (day) {
//               return isSameDay(_selectedDay, day);
//             },
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 _selectedDay = selectedDay;
//                 _focusedDay = focusedDay;
//               });
//               context.read<TaskBloc>().add(FilterTasksEvent(filterDate: selectedDay, showCompleted: _showCompleted));
//             },
//             onFormatChanged: (format) {
//               if (_calendarFormat != format) {
//                 setState(() {
//                   _calendarFormat = format;
//                 });
//               }
//             },
//             onPageChanged: (focusedDay) {
//               _focusedDay = focusedDay;
//             },
//             calendarStyle: CalendarStyle(
//               todayDecoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.3),
//                 shape: BoxShape.circle,
//               ),
//               selectedDecoration: BoxDecoration(
//                 color: AppColors.primary,
//                 shape: BoxShape.circle,
//               ),
//               markerDecoration: BoxDecoration(
//                 color: AppColors.text,
//                 shape: BoxShape.circle,
//               ),
//               outsideDaysVisible: false,
//               weekendTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.red),
//               defaultTextStyle: AppTypography.bodyMedium,
//             ),
//             calendarBuilders: CalendarBuilders(
//               markerBuilder: (context, date, events) {
//                 final tasks = context.read<TaskBloc>().state.tasks;
//                 if (tasks.any((task) =>
//                 task.date.year == date.year &&
//                     task.date.month == date.month &&
//                     task.date.day == date.day)) {
//                   return Positioned(
//                     right: 1,
//                     bottom: 1,
//                     child: Icon(
//                       Icons.circle,
//                       size: 8.0,
//                       color: AppColors.primary,
//                     ),
//                   );
//                 }
//                 return null;
//               },
//             ),
//           ),
//           SizedBox(
//             height: 60,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       _selectedDay = DateTime.now();
//                       _focusedDay = _selectedDay!;
//                       _showCompleted = null;
//                     });
//                     context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
//                   },
//                   child: Text('Today'),
//                   style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                 ),
//                 SizedBox(width: 10),
//                 OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                       _showCompleted = true;
//                     });
//                     context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
//                   },
//                   child: Text('Completed'),
//                 ),
//                 SizedBox(width: 10),
//                 OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                       _showCompleted = false;
//                     });
//                     context.read<TaskBloc>().add(FilterTasksEvent(filterDate: _selectedDay, showCompleted: _showCompleted));
//                   },
//                   child: Text('Not Completed'),
//                 ),
//                 SizedBox(width: 10),
//                 OutlinedButton(
//                   onPressed: () {
//                     setState(() {
//                       _selectedDay = null;
//                       _showCompleted = null;
//                     });
//                     context.read<TaskBloc>().add(FilterTasksEvent(filterDate: null, showCompleted: null));
//                   },
//                   child: Text('All Tasks'),
//                 ),
//                 SizedBox(width: 10),
//               ],
//             ),
//           ),
//           Expanded(
//             child: BlocBuilder<TaskBloc, TaskState>(
//               builder: (context, state) {
//                 return ListView.builder(
//                   itemCount: state.filteredTasks.length,
//                   itemBuilder: (context, index) {
//                     final task = state.filteredTasks[index];
//                     return Dismissible(
//                       key: Key(task.title + index.toString()),
//                       direction: DismissDirection.endToStart,
//                       onDismissed: (direction) {
//                         context.read<TaskBloc>().add(DeleteTaskEvent(index));
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('${task.title} deleted')),
//                         );
//                       },
//                       background: Container(
//                         color: Colors.red,
//                         alignment: Alignment.centerRight,
//                         padding: EdgeInsets.only(right: 20),
//                         child: Icon(Icons.delete, color: Colors.white),
//                       ),
//                       child: ListTile(
//                         leading: CircleAvatar(child: Text(task.priority)),
//                         title: Text(task.title, style: AppTypography.bodyMedium),
//                         subtitle: Text('${task.date.toIso8601String().split('T')[0]} ${task.time}',
//                             style: AppTypography.bodyMedium),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                               decoration: BoxDecoration(
//                                 color: task.category == 'University'
//                                     ? Colors.blue
//                                     : task.category == 'Home'
//                                     ? Colors.red
//                                     : Colors.orange,
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Text(task.category, style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.edit, color: AppColors.text),
//                               onPressed: () {
//                                 showEditTaskModal(
//                                   context,
//                                   task: task,
//                                   index: index,
//                                   categories: ['University', 'Home', 'Work'],
//                                   defaultCategory: 'University',
//                                 );
//                                 // Refresh tasks after editing
//                                 context.read<TaskBloc>().add(FilterTasksEvent(
//                                   filterDate: _selectedDay,
//                                   showCompleted: _showCompleted,
//                                 ));
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: CustomBottomNavBar(
//         currentRoute: '/calendar',
//         scaffoldKey: _scaffoldKey,
//         parentContext: context,
//         initialDate: _selectedDay,
//         showCompleted: _showCompleted,
//       ),
//
//     );
//   }
// }








