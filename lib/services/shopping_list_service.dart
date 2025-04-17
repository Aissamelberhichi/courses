import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shopping_list.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Créer une nouvelle liste de courses
  Future<String> createShoppingList(String userId, String name) async {
    try {
      final docRef = await _firestore.collection('shoppingLists').add({
        'userId': userId,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'items': [],
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la liste: $e');
    }
  }

  // Obtenir toutes les listes de courses d'un utilisateur
  Stream<List<ShoppingList>> getUserShoppingLists(String userId) {
    return _firestore
        .collection('shoppingLists')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final lists = snapshot.docs
          .map((doc) => ShoppingList.fromMap(doc.data(), doc.id))
          .toList();
      
      // Tri côté client en attendant la création de l'index
      lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return lists;
    });
  }

  // Ajouter un article à une liste
  Future<void> addItemToList(String listId, ShoppingItem item) async {
    try {
      await _firestore.collection('shoppingLists').doc(listId).update({
        'items': FieldValue.arrayUnion([item.toMap()]),
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'article: $e');
    }
  }

  // Mettre à jour un article
  Future<void> updateItem(String listId, ShoppingItem item) async {
    try {
      final list = await _firestore.collection('shoppingLists').doc(listId).get();
      final items = List<Map<String, dynamic>>.from(list.data()?['items'] ?? []);
      
      final index = items.indexWhere((i) => i['id'] == item.id);
      if (index != -1) {
        items[index] = item.toMap();
        await _firestore.collection('shoppingLists').doc(listId).update({
          'items': items,
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'article: $e');
    }
  }

  // Supprimer un article
  Future<void> removeItem(String listId, String itemId) async {
    try {
      final list = await _firestore.collection('shoppingLists').doc(listId).get();
      final items = List<Map<String, dynamic>>.from(list.data()?['items'] ?? []);
      
      items.removeWhere((item) => item['id'] == itemId);
      await _firestore.collection('shoppingLists').doc(listId).update({
        'items': items,
      });
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'article: $e');
    }
  }

  // Marquer un article comme acheté
  Future<void> toggleItemPurchased(String listId, String itemId) async {
    try {
      final list = await _firestore.collection('shoppingLists').doc(listId).get();
      final items = List<Map<String, dynamic>>.from(list.data()?['items'] ?? []);
      
      final index = items.indexWhere((item) => item['id'] == itemId);
      if (index != -1) {
        items[index]['purchased'] = !items[index]['purchased'];
        await _firestore.collection('shoppingLists').doc(listId).update({
          'items': items,
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Supprimer une liste de courses
  Future<void> deleteShoppingList(String listId) async {
    try {
      await _firestore.collection('shoppingLists').doc(listId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la liste: $e');
    }
  }
}
