import 'package:flutter/material.dart'; 
import 'screens/home_screen.dart';

// Punto de entrada principal de la aplicación.
// La función main() ejecuta la app llamando a runApp(), que carga el widget raíz de la aplicación.
void main() {
  runApp(const MyApp());
}

// MyApp es el widget principal (raíz) de la aplicación.
// Es un StatelessWidget porque no necesita manejar estados internos.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // El método build construye la interfaz visual de la aplicación.
  // Devuelve un MaterialApp, que configura el diseño, tema y pantalla inicial.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título general de la aplicación, visible en algunas plataformas.
      title: 'Administrador de Tareas',

      // Configuración del tema visual de la app.
      theme: ThemeData(
        // Color principal (predominante) del tema.
        primaryColor: const Color(0xFF6A0DAD),

        // Esquema de colores principal para los diferentes elementos del Material Design.
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF6A0DAD), // Color principal para botones, AppBar, etc.
          background: Colors.white, // Color de fondo general.
        ),

        // Estilo personalizado del AppBar (barra superior de la aplicación).
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6A0DAD), // Fondo del AppBar.
          foregroundColor: Colors.white, // Color del texto e iconos del AppBar.
        ),

        // Configuración del botón flotante (FAB) usado en la interfaz.
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6A0DAD), // Color del botón flotante.
        ),

        // Activación de las nuevas características visuales de Material 3 (versión moderna de Material Design).
        useMaterial3: true,
      ),

      // Define cuál será la primera pantalla que se mostrará al iniciar la app.
      home: const HomeScreen(),

      // Quita la etiqueta de "debug" en la esquina superior derecha al ejecutar en modo desarrollo.
      debugShowCheckedModeBanner: false,
    );
  }
}
