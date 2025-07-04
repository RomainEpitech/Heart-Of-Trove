import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'map_tile_layer.dart';
import 'user_location_marker.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng currentPosition;
  final double heading;

  const MapWidget({
    super.key,
    required this.mapController,
    required this.currentPosition,
    required this.heading,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition,
        initialZoom: 17,
        interactionOptions: const InteractionOptions(),
      ),
      children: [
        const MapTileLayer(),
        UserLocationMarker(
          position: currentPosition,
          heading: heading,
        ),
      ],
    );
  }
}