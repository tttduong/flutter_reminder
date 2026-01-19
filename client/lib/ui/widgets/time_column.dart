import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeColumn extends StatelessWidget {
  final double hourHeight;

  const TimeColumn({
    Key? key,
    required this.hourHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      color: Colors.transparent,
      child: Column(
        children: List.generate(24, (hour) {
          return Container(
            height: hourHeight,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: Text(
              '${hour.toString().padLeft(2, '0')}',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          );
        }),
      ),
    );
  }
}
