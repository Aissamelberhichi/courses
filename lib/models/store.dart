import 'package:google_maps_flutter/google_maps_flutter.dart';

class Store {
  final String id;
  final String name;
  final LatLng location;
  final String address;
  final double radius; // en mètres

  Store({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    this.radius = 500, // rayon par défaut de 500m
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'address': address,
      'radius': radius,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map, String id) {
    final location = map['location'] as Map<String, dynamic>;
    return Store(
      id: id,
      name: map['name'] ?? '',
      location: LatLng(
        location['latitude'] ?? 0.0,
        location['longitude'] ?? 0.0,
      ),
      address: map['address'] ?? '',
      radius: map['radius']?.toDouble() ?? 500.0,
    );
  }
}
