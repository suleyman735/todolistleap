abstract class TaskEvent {}

class AddTaskEvent extends TaskEvent {
  final String title;
  final String date;
  final String time;
  final String category;
  final String priority;
  final String description;

  AddTaskEvent({
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
    required this.description,
  });
}
class EditTaskEvent extends TaskEvent {
  final int index;
  final String title;
  final String date;
  final String time;
  final String category;
  final String priority;
  final String description;

  EditTaskEvent({
    required this.index,
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
    required this.description,
  });
}

class DeleteTaskEvent extends TaskEvent {
  final int index;

  DeleteTaskEvent(this.index);
}

class ToggleTaskCompletionEvent extends TaskEvent {
  final int index;

  ToggleTaskCompletionEvent(this.index);
}

class FilterTasksEvent extends TaskEvent {
  final bool? showCompleted;
  final DateTime? filterDate;

  FilterTasksEvent({this.showCompleted, this.filterDate});
}

