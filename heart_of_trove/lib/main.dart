import 'package:flutter/material.dart';
import 'pages/live_map_page.dart';

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