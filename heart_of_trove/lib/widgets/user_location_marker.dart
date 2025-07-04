import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserLocationMarker extends StatelessWidget {
  final LatLng position;
  final double heading;

  const UserLocationMarker({
    super.key,
    required this.position,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          width: 60,
          height: 60,
          point: position,
          child: Transform.rotate(
            angle: heading * math.pi / 180,
            child: Container(
              child: const Icon(
                Icons.navigation,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}