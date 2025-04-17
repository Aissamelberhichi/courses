import 'package:flutter/material.dart';
import 'ShoppingListScreen.dart';
import 'favorite_stores_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ShoppingListsScreen(), //ShoppingListScreen
    FavoriteStoresScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Listes de courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Magasins favoris',
          ),
        ],
      ),
    );
  }
}
