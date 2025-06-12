import 'package:equatable/equatable.dart';
import 'package:todolistleap/models/task_model.dart';




class TaskState extends Equatable {
  final List<Task> tasks; // Full list of all tasks
  final List<Task> filteredTasks; // Filtered list for display
  final bool? showCompleted;
  final DateTime? filterDate;

  const TaskState({
    this.tasks = const [],
    this.filteredTasks = const [],
    this.showCompleted,
    this.filterDate,
  });

  TaskState copyWith({
    List<Task>? tasks,
    List<Task>? filteredTasks,
    bool? showCompleted,
    DateTime? filterDate,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      showCompleted: showCompleted ?? this.showCompleted,
      filterDate: filterDate ?? this.filterDate,
    );
  }

  @override
  List<Object?> get props => [tasks, filteredTasks, showCompleted, filterDate];
}