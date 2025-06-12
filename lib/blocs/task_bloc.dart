import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todolistleap/models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';


class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskState()) {
    on<AddTaskEvent>((event, emit) {
      final updatedTasks = List<Task>.from(state.tasks)
        ..add(Task.fromStringDate(
          title: event.title,
          dateStr: event.date,
          time: event.time,
          category: event.category,
          priority: event.priority,
          description: event.description,
        ));
      // emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      emit(state.copyWith(tasks: updatedTasks, filteredTasks: updatedTasks)); // Update both lists
    });

    on<EditTaskEvent>((event, emit) {
      final updatedTasks = List<Task>.from(state.tasks);
      if (event.index >= 0 && event.index < updatedTasks.length) {
        updatedTasks[event.index] = Task.fromStringDate(
          title: event.title,
          dateStr: event.date,
          time: event.time,
          category: event.category,
          priority: event.priority,
          description: event.description,
          isCompleted: updatedTasks[event.index].isCompleted,
        );
        emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      }
    });

    on<DeleteTaskEvent>((event, emit) {
      final updatedTasks = List<Task>.from(state.tasks);
      if (event.index >= 0 && event.index < updatedTasks.length) {
        updatedTasks.removeAt(event.index);
        emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      }
    });

    on<ToggleTaskCompletionEvent>((event, emit) {
      final updatedTasks = List<Task>.from(state.tasks);
      if (event.index >= 0 && event.index < updatedTasks.length) {
        updatedTasks[event.index] = updatedTasks[event.index].copyWith(isCompleted: !updatedTasks[event.index].isCompleted);
        // Re-filter to update filteredTasks
        // emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
        emit(_applyFilters(state.copyWith(tasks: updatedTasks)));
      }
    });

    on<FilterTasksEvent>((event, emit) {
      final newState = _applyFilters(state.copyWith(
        showCompleted: event.showCompleted,
        filterDate: event.filterDate,
      ));
      emit(newState);
    });
  }

  TaskState _applyFilters(TaskState state) {
    List<Task> filteredTasks = List<Task>.from(state.tasks);
    if (state.showCompleted != null) {
      filteredTasks = filteredTasks.where((task) => task.isCompleted == state.showCompleted).toList();
    }
    if (state.filterDate != null) {
      filteredTasks = filteredTasks.where((task) {
        return task.date.year == state.filterDate!.year &&
            task.date.month == state.filterDate!.month &&
            task.date.day == state.filterDate!.day;
      }).toList();
    }
    return state.copyWith(filteredTasks: filteredTasks);
  }
}

// Extension for Task to create a copyWith method
extension TaskExtension on Task {
  Task copyWith({bool? isCompleted}) {
    return Task(
      title: title,
      date: date,
      time: time,
      category: category,
      priority: priority,
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}