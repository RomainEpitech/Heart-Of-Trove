import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../widgets/loading_indicator.dart';
import '../widgets/map_widget.dart';
import '../widgets/center_location_button.dart';
import '../widgets/compass_widget.dart';
import '../services/location_service.dart';

class LiveMapPage extends StatefulWidget {
  const LiveMapPage({super.key});

  @override
  State<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends State<LiveMapPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  
  LatLng? _currentPosition;
  double _heading = 0.0;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription<CompassEvent>? _compassStream;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (!hasPermission) return;

    _startLocationStream();
    _startCompassStream();
  }

  void _startLocationStream() {
    _positionStream = _locationService.getPositionStream().listen((position) {
      final newPosition = LatLng(position.latitude, position.longitude);
      _locationService.animateToPosition(
        oldPosition: _currentPosition,
        newPosition: newPosition,
        onUpdate: (interpolated) {
          if (mounted) {
            setState(() => _currentPosition = interpolated);
            _mapController.move(interpolated, _mapController.zoom);
          }
        },
      );
    });
  }

  void _startCompassStream() {
    _compassStream = FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        setState(() {
          _heading = event.heading!;
        });
      }
    });
  }

  void _centerOnCurrentPosition() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, _mapController.zoom);
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _compassStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? const LoadingIndicator()
          : Stack(
              children: [
                MapWidget(
                  mapController: _mapController,
                  currentPosition: _currentPosition!,
                  heading: _heading,
                ),
                
                // Boussole en haut à gauche
                Positioned(
                  top: 50,
                  right: 20,
                  child: CompassWidget(heading: _heading),
                ),
                
                // Bouton centrer en bas
                CenterLocationButton(
                  onPressed: _centerOnCurrentPosition,
                ),
              ],
            ),
    );
  }
}