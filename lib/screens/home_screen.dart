// Importaciones necesarias para el funcionamiento del widget y conexión con la base de datos
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/tarea.dart';

// Pantalla principal de la aplicación donde se gestionan las tareas
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Estado asociado a la pantalla principal
class _HomeScreenState extends State<HomeScreen> {
  // Instancia del helper que maneja las operaciones con la base de datos
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Lista donde se almacenarán las tareas cargadas desde la base de datos
  List<Tarea> _tareas = [];

  // Variables para manejar el estado de carga y posibles errores
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Se ejecuta al iniciar la pantalla y carga las tareas guardadas
    _cargarTareas();
  }

  // 🔹 LEER (GET) - Obtener tareas al iniciar la aplicación
  void _cargarTareas() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    
    try {
      // Se obtienen las tareas desde la base de datos
      final tareas = await _databaseHelper.getTareas();
      setState(() {
        _tareas = tareas;
      });
    } catch (e) {
      // Si ocurre un error de conexión o lectura, se guarda el mensaje
      setState(() {
        _error = 'Error de conexión: $e';
      });
    } finally {
      // Se desactiva el estado de carga al finalizar la operación
      setState(() {
        _cargando = false;
      });
    }
  }

  // 🔹 CREAR (POST) - Agregar una nueva tarea a la base de datos
  void _crearTarea(String descripcion) async {
    setState(() {
      _error = '';
    });

    try {
      // Crea una nueva tarea en la base de datos
      await _databaseHelper.createTarea(descripcion, false);
      // Recarga la lista de tareas
      _cargarTareas();
      
      // Mensaje de confirmación visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea creada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // En caso de error, muestra un mensaje rojo
      setState(() {
        _error = 'Error al crear tarea: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear tarea: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 🔹 ACTUALIZAR (PUT) - Cambia el estado de una tarea (completada o pendiente)
  void _alternarEstadoTarea(Tarea tarea) async {
    try {
      // Crea una copia de la tarea actual con el estado invertido
      final tareaActualizada = tarea.copyWith(completed: !tarea.completed);
      await _databaseHelper.updateTarea(tareaActualizada);
      _cargarTareas();
      
      // Notificación de actualización
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea ${tareaActualizada.completed ? 'completada' : 'marcada como pendiente'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // En caso de error, muestra un mensaje y recarga las tareas
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar tarea: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _cargarTareas();
    }
  }

  // 🔹 ELIMINAR (DELETE) - Elimina una tarea después de confirmar con el usuario
  void _eliminarTarea(Tarea tarea) async {
    // Muestra un diálogo de confirmación antes de eliminar
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar la tarea "${tarea.todo}"?'),
        actions: [
          // Botón para cancelar la eliminación
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          // Botón para confirmar la eliminación
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    // Si el usuario confirma la eliminación
    if (confirmar == true) {
      try {
        // Se elimina la tarea de la base de datos
        final success = await _databaseHelper.deleteTarea(tarea.id);
        if (success) {
          _cargarTareas();
          
          // Muestra mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tarea eliminada exitosamente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Muestra mensaje de error si la operación falla
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar tarea: $e'),
            backgroundColor: Colors.red,
          ),
        );
        _cargarTareas();
      }
    }
  }

  // 🔹 Muestra un cuadro de diálogo para escribir y crear una nueva tarea
  void _mostrarDialogoCrearTarea() {
    final TextEditingController controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Nueva Tarea',
            style: TextStyle(color: Color(0xFF6A0DAD)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Descripción de la tarea'),
              SizedBox(height: 10),
              // Campo de texto para escribir la descripción
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Escribe tu tarea aquí...',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF6A0DAD)),
                  ),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            // Botón para cancelar la creación
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            // Botón para confirmar y crear la tarea
            ElevatedButton(
              onPressed: () {
                final descripcion = controller.text.trim();
                if (descripcion.isNotEmpty) {
                  _crearTarea(descripcion);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6A0DAD),
              ),
              child: Text('Crear Tarea'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Estructura visual principal de la pantalla
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrador de Tareas'),
        backgroundColor: Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
        actions: [
          // Botón para recargar manualmente las tareas
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarTareas,
            tooltip: 'Recargar tareas',
          ),
        ],
      ),
      // Cuerpo de la pantalla que cambia según el estado de la app
      body: _cargando
          // Muestra un indicador de carga mientras se obtienen los datos
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF6A0DAD)),
                  SizedBox(height: 20),
                  Text('Cargando tareas...'),
                ],
              ),
            )
          // Si hay error, muestra un mensaje de error con opción a reintentar
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red),
                      SizedBox(height: 20),
                      Text(
                        'Error de conexión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _cargarTareas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6A0DAD),
                        ),
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              // Si no hay tareas registradas, muestra un mensaje amigable
              : _tareas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_outlined, size: 80, color: Color(0xFF9D4EDD)),
                          SizedBox(height: 20),
                          Text(
                            'No hay tareas registradas',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6A0DAD),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Presiona el botón + para agregar una',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  // Si hay tareas, las lista en tarjetas individuales
                  : ListView.builder(
                      itemCount: _tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = _tareas[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completed,
                              onChanged: (value) {
                                _alternarEstadoTarea(tarea);
                              },
                              activeColor: Color(0xFF6A0DAD),
                            ),
                            title: Text(
                              tarea.todo,
                              style: TextStyle(
                                fontSize: 16,
                                color: tarea.completed ? Colors.grey : Color(0xFF1A1A1A),
                                decoration: tarea.completed ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _eliminarTarea(tarea),
                            ),
                          ),
                        );
                      },
                    ),
      // Botón flotante para crear nuevas tareas
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrearTarea,
        backgroundColor: Color(0xFF6A0DAD),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
