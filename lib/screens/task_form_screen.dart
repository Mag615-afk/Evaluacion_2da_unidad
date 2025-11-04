// Importaciones necesarias para el manejo de la interfaz y base de datos
import 'package:flutter/material.dart';
import '../services/database_helper.dart';

// Pantalla para crear una nueva tarea manualmente mediante un formulario
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({Key? key}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

// Estado del formulario que permite gestionar la creación de tareas
class _TaskFormScreenState extends State<TaskFormScreen> {
  // Clave global para identificar y validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controlador del campo de texto donde se escribe la tarea
  final _tareaController = TextEditingController();

  // Instancia del helper que gestiona las operaciones con la base de datos
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Variable que indica si la tarea está siendo procesada (creándose)
  bool _isLoading = false;

  // 🔹 Función principal para crear una tarea en la base de datos
  Future<void> _crearTarea() async {
    // Verifica si el formulario pasó la validación
    if (_formKey.currentState!.validate()) {
      // Activa el indicador de carga
      setState(() {
        _isLoading = true;
      });

      try {
        // Llama al método que crea la tarea en la base de datos local
        await _databaseHelper.createTarea(_tareaController.text, false);
        
        // Si el widget sigue activo, muestra mensaje de éxito y regresa a la pantalla anterior
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Cierra la pantalla actual
        }
      } catch (e) {
        // Muestra un mensaje de error si algo falla al crear la tarea
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear tarea: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        // Desactiva el indicador de carga
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estructura visual principal del formulario
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Tarea'),
        // Botón para regresar a la pantalla anterior (desactivado si está cargando)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      // Cuerpo del formulario con padding y validaciones
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Vincula la clave del formulario
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Descripción de la tarea',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Campo de texto para ingresar la descripción de la tarea
              TextFormField(
                controller: _tareaController,
                decoration: const InputDecoration(
                  hintText: 'Ej: Estudiar Flutter, Hacer ejercicio...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                // Validaciones del campo (no vacío, longitud mínima)
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción de la tarea';
                  }
                  if (value.length < 3) {
                    return 'La tarea debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Botón para enviar el formulario y crear la tarea
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    // Si está cargando, muestra un círculo de progreso
                    ? const Center(child: CircularProgressIndicator())
                    // Si no, muestra el botón normal
                    : ElevatedButton(
                        onPressed: _crearTarea,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                        ),
                        child: const Text(
                          'Crear Tarea',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Libera los recursos del controlador cuando se destruye el widget
  @override
  void dispose() {
    _tareaController.dispose();
    super.dispose();
  }
}
