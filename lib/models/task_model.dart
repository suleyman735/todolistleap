class Task {
  final String title;
  final DateTime date;
  final String time;
  final String category;
  final String priority;
  final String description;
  bool isCompleted;

  Task({
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
    required this.description,
    this.isCompleted = false,
  });

  // Convert string date to DateTime for filtering
  factory Task.fromStringDate({
    required String title,
    required String dateStr,
    required String time,
    required String category,
    required String priority,
    required String description,
    bool isCompleted = false,
  }) {
    final dateParts = dateStr.split('-');
    return Task(
      title: title,
      date: DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])),
      time: time,
      category: category,
      priority: priority,
      description: description,
      isCompleted: isCompleted,
    );
  }
}