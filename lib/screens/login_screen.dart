import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  // Instance de FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Connexion de l'utilisateur avec l'e-mail et le mot de passe
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Connexion réussie, vous pouvez rediriger l'utilisateur ou afficher un message
        print('Utilisateur connecté : ${userCredential.user?.email}');
        // Naviguer vers l'écran d'accueil
        Navigator.pushReplacementNamed(
          context,
          '/',
        ); // Remplacez par la route de votre écran d'accueil
      } on FirebaseAuthException catch (e) {
        // Gérer les erreurs de connexion
        String message;
        if (e.code == 'user-not-found') {
          message = 'Aucun utilisateur trouvé avec cet e-mail.';
        } else if (e.code == 'wrong-password') {
          message = 'Mot de passe incorrect.';
        } else {
          message = 'Erreur inconnue : ${e.message}';
        }
        // Afficher un message d'erreur
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse e-mail';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Veuillez entrer une adresse e-mail valide';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _login, child: Text('Se connecter')),
              TextButton(
                onPressed: () {
                  // Naviguer vers la page d'inscription
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text('Pas de compte ? Inscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
