import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Assurez-vous d'importer le fichier de la page de connexion
import 'screens/SignUpScreen.dart'; // Assurez-vous d'importer le fichier de la page d'inscription
import 'screens/home_screen.dart';
import 'screens/list_screen.dart'; // Assurez-vous d'importer le fichier de l'écran de gestion des listes

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Courses',
      initialRoute: '/login', // Commencez par la page de connexion
      routes: {
        '/': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        //'/list': (context) => ListScreen(), // Remplacez par votre écran de gestion des listes
      },
    );
  }
}
