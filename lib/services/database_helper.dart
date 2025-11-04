import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tarea.dart';

class DatabaseHelper {
  static const String baseUrl = 'https://dummyjson.com/todos';
  
  // GET - Obtener todas las tareas desde la API
  Future<List<Tarea>> getTareas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?limit=10'));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> todos = data['todos'];
        
        return todos.map((json) => Tarea.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar tareas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // POST - Crear nueva tarea en la API
  Future<Tarea> createTarea(String todo, bool completed) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'todo': todo,
          'completed': completed,
          'userId': 1,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Tarea.fromJson(data);
      } else {
        throw Exception('Error al crear tarea: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PUT - Actualizar tarea en la API
  Future<Tarea> updateTarea(Tarea tarea) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/${tarea.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'completed': tarea.completed,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Tarea.fromJson(data);
      } else {
        throw Exception('Error al actualizar tarea: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // DELETE - Eliminar tarea de la API
  Future<bool> deleteTarea(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Error al eliminar tarea: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}