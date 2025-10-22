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
      color:
          Theme.of(context).scaffoldBackgroundColor, // 👈 màu nền lấy từ theme
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color.fromARGB(255, 245, 231, 254), // Very light purple
//             Color(0xFFF0F9FF), // Very light blue
//             Color(0xFFECFDF5), // Very light green
//             Color(0xFFFFFBEB), // Very light yellow
//             Color(0xFFFEF3F2), // Very light pink
//           ],
//           stops: [0.0, 0.25, 0.5, 0.75, 1.0],
//         ),
//       ),
//       // child: child,
//     );
//   }
}
