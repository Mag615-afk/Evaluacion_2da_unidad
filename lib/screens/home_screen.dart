import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/tarea.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Tarea> _tareas = [];
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  // LEER (GET) - Obtener tareas al iniciar
  void _cargarTareas() async {
    setState(() {
      _cargando = true;
      _error = '';
    });
    
    try {
      final tareas = await _databaseHelper.getTareas();
      setState(() {
        _tareas = tareas;
      });
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
      });
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  // CREAR (POST) - Agregar nueva tarea
  void _crearTarea(String descripcion) async {
    setState(() {
      _error = '';
    });

    try {
      await _databaseHelper.createTarea(descripcion, false);
      _cargarTareas();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea creada exitosamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
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

  // ACTUALIZAR (PUT) - Cambiar estado completado/pendiente
  void _alternarEstadoTarea(Tarea tarea) async {
    try {
      final tareaActualizada = tarea.copyWith(completed: !tarea.completed);
      await _databaseHelper.updateTarea(tareaActualizada);
      _cargarTareas();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tarea ${tareaActualizada.completed ? 'completada' : 'marcada como pendiente'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar tarea: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _cargarTareas();
    }
  }

  // ELIMINAR (DELETE) - Borrar tarea con confirmación
  void _eliminarTarea(Tarea tarea) async {
    final confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar la tarea "${tarea.todo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final success = await _databaseHelper.deleteTarea(tarea.id);
        if (success) {
          _cargarTareas();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tarea eliminada exitosamente'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrador de Tareas'),
        backgroundColor: Color(0xFF6A0DAD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _cargarTareas,
            tooltip: 'Recargar tareas',
          ),
        ],
      ),
      body: _cargando
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
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoCrearTarea,
        backgroundColor: Color(0xFF6A0DAD),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}