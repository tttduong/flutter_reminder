import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MiniCalendar extends StatelessWidget {
  final CalendarController controller;

  const MiniCalendar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final displayedDays = controller.displayedDays;
      final selectedDate = controller.selectedDate.value;

      return Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: displayedDays.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final isSelected = index == 1;

            return GestureDetector(
              onTap: () => controller.selectDate(date),
              child: Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Column(
                  children: [
                    Text(
                      DateFormat('E').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4285F4)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
