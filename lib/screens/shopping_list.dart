class ShoppingList {
  String id;
  String name;
  List<String> items;

  ShoppingList({required this.id, required this.name, required this.items});

  // Méthode pour convertir un document Firestore en ShoppingList
  factory ShoppingList.fromFirestore(Map<String, dynamic> data, String id) {
    return ShoppingList(
      id: id,
      name: data['name'] ?? '',
      items: List<String>.from(data['items'] ?? []),
    );
  }

  // Méthode pour convertir ShoppingList en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'items': items};
  }
}
