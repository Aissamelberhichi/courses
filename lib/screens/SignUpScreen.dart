import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  // Instance de FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Créer un nouvel utilisateur avec l'e-mail et le mot de passe
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: _email, password: _password);

        // Inscription réussie, vous pouvez rediriger l'utilisateur ou afficher un message
        print('Utilisateur inscrit : ${userCredential.user?.email}');
        // Vous pouvez naviguer vers l'écran d'accueil ou afficher un message de succès ici
        Navigator.pop(context); // Par exemple, revenir à l'écran de connexion
      } on FirebaseAuthException catch (e) {
        // Gérer les erreurs d'inscription
        String message;
        if (e.code == 'weak-password') {
          message = 'Le mot de passe est trop faible.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Un compte existe déjà avec cet e-mail.';
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
      appBar: AppBar(title: Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
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
                    return 'Veuillez entrer un mot de passe';
                  } else if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez confirmer votre mot de passe';
                  } else if (value != _password) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _signUp, child: Text('S\'inscrire')),
              TextButton(
                onPressed: () {
                  // Naviguer vers la page de connexion
                  Navigator.pop(context);
                },
                child: Text('Déjà un compte ? Connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
