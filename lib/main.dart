import 'package:flutter/material.dart';
import 'screens/home_screen.dart'; // Importez votre écran d'accueil
import 'screens/login_screen.dart'; // Importez votre écran de connexion
import 'screens/SignUpScreen.dart'; // Importez votre écran d'inscription
import 'screens/list_screen.dart'; // Importez votre écran de gestion des listes
import 'screens/favorites_screen.dart'; // Importez votre écran de gestion des magasins favoris

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Courses',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Couleur principale de l'application
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login', // Route initiale
      routes: {
        '/': (context) => HomeScreen(), // Écran d'accueil
        '/login': (context) => LoginScreen(), // Écran de connexion
        '/signup': (context) => SignUpScreen(), // Écran d'inscription
        //'/list': (context) => ListScreen(), // Écran de gestion des listes
        //'/favorites': (context) => FavoritesScreen(), // Écran de gestion des magasins favoris
      },
    );
  }
}
