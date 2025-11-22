import 'dart:math' as math;

import 'package:flutter/material.dart';

double sin(double x) => math.sin(x);

// 🔥 Typing Indicator Widget
class TypingIndicatorCustom extends StatefulWidget {
  const TypingIndicatorCustom({Key? key}) : super(key: key);

  @override
  State<TypingIndicatorCustom> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicatorCustom>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset =
                sin((_controller.value * 2 * 3.14159) + (index * 0.3)) * 6;
            return Transform.translate(
              offset: Offset(0, offset),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[400],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
