
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/blocs/task_event.dart';
import 'package:todolistleap/blocs/task_state.dart';


import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/models/task_model.dart';
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc()..add(FilterTasksEvent(filterDate: DateTime.now())),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: AppColors.text),
            onPressed: () {},
          ),
          actions: [
            CircleAvatar(
              radius: 20,
            ),
            SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tasks', style: AppTypography.headlineMedium),
                  Builder(
                    builder: (innerContext) {
                      final taskBloc = BlocProvider.of<TaskBloc>(innerContext);
                      return Row(
                        children: [
                          Text(
                            taskBloc.state.filterDate?.toIso8601String().split('T')[0] ?? 'Select Date',
                            style: AppTypography.bodyMedium,
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today, color: AppColors.text),
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: innerContext,
                                initialDate: taskBloc.state.filterDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                taskBloc.add(FilterTasksEvent(filterDate: pickedDate));
                              }
                            },
                          ),
                          DropdownButton<bool>(
                            value: taskBloc.state.showCompleted,
                            hint: Text('Filter by Completion', style: AppTypography.bodyMedium),
                            items: [
                              DropdownMenuItem(value: true, child: Text('Completed', style: AppTypography.bodyMedium)),
                              DropdownMenuItem(value: false, child: Text('Not Completed', style: AppTypography.bodyMedium)),
                              DropdownMenuItem(value: null, child: Text('All', style: AppTypography.bodyMedium)),
                            ],
                            onChanged: (value) {
                              taskBloc.add(FilterTasksEvent(showCompleted: value));
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<TaskBloc, TaskState>(
                builder: (context, state) {
                  return ListView.builder(
                    itemCount: state.filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = state.filteredTasks[index];
                      return Dismissible(
                        key: Key(task.title + index.toString()),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          context.read<TaskBloc>().add(DeleteTaskEvent(index));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${task.title} deleted')),
                          );
                        },
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<TaskBloc>().add(ToggleTaskCompletionEvent(index));
                              }
                            },
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Text('${task.date.toIso8601String().split('T')[0]} ${task.time}'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: AppColors.text),
                            onPressed: () {
                              _showEditTaskModal(context, task, index);
                            },
                          ),
                          onTap: () {
                            context.read<TaskBloc>().add(ToggleTaskCompletionEvent(index));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.list, color: AppColors.primary),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: AppColors.text),
                  onPressed: () {},
                ),
                Builder(
                  builder: (context) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          _showAddTaskModal(context);
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.watch_later, color: AppColors.text),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.person, color: AppColors.text),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    String selectedDate = '';
    String selectedTime = '';
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    final priorityController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Task',
                    style: AppTypography.headlineMedium,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: AppTypography.bodyMedium,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: modalContext,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: selectedDate),
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: AppTypography.bodyMedium,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: modalContext,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime.format(modalContext);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: selectedTime),
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: AppTypography.bodyMedium,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: AppTypography.bodyMedium,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: priorityController,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: AppTypography.bodyMedium,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: AppTypography.bodyMedium,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(modalContext),
                        child: Text('Cancel', style: AppTypography.bodyMedium),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final taskBloc = BlocProvider.of<TaskBloc>(context);
                          taskBloc.add(AddTaskEvent(
                            title: titleController.text,
                            date: selectedDate,
                            time: selectedTime,
                            category: categoryController.text,
                            priority: priorityController.text,
                            description: descriptionController.text,
                          ));
                          Navigator.pop(modalContext);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTaskModal(BuildContext context, Task task, int index) {
    String selectedDate = task.date.toIso8601String().split('T')[0];
    String selectedTime = task.time;
    final titleController = TextEditingController(text: task.title);
    final categoryController = TextEditingController(text: task.category);
    final priorityController = TextEditingController(text: task.priority);
    final descriptionController = TextEditingController(text: task.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Task',
                    style: AppTypography.headlineMedium,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: AppTypography.bodyMedium,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: modalContext,
                        initialDate: task.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: selectedDate),
                        decoration: InputDecoration(
                          labelText: 'Date',
                          labelStyle: AppTypography.bodyMedium,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: modalContext,
                        initialTime: TimeOfDay.fromDateTime(
                          DateTime.parse('2025-01-01 ${task.time}'),
                        ),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime.format(modalContext);
                        });
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(text: selectedTime),
                        decoration: InputDecoration(
                          labelText: 'Time',
                          labelStyle: AppTypography.bodyMedium,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: categoryController,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: AppTypography.bodyMedium,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: priorityController,
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: AppTypography.bodyMedium,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: AppTypography.bodyMedium,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(modalContext),
                        child: Text('Cancel', style: AppTypography.bodyMedium),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final taskBloc = BlocProvider.of<TaskBloc>(context);
                          taskBloc.add(EditTaskEvent(
                            index: index,
                            title: titleController.text,
                            date: selectedDate,
                            time: selectedTime,
                            category: categoryController.text,
                            priority: priorityController.text,
                            description: descriptionController.text,
                          ));
                          Navigator.pop(modalContext);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => TaskBloc()..add(FilterTasksEvent(filterDate: DateTime.now())),
//       child: Scaffold(
//         backgroundColor: AppColors.background,
//         appBar: AppBar(
//           backgroundColor: AppColors.background,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.menu, color: AppColors.text),
//             onPressed: () {},
//           ),
//           actions: [
//             CircleAvatar(
//               radius: 20,
//             ),
//             SizedBox(width: 16),
//           ],
//         ),
//         body: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Tasks', style: AppTypography.headlineMedium),
//                   Builder(
//                     builder: (innerContext) {
//                       final taskBloc = BlocProvider.of<TaskBloc>(innerContext);
//                       return Row(
//                         children: [
//                           Text(
//                             taskBloc.state.filterDate?.toIso8601String().split('T')[0] ?? 'Select Date',
//                             style: AppTypography.bodyMedium,
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.calendar_today, color: AppColors.text),
//                             onPressed: () async {
//                               final pickedDate = await showDatePicker(
//                                 context: innerContext,
//                                 initialDate: taskBloc.state.filterDate ?? DateTime.now(),
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime(2100),
//                               );
//                               if (pickedDate != null) {
//                                 taskBloc.add(FilterTasksEvent(filterDate: pickedDate));
//                               }
//                             },
//                           ),
//                           DropdownButton<bool>(
//                             value: taskBloc.state.showCompleted,
//                             hint: Text('Filter by Completion', style: AppTypography.bodyMedium),
//                             items: [
//                               DropdownMenuItem(value: true, child: Text('Completed', style: AppTypography.bodyMedium)),
//                               DropdownMenuItem(value: false, child: Text('Not Completed', style: AppTypography.bodyMedium)),
//                               DropdownMenuItem(value: null, child: Text('All', style: AppTypography.bodyMedium)),
//                             ],
//                             onChanged: (value) {
//                               taskBloc.add(FilterTasksEvent(showCompleted: value));
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: BlocBuilder<TaskBloc, TaskState>(
//                 builder: (context, state) {
//                   return ListView.builder(
//                     itemCount: state.filteredTasks.length,
//                     itemBuilder: (context, index) {
//                       final task = state.filteredTasks[index];
//                       return ListTile(
//                         leading: Checkbox(
//                           value: task.isCompleted,
//                           onChanged: (value) {
//                             if (value != null) {
//                               context.read<TaskBloc>().add(ToggleTaskCompletionEvent(index));
//                             }
//                           },
//                         ),
//                         title: Text(task.title, style: TextStyle(decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
//                         subtitle: Text('${task.date.toIso8601String().split('T')[0]} ${task.time}'),
//                         onTap: () {
//                           context.read<TaskBloc>().add(ToggleTaskCompletionEvent(index));
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//         bottomNavigationBar: BottomAppBar(
//           color: AppColors.background,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.list, color: AppColors.primary),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.calendar_today, color: AppColors.text),
//                   onPressed: () {},
//                 ),
//                 Builder(
//                   builder: (context) {
//                     return Container(
//                       margin: EdgeInsets.only(bottom: 20),
//                       decoration: BoxDecoration(
//                         color: AppColors.primary,
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         icon: Icon(Icons.add, color: Colors.white),
//                         onPressed: () {
//                           _showAddTaskModal(context);
//                         },
//                       ),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.watch_later, color: AppColors.text),
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.person, color: AppColors.text),
//                   onPressed: () {},
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showAddTaskModal(BuildContext context) {
//     String selectedDate = '';
//     String selectedTime = '';
//     final titleController = TextEditingController();
//     final categoryController = TextEditingController();
//     final priorityController = TextEditingController();
//     final descriptionController = TextEditingController();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.background,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext modalContext) {
//         return StatefulBuilder(
//           builder: (BuildContext modalContext, StateSetter setState) {
//             return Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Add Task',
//                     style: AppTypography.headlineMedium,
//                   ),
//                   SizedBox(height: 16),
//                   // Title Section
//                   TextField(
//                     controller: titleController,
//                     decoration: InputDecoration(
//                       labelText: 'Title',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   // Date Section
//                   GestureDetector(
//                     onTap: () async {
//                       DateTime? pickedDate = await showDatePicker(
//                         context: modalContext,
//                         initialDate: DateTime.now(),
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2100),
//                       );
//                       if (pickedDate != null) {
//                         setState(() {
//                           selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                         });
//                       }
//                     },
//                     child: AbsorbPointer(
//                       child: TextField(
//                         controller: TextEditingController(text: selectedDate),
//                         decoration: InputDecoration(
//                           labelText: 'Date',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   // Time Section
//                   GestureDetector(
//                     onTap: () async {
//                       TimeOfDay? pickedTime = await showTimePicker(
//                         context: modalContext,
//                         initialTime: TimeOfDay.now(),
//                       );
//                       if (pickedTime != null) {
//                         setState(() {
//                           selectedTime = pickedTime.format(modalContext);
//                         });
//                       }
//                     },
//                     child: AbsorbPointer(
//                       child: TextField(
//                         controller: TextEditingController(text: selectedTime),
//                         decoration: InputDecoration(
//                           labelText: 'Time',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   // Category and Priority Row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: categoryController,
//                           decoration: InputDecoration(
//                             labelText: 'Category',
//                             labelStyle: AppTypography.bodyMedium,
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: TextField(
//                           controller: priorityController,
//                           decoration: InputDecoration(
//                             labelText: 'Priority',
//                             labelStyle: AppTypography.bodyMedium,
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   // Description Section
//                   TextField(
//                     controller: descriptionController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       labelText: 'Description',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(modalContext),
//                         child: Text('Cancel', style: AppTypography.bodyMedium),
//                       ),
//                       SizedBox(width: 8),
//                       ElevatedButton(
//                         onPressed: () {
//                           final taskBloc = BlocProvider.of<TaskBloc>(context);
//                           taskBloc.add(AddTaskEvent(
//                             title: titleController.text,
//                             date: selectedDate,
//                             time: selectedTime,
//                             category: categoryController.text,
//                             priority: priorityController.text,
//                             description: descriptionController.text,
//                           ));
//                           Navigator.pop(modalContext);
//                         },
//                         style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                         child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
