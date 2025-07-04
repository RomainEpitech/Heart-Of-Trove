import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  Future<bool> requestLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return false;
      }
    }

    return true;
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    );
  }

  void animateToPosition({
    required LatLng? oldPosition,
    required LatLng newPosition,
    required Function(LatLng) onUpdate,
  }) {
    if (oldPosition != null) {
      const duration = Duration(milliseconds: 400);
      const steps = 10;
      final stepDuration = duration ~/ steps;

      for (int i = 1; i <= steps; i++) {
        Future.delayed(stepDuration * i, () {
          final lat = oldPosition.latitude +
              (newPosition.latitude - oldPosition.latitude) * (i / steps);
          final lng = oldPosition.longitude +
              (newPosition.longitude - oldPosition.longitude) * (i / steps);
          final interpolated = LatLng(lat, lng);
          onUpdate(interpolated);
        });
      }
    } else {
      onUpdate(newPosition);
    }
  }
}