import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/store.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ajouter un magasin aux favoris
  Future<void> addFavoriteStore(String userId, Store store) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoriteStores')
          .doc(store.id)
          .set(store.toMap());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du magasin: $e');
    }
  }

  // Obtenir tous les magasins favoris d'un utilisateur
  Stream<List<Store>> getFavoriteStores(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favoriteStores')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Store.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Mettre à jour un magasin favori
  Future<void> updateFavoriteStore(String userId, Store store) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoriteStores')
          .doc(store.id)
          .update(store.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du magasin: $e');
    }
  }

  // Supprimer un magasin des favoris
  Future<void> removeFavoriteStore(String userId, String storeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favoriteStores')
          .doc(storeId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du magasin: $e');
    }
  }

  // Vérifier si l'utilisateur est proche d'un magasin favori
  Future<List<Store>> getNearbyStores(String userId, Position userPosition) async {
    final stores = await getFavoriteStores(userId).first;
    return stores.where((store) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        store.location.latitude,
        store.location.longitude,
      );
      return distance <= store.radius;
    }).toList();
  }
}
