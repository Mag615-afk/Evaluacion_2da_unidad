// Clase que representa una Tarea individual dentro del sistema.
class Tarea { 
  // Identificador único de la tarea
  final int id;
  // Descripción o contenido de la tarea
  final String todo;
  // Indica si la tarea está completada (true) o no (false)
  final bool completed;
  // Identificador del usuario al que pertenece la tarea
  final int userId;

  // Constructor principal de la clase, con parámetros requeridos
  Tarea({
    required this.id,
    required this.todo,
    required this.completed,
    required this.userId,
  });

  // Constructor de tipo fábrica que permite crear una instancia
  // de la clase a partir de un mapa JSON (por ejemplo, una respuesta de una API)
  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] ?? 0,                 // Si no viene el id, se asigna 0
      todo: json['todo'] ?? '',            // Si no hay descripción, queda vacío
      completed: json['completed'] ?? false, // Si no viene el valor, se asume no completado
      userId: json['userId'] ?? 0,         // Si no se indica usuario, se asigna 0
    );
  }

  // Convierte la instancia actual de Tarea en un mapa JSON
  // Esto sirve para enviar la información a una API o guardarla en local
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  // Método que permite crear una copia de la tarea actual
  // cambiando solo los valores que se indiquen (los demás se mantienen iguales)
  Tarea copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
  }) {
    return Tarea(
      id: id ?? this.id,                   // Si no se pasa un nuevo id, se mantiene el actual
      todo: todo ?? this.todo,             // Igual con la descripción
      completed: completed ?? this.completed, // Mantiene el estado si no se cambia
      userId: userId ?? this.userId,       // Mantiene el mismo usuario si no se pasa otro
    );
  }
}
