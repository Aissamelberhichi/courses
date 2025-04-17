import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../services/store_service.dart';
import '../../models/store.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class StoresScreen extends StatefulWidget {
  const StoresScreen({Key? key}) : super(key: key);

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final StoreService _storeService = StoreService();
  final TextEditingController _storeNameController = TextEditingController();

  Position? _currentPosition;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<Store> _favoriteStores = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _retryTimer;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _locationService.dispose();
    _mapController?.dispose();
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      print('Début de l\'initialisation...');
      await _initializeLocation();
      print('Localisation initialisée');
      await _loadStores();
      print('Magasins chargés');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Erreur lors de l\'initialisation: $e');
      print('Stack trace: $stackTrace');
      _handleError('Erreur d\'initialisation: $e');
    }
  }

  Future<void> _loadStores() async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) return;

      final stores = await _storeService.getFavoriteStores(userId).first;
      if (!mounted) return;

      setState(() {
        _favoriteStores = stores;
        _markers = {
          for (var store in stores)
            Marker(
              markerId: MarkerId(store.id),
              position: store.location,
              infoWindow: InfoWindow(title: store.name),
            ),
        };
      });
    } catch (e) {
      _handleError('Erreur lors du chargement des magasins: $e');
    }
  }

  void _checkNearbyStores() {
    if (_currentPosition == null) return;

    for (var store in _favoriteStores) {
      final distance = _locationService.calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        store.location.latitude,
        store.location.longitude,
      );

      if (distance <= store.radius) {
        _showNotification(store);
      }
    }
  }

  void _showNotification(Store store) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vous êtes à proximité de ${store.name}'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Voir',
          onPressed: () {
            _mapController?.animateCamera(
              CameraUpdate.newLatLngZoom(
                store.location,
                18,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showAddStoreDialog() async {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez d\'abord un emplacement sur la carte'),
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un magasin'),
        content: TextField(
          controller: _storeNameController,
          decoration: const InputDecoration(
            labelText: 'Nom du magasin',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final userId = _authService.currentUser?.uid;
              if (userId == null) return;

              final store = Store(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _storeNameController.text,
                location: _selectedLocation!,
                address: '', // TODO: Utiliser l'API Geocoding pour obtenir l'adresse
              );

              await _storeService.addFavoriteStore(userId, store);
              _storeNameController.clear();
              Navigator.pop(context);
              _loadStores();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeLocation() async {
    try {
      print('Début de l\'initialisation de la localisation');
      final hasPermission = await _locationService.requestLocationPermission();
      
      if (!hasPermission) {
        throw Exception('Permission de localisation refusée');
      }

      final position = await _locationService.getCurrentPosition();
      print('Position obtenue: ${position.latitude}, ${position.longitude}');

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });

      _checkNearbyStores();
    } catch (e) {
      print('Erreur lors de l\'initialisation de la localisation: $e');
      throw e;
    }
  }

  void _updateCameraPosition() {
    if (_mapController != null && _currentPosition != null && mounted) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  Widget _buildMap() {
    try {
      print('Construction de la carte');
      if (_currentPosition == null) {
        print('Position null, retour d\'un widget vide');
        return const SizedBox.shrink();
      }

      print('Position actuelle: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      return GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          print('Carte créée');
          if (!mounted) return;
          setState(() {
            _mapController = controller;
          });
          _updateCameraPosition();
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 15,
        ),
        markers: _markers,
        circles: _circles,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: true,
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
            _markers = {
              ..._markers,
              Marker(
                markerId: const MarkerId('selected'),
                position: location,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
              ),
            };
          });
        },
      );
    } catch (e, stackTrace) {
      print('Erreur lors de la construction de la carte: $e');
      print('Stack trace: $stackTrace');
      return Center(
        child: Text('Erreur lors du chargement de la carte: $e'),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_currentPosition == null) {
      return _buildLocationPermissionWidget();
    }

    return _buildMap();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(_errorMessage),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initialize,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPermissionWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off,
            size: 60,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Cette application nécessite l\'accès à votre localisation',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final hasPermission = await _locationService.requestLocationPermission();
              if (hasPermission) {
                _initializeLocation();
              }
            },
            child: const Text('Autoriser la localisation'),
          ),
        ],
      ),
    );
  }

  void _handleError(String message) {
    if (!mounted) return;

    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
    });

    // Retry after 5 seconds
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 5), _initialize);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
            icon: const Icon(Icons.refresh),
            onPressed: _initialize,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStoreDialog,
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
