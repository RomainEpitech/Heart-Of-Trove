import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isLoading = true;
  String _statusMessage = 'Checking permissions...';

  @override
  void initState() {
    super.initState();
    _handleLocationPermission();
  }

  Future<void> _handleLocationPermission() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      _getLocation();
    } else if (status.isDenied) {
      final result = await Permission.location.request();
      if (result.isGranted) {
        _getLocation();
      } else {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Permission refused. Please enable it in settings.';
        });
      }
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Permission permanently denied. Please go to settings.';
      });
      openAppSettings();
    }
  }

  Future<void> _getLocation() async {
    setState(() {
      _statusMessage = 'Getting location...';
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _isLoading = false;
        _statusMessage = 'Your location: ${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error getting location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Page')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(_statusMessage, textAlign: TextAlign.center),
      ),
    );
  }
}
