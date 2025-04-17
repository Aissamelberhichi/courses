import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shopping_list_detail_screen.dart';

class ShoppingListsScreen extends StatelessWidget {
  const ShoppingListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes listes de courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('shopping_lists')
                .where(
                  'userId',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid,
                )
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final lists = snapshot.data?.docs ?? [];

          if (lists.isEmpty) {
            return const Center(
              child: Text('Aucune liste de courses pour le moment'),
            );
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return ListTile(
                title: Text(list['name']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteList(list.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ShoppingListDetailScreen(
                            listId: list.id,
                            listName: list['name'],
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context) async {
    final nameController = TextEditingController();

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nouvelle liste'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom de la liste'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    _createList(nameController.text);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Créer'),
              ),
            ],
          ),
    );
  }

  Future<void> _createList(String name) async {
    await FirebaseFirestore.instance.collection('shopping_lists').add({
      'name': name,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteList(String listId) async {
    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(listId)
        .delete();
  }
}
