class Task {
  final int id; // Added for SQLite primary key
  final String title;
  final DateTime date;
  final String time;
  final String category;
  final String priority;
  final String description;
  final bool isCompleted;


  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
    required this.description,
    required this.isCompleted,
  });

  // Convert string date to DateTime for filtering, id is optional
  factory Task.fromStringDate({
    int? id, // Make id optional
    required String title,
    required String dateStr,
    required String time,
    required String category,
    required String priority,
    required String description,
    required bool isCompleted,
  }) {
    final dateParts = dateStr.split('-');
    return Task(
      id: id ?? 0, // Default to 0 if not provided, but will be overridden by database
      title: title,
      date: DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])),
      time: time,
      category: category,
      priority: priority,
      description: description,
      isCompleted: isCompleted,
    );
  }

  // Convert database map to Task
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      category: map['category'],
      priority: map['priority'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  // Convert Task to map for database insertion/update
  Map<String, dynamic> toMap() {
    return {
      'id': id == 0 ? null : id, // Set id to null if 0, letting SQLite auto-increment
      'title': title,
      'date': date.toIso8601String().split('T')[0],
      'time': time,
      'category': category,
      'priority': priority,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }
}

// Extension for Task to create a copyWith method
extension TaskExtension on Task {
  Task copyWith({int? id, bool? isCompleted}) {
    return Task(
      id: id ?? this.id,
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
