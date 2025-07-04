import 'dart:math' as math;
import 'package:flutter/material.dart';

class CompassWidget extends StatelessWidget {
  final double heading;
  final double size;

  const CompassWidget({
    super.key,
    required this.heading,
    this.size = 80,
  });

  String _getCardinalDirection(double heading) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cercle de fond avec graduations
          CustomPaint(
            size: Size(size, size),
            painter: CompassPainter(),
          ),
          
          // Aiguille de la boussole
          Center(
            child: Transform.rotate(
              angle: heading * math.pi / 180,
              child: Container(
                width: 3,
                height: size * 0.6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.red,      // Nord (pointe rouge)
                      Colors.white,    // Milieu
                      Colors.black,    // Sud (pointe noire)
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Point central
          Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          // Direction cardinale en bas
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Text(
              _getCardinalDirection(heading),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          
          // Degrés en haut
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Text(
              '${heading.round()}°',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black26;
    
    // Cercle extérieur
    canvas.drawCircle(center, radius, paint);
    
    // Graduations principales (N, E, S, W)
    final mainTickPaint = Paint()
      ..strokeWidth = 2
      ..color = Colors.black54;
    
    // Graduations secondaires
    final minorTickPaint = Paint()
      ..strokeWidth = 1
      ..color = Colors.black26;
    
    for (int i = 0; i < 360; i += 15) {
      final angle = i * math.pi / 180;
      final isMainTick = i % 90 == 0;
      final tickLength = isMainTick ? 8.0 : 4.0;
      final tickPaint = isMainTick ? mainTickPaint : minorTickPaint;
      
      final startX = center.dx + (radius - tickLength) * math.cos(angle - math.pi / 2);
      final startY = center.dy + (radius - tickLength) * math.sin(angle - math.pi / 2);
      final endX = center.dx + radius * math.cos(angle - math.pi / 2);
      final endY = center.dy + radius * math.sin(angle - math.pi / 2);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        tickPaint,
      );
    }
    
    // Marquer le Nord
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - radius + 2,
      ),
    );
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}