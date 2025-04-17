import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingList {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdAt': createdAt,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  factory ShoppingList.fromMap(Map<String, dynamic> map, String id) {
    return ShoppingList(
      id: id,
      name: map['name'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: List<ShoppingItem>.from(
        (map['items'] ?? []).map((item) => ShoppingItem.fromMap(item)),
      ),
    );
  }
}

class ShoppingItem {
  final String id;
  final String name;
  final String category;
  final int quantity;
  final bool purchased;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.purchased,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'purchased': purchased,
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      quantity: map['quantity'] ?? 1,
      purchased: map['purchased'] ?? false,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? category,
    int? quantity,
    bool? purchased,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      purchased: purchased ?? this.purchased,
    );
  }
}
