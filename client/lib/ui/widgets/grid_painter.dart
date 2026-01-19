import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double hourHeight;

  GridPainter({required this.hourHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 0.5;

    final double colWidth = size.width / 2;

    // Horizontal lines
    for (double y = 0; y < size.height; y += hourHeight) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Vertical line
    canvas.drawLine(
      Offset(colWidth * 2, 0),
      Offset(colWidth * 2, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
