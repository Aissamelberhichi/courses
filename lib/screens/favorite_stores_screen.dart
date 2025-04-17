import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class FavoriteStoresScreen extends StatefulWidget {
  const FavoriteStoresScreen({super.key});

  @override
  State<FavoriteStoresScreen> createState() => _FavoriteStoresScreenState();
}

class _FavoriteStoresScreenState extends State<FavoriteStoresScreen> {
  final _nameController = TextEditingController();
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _currentPosition = position);

      _checkNearbyStores();
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _checkNearbyStores() async {
    if (_currentPosition == null) return;

    final stores =
        await FirebaseFirestore.instance
            .collection('favorite_stores')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            .get();

    for (var store in stores.docs) {
      final storeLocation = store['location'] as GeoPoint;
      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        storeLocation.latitude,
        storeLocation.longitude,
      );

      if (distance <= 500) {
        // 500 meters
        _showNearbyStoreNotification(store['name']);
      }
    }
  }

  void _showNearbyStoreNotification(String storeName) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous êtes proche de $storeName !'),
        action: SnackBarAction(
          label: 'Voir la liste',
          onPressed: () {
            // Navigate to shopping list
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magasins favoris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddStoreDialog,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('favorite_stores')
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

          final stores = snapshot.data?.docs ?? [];

          if (stores.isEmpty) {
            return const Center(child: Text('Aucun magasin favori'));
          }

          return ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return ListTile(
                title: Text(store['name']),
                subtitle: Text(store['address']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteStore(store.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddStoreDialog() async {
    String? selectedAddress;
    GeoPoint? selectedLocation;

    return showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ajouter un magasin'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du magasin',
                  ),
                ),
                const SizedBox(height: 16),
                GooglePlaceAutoCompleteTextField(
                  textEditingController: TextEditingController(),
                  googleAPIKey: "AIzaSyCirgxlMHAbm_G7uoJL8rgN-t_OA_dTuY8",
                  inputDecoration: const InputDecoration(labelText: 'Adresse'),
                  debounceTime: 800,
                  countries: const ["fr"],
                  isLatLngRequired: true,
                  getPlaceDetailWithLatLng: (Prediction prediction) {
                    selectedAddress = prediction.description;
                    selectedLocation = GeoPoint(
                      double.parse(prediction.lat ?? "0"),
                      double.parse(prediction.lng ?? "0"),
                    );
                  },
                  itemClick: (Prediction prediction) {
                    selectedAddress = prediction.description;
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
                  if (_nameController.text.isNotEmpty &&
                      selectedAddress != null) {
                    _addStore(
                      _nameController.text,
                      selectedAddress!,
                      selectedLocation!,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ajouter'),
              ),
            ],
          ),
    );
  }

  Future<void> _addStore(String name, String address, GeoPoint location) async {
    await FirebaseFirestore.instance.collection('favorite_stores').add({
      'name': name,
      'address': address,
      'location': location,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deleteStore(String storeId) async {
    await FirebaseFirestore.instance
        .collection('favorite_stores')
        .doc(storeId)
        .delete();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
