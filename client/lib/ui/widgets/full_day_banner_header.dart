import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';

class FullDayBannerHeader extends StatelessWidget {
  final int taskCount;
  final bool isExpanded;
  final VoidCallback onToggle;

  const FullDayBannerHeader({
    Key? key,
    required this.taskCount,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Day Events ($taskCount)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            AnimatedRotation(
              duration: const Duration(milliseconds: 200),
              turns: isExpanded ? 0.5 : 0.0,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
