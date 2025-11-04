class Tarea {
  final int id;
  final String todo;
  final bool completed;
  final int userId;

  Tarea({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] ?? 0,
      todo: json['todo'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  Tarea copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
  }) {
    return Tarea(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }
}