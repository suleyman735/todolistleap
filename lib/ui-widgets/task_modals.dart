import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistleap/blocs/task_bloc.dart';
import 'package:todolistleap/blocs/task_event.dart';
import 'package:todolistleap/core/constant/colors.dart';
import 'package:todolistleap/core/constant/typography.dart';
import 'package:todolistleap/models/task_model.dart';







void showAddTaskModal(
    BuildContext context, {
      DateTime? initialDate,
      List<String> categories = const ['University', 'Home', 'Work'],
      String defaultCategory = 'University',
    }) {
  String selectedDate = initialDate != null
      ? "${initialDate.year}-${initialDate.month.toString().padLeft(2, '0')}-${initialDate.day.toString().padLeft(2, '0')}"
      : '';
  String selectedTime = '';
  final titleController = TextEditingController();
  String? selectedCategory = defaultCategory;
  final priorityController = TextEditingController();
  final descriptionController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext modalContext, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Task',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: AppTypography.bodyMedium,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: modalContext,
                      initialDate: initialDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
                      });
                    }
                  },
                  child: TextField(
                    controller: TextEditingController(text: selectedDate),
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: AppTypography.bodyMedium,
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 16),
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
                  child: TextField(
                    controller: TextEditingController(text: selectedTime),
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: AppTypography.bodyMedium,
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: AppTypography.bodyMedium,
                          border: const OutlineInputBorder(),
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: AppTypography.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priorityController,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: AppTypography.bodyMedium,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: AppTypography.bodyMedium,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: Text('Cancel', style: AppTypography.bodyMedium),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final taskBloc = BlocProvider.of<TaskBloc>(context);
                        taskBloc.add(AddTaskEvent(
                          title: titleController.text,
                          date: selectedDate,
                          time: selectedTime,
                          category: selectedCategory ?? defaultCategory,
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

void showEditTaskModal(
    BuildContext context, {
      required Task task,
      required int index,
      List<String> categories = const ['University', 'Home', 'Work'],
      String defaultCategory = 'University',
    }) {
  String selectedDate = task.date.toIso8601String().split('T')[0];
  String selectedTime = task.time;
  final titleController = TextEditingController(text: task.title);
  // Validate task.category against categories list
  String? selectedCategory = categories.contains(task.category) ? task.category : defaultCategory;
  final priorityController = TextEditingController(text: task.priority);
  final descriptionController = TextEditingController(text: task.description);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext modalContext) {
      return StatefulBuilder(
        builder: (BuildContext modalContext, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Task',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: AppTypography.bodyMedium,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
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
                  child: TextField(
                    controller: TextEditingController(text: selectedDate),
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: AppTypography.bodyMedium,
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 16),
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
                  child: TextField(
                    controller: TextEditingController(text: selectedTime),
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: AppTypography.bodyMedium,
                      border: const OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: AppTypography.bodyMedium,
                          border: const OutlineInputBorder(),
                        ),
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: AppTypography.bodyMedium),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: priorityController,
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: AppTypography.bodyMedium,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: AppTypography.bodyMedium,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(modalContext),
                      child: Text('Cancel', style: AppTypography.bodyMedium),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final taskBloc = BlocProvider.of<TaskBloc>(context);
                        taskBloc.add(EditTaskEvent(
                          index: index,
                          title: titleController.text,
                          date: selectedDate,
                          time: selectedTime,
                          category: selectedCategory ?? defaultCategory,
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




//
// void showAddTaskModal(
//     BuildContext context, {
//       DateTime? initialDate,
//       List<String> categories = const ['University', 'Home', 'Work'],
//       String defaultCategory = 'University',
//     }) {
//   String selectedDate = initialDate != null
//       ? "${initialDate.year}-${initialDate.month.toString().padLeft(2, '0')}-${initialDate.day.toString().padLeft(2, '0')}"
//       : '';
//   String selectedTime = '';
//   final titleController = TextEditingController();
//   String? selectedCategory = defaultCategory;
//   final priorityController = TextEditingController();
//   final descriptionController = TextEditingController();
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext modalContext) {
//       return StatefulBuilder(
//         builder: (BuildContext modalContext, StateSetter setState) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Add Task',
//                   style: AppTypography.headlineMedium,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: modalContext,
//                       initialDate: initialDate ?? DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedDate),
//                     decoration: InputDecoration(
//                       labelText: 'Date',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     TimeOfDay? pickedTime = await showTimePicker(
//                       context: modalContext,
//                       initialTime: TimeOfDay.now(),
//                     );
//                     if (pickedTime != null) {
//                       setState(() {
//                         selectedTime = pickedTime.format(modalContext);
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedTime),
//                     decoration: InputDecoration(
//                       labelText: 'Time',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                         items: categories.map((String category) {
//                           return DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(category, style: AppTypography.bodyMedium),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedCategory = newValue;
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: priorityController,
//                         decoration: InputDecoration(
//                           labelText: 'Priority',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: descriptionController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(modalContext),
//                       child: Text('Cancel', style: AppTypography.bodyMedium),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final taskBloc = BlocProvider.of<TaskBloc>(context);
//                         taskBloc.add(AddTaskEvent(
//                           title: titleController.text,
//                           date: selectedDate,
//                           time: selectedTime,
//                           category: selectedCategory ?? defaultCategory,
//                           priority: priorityController.text,
//                           description: descriptionController.text,
//                         ));
//                         Navigator.pop(modalContext);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                       child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
//
// void showEditTaskModal(
//     BuildContext context, {
//       required Task task,
//       required int index,
//       List<String> categories = const ['University', 'Home', 'Work'],
//       String defaultCategory = 'University',
//     }) {
//   String selectedDate = task.date.toIso8601String().split('T')[0];
//   String selectedTime = task.time;
//   final titleController = TextEditingController(text: task.title);
//   // Validate task.category against categories list
//   String? selectedCategory = categories.contains(task.category) ? task.category : defaultCategory;
//   final priorityController = TextEditingController(text: task.priority);
//   final descriptionController = TextEditingController(text: task.description);
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext modalContext) {
//       return StatefulBuilder(
//         builder: (BuildContext modalContext, StateSetter setState) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Edit Task',
//                   style: AppTypography.headlineMedium,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: modalContext,
//                       initialDate: task.date,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedDate),
//                     decoration: InputDecoration(
//                       labelText: 'Date',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     TimeOfDay? pickedTime = await showTimePicker(
//                       context: modalContext,
//                       initialTime: TimeOfDay.fromDateTime(
//                         DateTime.parse('2025-01-01 ${task.time}'),
//                       ),
//                     );
//                     if (pickedTime != null) {
//                       setState(() {
//                         selectedTime = pickedTime.format(modalContext);
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedTime),
//                     decoration: InputDecoration(
//                       labelText: 'Time',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                         items: categories.map((String category) {
//                           return DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(category, style: AppTypography.bodyMedium),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedCategory = newValue;
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: priorityController,
//                         decoration: InputDecoration(
//                           labelText: 'Priority',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: descriptionController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(modalContext),
//                       child: Text('Cancel', style: AppTypography.bodyMedium),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final taskBloc = BlocProvider.of<TaskBloc>(context);
//                         taskBloc.add(EditTaskEvent(
//                           index: index,
//                           title: titleController.text,
//                           date: selectedDate,
//                           time: selectedTime,
//                           category: selectedCategory ?? defaultCategory,
//                           priority: priorityController.text,
//                           description: descriptionController.text,
//                         ));
//                         Navigator.pop(modalContext);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                       child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }


// void showAddTaskModal(
//     BuildContext context, {
//       DateTime? initialDate,
//       List<String> categories = const ['University', 'Home', 'Work'],
//       String defaultCategory = 'University',
//     }) {
//   String selectedDate = initialDate != null
//       ? "${initialDate.year}-${initialDate.month.toString().padLeft(2, '0')}-${initialDate.day.toString().padLeft(2, '0')}"
//       : '';
//   String selectedTime = '';
//   final titleController = TextEditingController();
//   String? selectedCategory = defaultCategory;
//   final priorityController = TextEditingController();
//   final descriptionController = TextEditingController();
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext modalContext) {
//       return StatefulBuilder(
//         builder: (BuildContext modalContext, StateSetter setState) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Add Task',
//                   style: AppTypography.headlineMedium,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: modalContext,
//                       initialDate: initialDate ?? DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedDate),
//                     decoration: InputDecoration(
//                       labelText: 'Date',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     TimeOfDay? pickedTime = await showTimePicker(
//                       context: modalContext,
//                       initialTime: TimeOfDay.now(),
//                     );
//                     if (pickedTime != null) {
//                       setState(() {
//                         selectedTime = pickedTime.format(modalContext);
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedTime),
//                     decoration: InputDecoration(
//                       labelText: 'Time',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                         items: categories.map((String category) {
//                           return DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(category, style: AppTypography.bodyMedium),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedCategory = newValue;
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: priorityController,
//                         decoration: InputDecoration(
//                           labelText: 'Priority',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: descriptionController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(modalContext),
//                       child: Text('Cancel', style: AppTypography.bodyMedium),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final taskBloc = BlocProvider.of<TaskBloc>(context);
//                         taskBloc.add(AddTaskEvent(
//                           title: titleController.text,
//                           date: selectedDate,
//                           time: selectedTime,
//                           category: selectedCategory ?? defaultCategory,
//                           priority: priorityController.text,
//                           description: descriptionController.text,
//                         ));
//                         Navigator.pop(modalContext);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                       child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
//
// void showEditTaskModal(
//     BuildContext context, {
//       required Task task,
//       required int index,
//       List<String> categories = const ['University', 'Home', 'Work'],
//       String defaultCategory = 'University',
//     }) {
//   String selectedDate = task.date.toIso8601String().split('T')[0];
//   String selectedTime = task.time;
//   final titleController = TextEditingController(text: task.title);
//   String? selectedCategory = task.category.isNotEmpty ? task.category : defaultCategory;
//   final priorityController = TextEditingController(text: task.priority);
//   final descriptionController = TextEditingController(text: task.description);
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext modalContext) {
//       return StatefulBuilder(
//         builder: (BuildContext modalContext, StateSetter setState) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Edit Task',
//                   style: AppTypography.headlineMedium,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: modalContext,
//                       initialDate: task.date,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedDate),
//                     decoration: InputDecoration(
//                       labelText: 'Date',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     TimeOfDay? pickedTime = await showTimePicker(
//                       context: modalContext,
//                       initialTime: TimeOfDay.fromDateTime(
//                         DateTime.parse('2025-01-01 ${task.time}'),
//                       ),
//                     );
//                     if (pickedTime != null) {
//                       setState(() {
//                         selectedTime = pickedTime.format(modalContext);
//                       });
//                     }
//                   },
//                   child: TextField(
//                     controller: TextEditingController(text: selectedTime),
//                     decoration: InputDecoration(
//                       labelText: 'Time',
//                       labelStyle: AppTypography.bodyMedium,
//                       border: const OutlineInputBorder(),
//                     ),
//                     readOnly: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<String>(
//                         value: selectedCategory,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                         items: categories.map((String category) {
//                           return DropdownMenuItem<String>(
//                             value: category,
//                             child: Text(category, style: AppTypography.bodyMedium),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           setState(() {
//                             selectedCategory = newValue;
//                           });
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: priorityController,
//                         decoration: InputDecoration(
//                           labelText: 'Priority',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: descriptionController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(modalContext),
//                       child: Text('Cancel', style: AppTypography.bodyMedium),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final taskBloc = BlocProvider.of<TaskBloc>(context);
//                         taskBloc.add(EditTaskEvent(
//                           index: index,
//                           title: titleController.text,
//                           date: selectedDate,
//                           time: selectedTime,
//                           category: selectedCategory ?? defaultCategory,
//                           priority: priorityController.text,
//                           description: descriptionController.text,
//                         ));
//                         Navigator.pop(modalContext);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                       child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }


// void showAddTaskModal(BuildContext context) {
//   String selectedDate = '';
//   String selectedTime = '';
//   final titleController = TextEditingController();
//   final categoryController = TextEditingController();
//   final priorityController = TextEditingController();
//   final descriptionController = TextEditingController();
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext modalContext) {
//       return StatefulBuilder(
//         builder: (BuildContext modalContext, StateSetter setState) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Add Task',
//                   style: AppTypography.headlineMedium,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: modalContext,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                       });
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: TextField(
//                       controller: TextEditingController(text: selectedDate),
//                       decoration: InputDecoration(
//                         labelText: 'Date',
//                         labelStyle: AppTypography.bodyMedium,
//                         border: const OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     TimeOfDay? pickedTime = await showTimePicker(
//                       context: modalContext,
//                       initialTime: TimeOfDay.now(),
//                     );
//                     if (pickedTime != null) {
//                       setState(() {
//                         selectedTime = pickedTime.format(modalContext);
//                       });
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: TextField(
//                       controller: TextEditingController(text: selectedTime),
//                       decoration: InputDecoration(
//                         labelText: 'Time',
//                         labelStyle: AppTypography.bodyMedium,
//                         border: const OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: categoryController,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: priorityController,
//                         decoration: InputDecoration(
//                           labelText: 'Priority',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: descriptionController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(modalContext),
//                       child: Text('Cancel', style: AppTypography.bodyMedium),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final taskBloc = BlocProvider.of<TaskBloc>(context);
//                         taskBloc.add(AddTaskEvent(
//                           title: titleController.text,
//                           date: selectedDate,
//                           time: selectedTime,
//                           category: categoryController.text,
//                           priority: priorityController.text,
//                           description: descriptionController.text,
//                         ));
//                         Navigator.pop(modalContext);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                       child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }
//
// void showEditTaskModal(BuildContext context, Task task, int index) {
//   String selectedDate = task.date.toIso8601String().split('T')[0];
//   String selectedTime = task.time;
//   final titleController = TextEditingController(text: task.title);
//   final categoryController = TextEditingController(text: task.category);
//   final priorityController = TextEditingController(text: task.priority);
//   final descriptionController = TextEditingController(text: task.description);
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: AppColors.background,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext modalContext) {
//       return StatefulBuilder(
//         builder: (BuildContext modalContext, StateSetter setState) {
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Edit Task',
//                   style: AppTypography.headlineMedium,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: titleController,
//                   decoration: InputDecoration(
//                     labelText: 'Title',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: modalContext,
//                       initialDate: task.date,
//                       firstDate: DateTime(2000),
//                       lastDate: DateTime(2100),
//                     );
//                     if (pickedDate != null) {
//                       setState(() {
//                         selectedDate = "${pickedDate.toLocal()}".split(' ')[0];
//                       });
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: TextField(
//                       controller: TextEditingController(text: selectedDate),
//                       decoration: InputDecoration(
//                         labelText: 'Date',
//                         labelStyle: AppTypography.bodyMedium,
//                         border: const OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () async {
//                     TimeOfDay? pickedTime = await showTimePicker(
//                       context: modalContext,
//                       initialTime: TimeOfDay.fromDateTime(
//                         DateTime.parse('2025-01-01 ${task.time}'),
//                       ),
//                     );
//                     if (pickedTime != null) {
//                       setState(() {
//                         selectedTime = pickedTime.format(modalContext);
//                       });
//                     }
//                   },
//                   child: AbsorbPointer(
//                     child: TextField(
//                       controller: TextEditingController(text: selectedTime),
//                       decoration: InputDecoration(
//                         labelText: 'Time',
//                         labelStyle: AppTypography.bodyMedium,
//                         border: const OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: categoryController,
//                         decoration: InputDecoration(
//                           labelText: 'Category',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: TextField(
//                         controller: priorityController,
//                         decoration: InputDecoration(
//                           labelText: 'Priority',
//                           labelStyle: AppTypography.bodyMedium,
//                           border: const OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: descriptionController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: 'Description',
//                     labelStyle: AppTypography.bodyMedium,
//                     border: const OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(modalContext),
//                       child: Text('Cancel', style: AppTypography.bodyMedium),
//                     ),
//                     const SizedBox(width: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         final taskBloc = BlocProvider.of<TaskBloc>(context);
//                         taskBloc.add(EditTaskEvent(
//                           index: index,
//                           title: titleController.text,
//                           date: selectedDate,
//                           time: selectedTime,
//                           category: categoryController.text,
//                           priority: priorityController.text,
//                           description: descriptionController.text,
//                         ));
//                         Navigator.pop(modalContext);
//                       },
//                       style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
//                       child: Text('Save', style: AppTypography.bodyMedium.copyWith(color: Colors.white)),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           );
//         },
//       );
//     },
//   );
// }