import 'package:flutter/material.dart';

class CenterLocationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CenterLocationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
              onTap: onPressed,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.my_location,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}