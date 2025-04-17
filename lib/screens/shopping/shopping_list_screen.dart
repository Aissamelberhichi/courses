import 'package:flutter/material.dart';
import '../../models/shopping_list.dart';
import '../../services/shopping_list_service.dart';

class ShoppingListScreen extends StatefulWidget {
  final ShoppingList list;

  const ShoppingListScreen({
    super.key,
    required this.list,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _shoppingListService = ShoppingListService();
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  String _selectedCategory = 'Divers';
  int _quantity = 1;

  final List<String> _categories = [
    'Fruits',
    'Légumes',
    'Produits laitiers',
    'Viandes',
    'Boissons',
    'Snacks',
    'Produits d\'entretien',
    'Divers',
  ];

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un article'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'article',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Quantité: '),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 1) _quantity--;
                      });
                    },
                  ),
                  Text('$_quantity'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _addItem,
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      final newItem = ShoppingItem(
        id: DateTime.now().toString(),
        name: _itemNameController.text,
        category: _selectedCategory,
        quantity: _quantity,
        purchased: false,
      );

      try {
        await _shoppingListService.addItemToList(widget.list.id, newItem);
        if (mounted) {
          _itemNameController.clear();
          _quantity = 1;
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
      ),
      body: StreamBuilder<List<ShoppingList>>(
        stream: _shoppingListService.getUserShoppingLists(widget.list.userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentList = snapshot.data!
              .firstWhere((list) => list.id == widget.list.id);
          final items = currentList.items;

          if (items.isEmpty) {
            return const Center(
              child: Text('Aucun article dans la liste'),
            );
          }

          // Trier les articles par catégorie
          final itemsByCategory = <String, List<ShoppingItem>>{};
          for (var item in items) {
            if (!itemsByCategory.containsKey(item.category)) {
              itemsByCategory[item.category] = [];
            }
            itemsByCategory[item.category]!.add(item);
          }

          return ListView.builder(
            itemCount: itemsByCategory.length,
            itemBuilder: (context, index) {
              final category = itemsByCategory.keys.elementAt(index);
              final categoryItems = itemsByCategory[category]!;

              return ExpansionTile(
                title: Text(category),
                initiallyExpanded: true,
                children: categoryItems.map((item) {
                  return ListTile(
                    leading: Checkbox(
                      value: item.purchased,
                      onChanged: (value) async {
                        await _shoppingListService.toggleItemPurchased(
                          widget.list.id,
                          item.id,
                        );
                      },
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: item.purchased
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text('Quantité: ${item.quantity}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await _shoppingListService.removeItem(
                          widget.list.id,
                          item.id,
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    super.dispose();
  }
}
