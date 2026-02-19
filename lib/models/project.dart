class Project {
  final String name;
  final String description;
  final String dueDate;
  final String? memberEmail;
  final String status;
  final int progress;

  Project({
    required this.name,
    required this.description,
    required this.dueDate,
    this.memberEmail,
    this.status = 'Doing',
    this.progress = 0,
  });
}
