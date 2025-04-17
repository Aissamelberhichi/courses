import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingListDetailScreen extends StatefulWidget {
  final String listId;
  final String listName;

  const ShoppingListDetailScreen({
    super.key,
    required this.listId,
    required this.listName,
  });

  @override
  State<ShoppingListDetailScreen> createState() =>
      _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  final List<String> categories = [
    'Fruits et Légumes',
    'Produits Laitiers',
    'Viandes',
    'Épicerie',
    'Boissons',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('shopping_lists')
                .doc(widget.listId)
                .collection('items')
                .orderBy('category')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Une erreur est survenue'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data?.docs ?? [];

          if (items.isEmpty) {
            return const Center(child: Text('Aucun article dans cette liste'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return CheckboxListTile(
                title: Text(item['name']),
                subtitle: Text(item['category']),
                value: item['checked'] ?? false,
                onChanged: (bool? value) {
                  _updateItemStatus(item.id, value ?? false);
                },
                secondary: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddItemDialog() async {
    final nameController = TextEditingController();
    String selectedCategory = categories.first;

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un article'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'article',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Catégorie'),
                  items:
                      categories.map((String category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      selectedCategory = value;
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    _addItem(nameController.text, selectedCategory);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  Future<void> _addItem(String name, String category) async {
    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(widget.listId)
        .collection('items')
        .add({
          'name': name,
          'category': category,
          'checked': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  Future<void> _updateItemStatus(String itemId, bool checked) async {
    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(widget.listId)
        .collection('items')
        .doc(itemId)
        .update({'checked': checked});
  }

  Future<void> _deleteItem(String itemId) async {
    await FirebaseFirestore.instance
        .collection('shopping_lists')
        .doc(widget.listId)
        .collection('items')
        .doc(itemId)
        .delete();
  }
}
