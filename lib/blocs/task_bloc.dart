import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistleap/core/database_helper.dart';
import 'package:todolistleap/models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

import 'package:bloc/bloc.dart';



class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  TaskBloc() : super(TaskState()) {
    on<AddTaskEvent>(_onAddTask);
    on<EditTaskEvent>(_onEditTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<FilterTasksEvent>(_onFilterTasks);
    _loadTasks(); // Load tasks on initialization
  }

  Future<void> _loadTasks() async {
    try {
      print('Loading tasks...');
      final tasks = await _dbHelper.getTasks();
      print('Loaded tasks: ${tasks.map((t) => t.title).toList()}');
      emit(state.copyWith(tasks: tasks, filteredTasks: tasks));
    } catch (e) {
      print('Error loading tasks: $e');
      emit(state); // Emit current state on error
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      print('Adding task: ${event.title}');
      final task = Task.fromStringDate(
        id: null, // Pass null to let SQLite auto-increment
        title: event.title,
        dateStr: event.date,
        time: event.time,
        category: event.category,
        priority: event.priority,
        description: event.description,
        isCompleted: false,
      );
      final id = await _dbHelper.insertTask(task);
      final updatedTask = task.copyWith(id: id); // Update with the generated id
      final updatedTasks = List<Task>.from(state.tasks)..add(updatedTask);
      emit(_applyFilters(state.copyWith(tasks: updatedTasks, filteredTasks: updatedTasks)));
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  Future<void> _onEditTask(EditTaskEvent event, Emitter<TaskState> emit) async {
    try {
      print('Editing task at index: ${event.index}');
      final updatedTasks = List<Task>.from(state.tasks);
      if (event.index >= 0 && event.index < updatedTasks.length) {
        final task = Task.fromStringDate(
          id: updatedTasks[event.index].id, // Use existing id
          title: event.title,
          dateStr: event.date,
          time: event.time,
          category: event.category,
          priority: event.priority,
          description: event.description,
          isCompleted: updatedTasks[event.index].isCompleted,
        );
        await _dbHelper.updateTask(task);
        updatedTasks[event.index] = task;
        emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      }
    } catch (e) {
      print('Error editing task: $e');
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      print('Deleting task at index: ${event.index}');
      final updatedTasks = List<Task>.from(state.tasks);
      if (event.index >= 0 && event.index < updatedTasks.length) {
        await _dbHelper.deleteTask(updatedTasks[event.index].id);
        updatedTasks.removeAt(event.index);
        emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> _onToggleTaskCompletion(ToggleTaskCompletionEvent event, Emitter<TaskState> emit) async {
    try {
      print('Toggling completion for task at index: ${event.index}');
      final updatedTasks = List<Task>.from(state.tasks);
      if (event.index >= 0 && event.index < updatedTasks.length) {
        final updatedTask = updatedTasks[event.index].copyWith(isCompleted: !updatedTasks[event.index].isCompleted);
        await _dbHelper.updateTask(updatedTask);
        updatedTasks[event.index] = updatedTask;
        emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      }
    } catch (e) {
      print('Error toggling task completion: $e');
    }
  }

  void _onFilterTasks(FilterTasksEvent event, Emitter<TaskState> emit) {
    try {
      print('Filtering tasks with date: ${event.filterDate}, completed: ${event.showCompleted}');
      final newState = state.copyWith(
        showCompleted: event.showCompleted,
        filterDate: event.filterDate,
      );
      final filteredState = _applyFilters(newState);
      print('Filtered tasks: ${filteredState.filteredTasks.map((t) => t.title).toList()}');
      emit(filteredState);
    } catch (e) {
      print('Error filtering tasks: $e');
    }
  }

  TaskState _applyFilters(TaskState state) {
    List<Task> filteredTasks = List<Task>.from(state.tasks); // Create a fresh copy
    print('Applying filters: filterDate=${state.filterDate}, showCompleted=${state.showCompleted}');
    print('Initial task count: ${filteredTasks.length}');

    if (state.filterDate != null) {
      filteredTasks = filteredTasks.where((task) {
        final matchesDate = task.date.year == state.filterDate!.year &&
            task.date.month == state.filterDate!.month &&
            task.date.day == state.filterDate!.day;
        print('Task ${task.title} date match: $matchesDate');
        return matchesDate;
      }).toList();
      print('After date filter: ${filteredTasks.length} tasks');
    }

    if (state.showCompleted != null) {
      filteredTasks = filteredTasks.where((task) {
        final matchesCompletion = task.isCompleted == state.showCompleted;
        print('Task ${task.title} completion match: $matchesCompletion');
        return matchesCompletion;
      }).toList();
      print('After completion filter: ${filteredTasks.length} tasks');
    }

    return state.copyWith(filteredTasks: filteredTasks);
  }
}


// class TaskBloc extends Bloc<TaskEvent, TaskState> {
//   final DatabaseHelper _dbHelper = DatabaseHelper.instance;
//
//   TaskBloc() : super(TaskState()) {
//     on<AddTaskEvent>(_onAddTask);
//     on<EditTaskEvent>(_onEditTask);
//     on<DeleteTaskEvent>(_onDeleteTask);
//     on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
//     on<FilterTasksEvent>(_onFilterTasks);
//     _loadTasks(); // Load tasks on initialization
//   }
//
//   Future<void> _loadTasks() async {
//     try {
//       print('Loading tasks...');
//       final tasks = await _dbHelper.getTasks();
//       print('Loaded tasks: ${tasks.map((t) => t.title)}');
//       emit(state.copyWith(tasks: tasks, filteredTasks: tasks));
//     } catch (e) {
//       print('Error loading tasks: $e');
//       emit(state); // Emit current state on error
//     }
//   }
//
//   Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
//     try {
//       print('Adding task: ${event.title}');
//       final task = Task.fromStringDate(
//         id: null, // Pass null to let SQLite auto-increment
//         title: event.title,
//         dateStr: event.date,
//         time: event.time,
//         category: event.category,
//         priority: event.priority,
//         description: event.description,
//         isCompleted: false,
//       );
//       final id = await _dbHelper.insertTask(task);
//       final updatedTask = task.copyWith(id: id); // Update with the generated id
//       final updatedTasks = List<Task>.from(state.tasks)..add(updatedTask);
//       emit(_applyFilters(state.copyWith(tasks: updatedTasks, filteredTasks: updatedTasks)));
//     } catch (e) {
//       print('Error adding task: $e');
//     }
//   }
//
//   Future<void> _onEditTask(EditTaskEvent event, Emitter<TaskState> emit) async {
//     try {
//       print('Editing task at index: ${event.index}');
//       final updatedTasks = List<Task>.from(state.tasks);
//       if (event.index >= 0 && event.index < updatedTasks.length) {
//         final task = Task.fromStringDate(
//           id: updatedTasks[event.index].id, // Use existing id
//           title: event.title,
//           dateStr: event.date,
//           time: event.time,
//           category: event.category,
//           priority: event.priority,
//           description: event.description,
//           isCompleted: updatedTasks[event.index].isCompleted,
//         );
//         await _dbHelper.updateTask(task);
//         updatedTasks[event.index] = task;
//         emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
//       }
//     } catch (e) {
//       print('Error editing task: $e');
//     }
//   }
//
//   Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
//     try {
//       print('Deleting task at index: ${event.index}');
//       final updatedTasks = List<Task>.from(state.tasks);
//       if (event.index >= 0 && event.index < updatedTasks.length) {
//         await _dbHelper.deleteTask(updatedTasks[event.index].id);
//         updatedTasks.removeAt(event.index);
//         emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
//       }
//     } catch (e) {
//       print('Error deleting task: $e');
//     }
//   }
//
//   Future<void> _onToggleTaskCompletion(ToggleTaskCompletionEvent event, Emitter<TaskState> emit) async {
//     try {
//       print('Toggling completion for task at index: ${event.index}');
//       final updatedTasks = List<Task>.from(state.tasks);
//       if (event.index >= 0 && event.index < updatedTasks.length) {
//         final updatedTask = updatedTasks[event.index].copyWith(isCompleted: !updatedTasks[event.index].isCompleted);
//         await _dbHelper.updateTask(updatedTask);
//         updatedTasks[event.index] = updatedTask;
//         emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
//       }
//     } catch (e) {
//       print('Error toggling task completion: $e');
//     }
//   }
//
//   void _onFilterTasks(FilterTasksEvent event, Emitter<TaskState> emit) {
//     try {
//       print('Filtering tasks with date: ${event.filterDate}, completed: ${event.showCompleted}');
//       final newState = _applyFilters(state.copyWith(
//         showCompleted: event.showCompleted,
//         filterDate: event.filterDate,
//       ));
//       emit(newState);
//     } catch (e) {
//       print('Error filtering tasks: $e');
//     }
//   }
//
//   TaskState _applyFilters(TaskState state) {
//     List<Task> filteredTasks = List<Task>.from(state.tasks);
//     if (state.filterDate != null) {
//       filteredTasks = filteredTasks.where((task) {
//         return task.date.year == state.filterDate!.year &&
//             task.date.month == state.filterDate!.month &&
//             task.date.day == state.filterDate!.day;
//       }).toList();
//     }
//     if (state.showCompleted != null) {
//       filteredTasks = filteredTasks.where((task) => task.isCompleted == state.showCompleted).toList();
//     }
//     return state.copyWith(filteredTasks: filteredTasks);
//   }
// }



