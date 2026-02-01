import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  // final Widget child;

  const GradientBackground({
    Key? key,
    // required this.child,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, //màu nền lấy từ theme
    );
  }
}
