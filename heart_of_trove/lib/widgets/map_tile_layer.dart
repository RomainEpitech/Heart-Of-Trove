import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapTileLayer extends StatelessWidget {
  const MapTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
      userAgentPackageName: 'com.example.app',
      tileProvider: NetworkTileProvider(),
    );
  }
}