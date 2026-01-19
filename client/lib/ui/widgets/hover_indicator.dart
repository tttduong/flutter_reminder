import 'package:flutter/material.dart';

class HoverIndicator extends StatelessWidget {
  final double hour;
  final double hourHeight;

  const HoverIndicator({
    Key? key,
    required this.hour,
    required this.hourHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: hour * hourHeight,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${(hour * 60).toInt()} min',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
