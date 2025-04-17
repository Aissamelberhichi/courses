import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/shopping_list_service.dart';
import '../../models/shopping_list.dart';
import '../shopping/shopping_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _shoppingListService = ShoppingListService();
  final _newListController = TextEditingController();

  Future<void> _createNewList() async {
    final name = _newListController.text.trim();
    if (name.isEmpty) return;

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      await _shoppingListService.createShoppingList(userId, name);
      if (mounted) {
        _newListController.clear();
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

  void _showCreateListDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouvelle liste'),
        content: TextField(
          controller: _newListController,
          decoration: const InputDecoration(
            labelText: 'Nom de la liste',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _createNewList,
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes listes de courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.pushNamed(context, '/stores'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Non connecté'))
          : StreamBuilder<List<ShoppingList>>(
              stream: _shoppingListService.getUserShoppingLists(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final lists = snapshot.data!;
                if (lists.isEmpty) {
                  return const Center(
                    child: Text('Aucune liste de courses'),
                  );
                }

                return ListView.builder(
                  itemCount: lists.length,
                  itemBuilder: (context, index) {
                    final list = lists[index];
                    final completedItems = list.items
                        .where((item) => item.purchased)
                        .length;
                    final totalItems = list.items.length;

                    return ListTile(
                      title: Text(list.name),
                      subtitle: Text(
                        '$completedItems/$totalItems articles achetés',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _shoppingListService.deleteShoppingList(list.id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShoppingListScreen(list: list),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateListDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _newListController.dispose();
    super.dispose();
  }
}
