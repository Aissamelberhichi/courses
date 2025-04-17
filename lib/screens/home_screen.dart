import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logique de déconnexion ici
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Magasins Favoris',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Remplacez par le nombre de magasins favoris
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(
                        'Magasin ${index + 1}',
                      ), // Remplacez par le nom du magasin
                      subtitle: Text(
                        'Adresse du magasin',
                      ), // Remplacez par l'adresse
                      onTap: () {
                        // Logique pour naviguer vers les détails du magasin
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers l'écran de gestion des listes de courses
                Navigator.pushNamed(context, '/list');
              },
              child: Text('Créer une nouvelle liste de courses'),
            ),
          ],
        ),
      ),
    );
  }
}
