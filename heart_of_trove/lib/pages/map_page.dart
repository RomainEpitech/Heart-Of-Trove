import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapPage extends StatefulWidget {
    const MapPage({super.key});

    @override
        State<MapPage> createState() => _MapPageState();
    }

    class _MapPageState extends State<MapPage> {
    LatLng? _userLocation;

    @override
    void initState() {
        void checkPermission() async {
        final status = await Permission.location.status;
        print('🛰️ Location permission status: $status');

        if (status.isDenied) {
            final result = await Permission.location.request();
            print('🛂 Permission result: $result');
        }

        if (await Permission.location.isPermanentlyDenied) {
            openAppSettings(); // ouvre les réglages de l'app
        }
        }

        super.initState();
        _getLocation();
    }

    Future<void> _getLocation() async {
        final status = await Permission.location.request();

        if (status.isGranted) {
            Position position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
            );

            setState(() {
                _userLocation = LatLng(position.latitude, position.longitude);
            });
        } else {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location permission denied')),
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: const Text("Carte")),
            body: _userLocation == null
            ? const Center(child: CircularProgressIndicator())
            : FlutterMap(
                options: MapOptions(
                    center: _userLocation,
                    zoom: 15.0,
                ),
                children: [
                    TileLayer(
                        urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                        userAgentPackageName: 'com.example.heartOfTrove',
                    ),
                    MarkerLayer(
                        markers: [
                            Marker(
                            point: _userLocation!,
                            width: 60,
                            height: 60,
                            child: const Icon(Icons.person_pin_circle, size: 40, color: Colors.red),
                            )
                        ],
                    )
                ],
            ),
        );
    }
}
