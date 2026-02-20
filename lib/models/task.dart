class Task {
  String title;
  String description;
  DateTime dueDate;
  DateTime createdDate;
  bool isCompleted;

  Task({
    required this.title,
    this.description = '',
    required this.dueDate,
    required this.createdDate,
    this.isCompleted = false,
  });
}
