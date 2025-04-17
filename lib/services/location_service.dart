import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();
  StreamSubscription<Position>? _positionStreamSubscription;

  Stream<Position> get locationStream => _locationController.stream;

  Future<Position> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Erreur lors de l\'obtention de la position: $e');
      throw e;
    }
  }



  // Vérifier et demander les permissions de localisation
  Future<bool> requestLocationPermission() async {
    try {
      // Vérifier si les services de localisation sont activés
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Services de localisation désactivés');
        // Demander à l'utilisateur d'activer les services de localisation
        bool? serviceRequest = await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          return false;
        }
      }

      // Vérifier les permissions de localisation
      LocationPermission permission = await Geolocator.checkPermission();
      print('Permission actuelle: $permission');

      // Si les permissions sont refusées, les demander
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        print('Nouvelle permission après demande: $permission');
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      // Si les permissions sont refusées définitivement
      if (permission == LocationPermission.deniedForever) {
        print('Permission refusée définitivement');
        // Rediriger l'utilisateur vers les paramètres de l'application
        await Geolocator.openAppSettings();
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          return false;
        }
      }

      // Vérifier si nous avons besoin de la permission en arrière-plan
      if (permission == LocationPermission.whileInUse) {
        // Demander la permission en arrière-plan si nécessaire
        if (await Geolocator.checkPermission() != LocationPermission.always) {
          final bool? backgroundRequest = await _showBackgroundLocationDialog();
          if (backgroundRequest == true) {
            permission = await Geolocator.requestPermission();
          }
        }
      }

      print('Permission de localisation accordée: $permission');
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Erreur lors de la demande de permission: $e');
      return false;
    }
  }

  Future<bool?> _showBackgroundLocationDialog() async {
    // Note: Cette méthode devrait être implémentée dans votre widget
    // car elle nécessite un BuildContext pour afficher le dialogue
    return null;
  }

  // Démarrer le suivi de la localisation
  Future<void> startLocationTracking() async {
    try {
      if (!await requestLocationPermission()) {
        print('Impossible de démarrer le suivi: permission non accordée');
        return;
      }

      // Arrêter l'ancien suivi s'il existe
      await stopLocationTracking();

      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // mise à jour tous les 10 mètres
        ),
      ).listen(
        (Position position) {
          print('Nouvelle position reçue: ${position.latitude}, ${position.longitude}');
          _locationController.add(position);
        },
        onError: (e) {
          print('Erreur dans le flux de position: $e');
        },
        cancelOnError: false,
      );

      print('Suivi de la localisation démarré');
    } catch (e) {
      print('Erreur lors du démarrage du suivi: $e');
    }
  }

  // Arrêter le suivi de la localisation
  Future<void> stopLocationTracking() async {
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      print('Suivi de la localisation arrêté');
    } catch (e) {
      print('Erreur lors de l\'arrêt du suivi: $e');
    }
  }

  // Nettoyer les ressources
  void dispose() {
    stopLocationTracking();
    _locationController.close();
  }

  // Calculer la distance entre deux points
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}