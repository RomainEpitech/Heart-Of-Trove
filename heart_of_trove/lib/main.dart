import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Map Tracking',
      debugShowCheckedModeBanner: false,
      home: const LiveMapPage(),
    );
  }
}

class LiveMapPage extends StatefulWidget {
  const LiveMapPage({super.key});

  @override
  State<LiveMapPage> createState() => _LiveMapPageState();
}

class _LiveMapPageState extends State<LiveMapPage> {
  final MapController _mapController = MapController();
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
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) return;
    }

    _startLocationStream();
    _startCompassStream();
  }

  void _startLocationStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 1,
      ),
    ).listen((position) {
      final newPosition = LatLng(position.latitude, position.longitude);

      if (_currentPosition != null) {
        final oldPosition = _currentPosition!;
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

            if (mounted) {
              setState(() => _currentPosition = interpolated);
              _mapController.move(interpolated, _mapController.zoom);
            }
          });
        }
      } else {
        setState(() => _currentPosition = newPosition);
        _mapController.move(newPosition, _mapController.zoom);
      }
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
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 17,
                    interactionOptions: const InteractionOptions(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                      userAgentPackageName: 'com.example.app',
                      tileProvider: NetworkTileProvider(),
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 60,
                          height: 60,
                          point: _currentPosition!,
                          child: Transform.rotate(
                            angle: _heading * math.pi / 180,
                            child: Icon(
                              Icons.navigation,
                              size: 40,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            if (_currentPosition != null) {
                              _mapController.move(_currentPosition!, _mapController.zoom);
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Icon(
                              Icons.my_location,
                              color: Colors.black87,
                              size: 28,
                            ),
                          ),
                        )
                      )
                    )
                  )
                )
              ],
            ),
    );
  }
}