import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

enum ScheduleViewMode {
  calendar,
  grid,
}

class ScheduleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final bool hasUnsavedChanges;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final ValueChanged<ScheduleViewMode>? onModeSelected;
  final ScheduleViewMode currentMode;

  const ScheduleAppBar({
    super.key,
    required this.selectedDate,
    required this.hasUnsavedChanges,
    required this.currentMode,
    this.onCancel,
    this.onSave,
    this.onMore,
    this.onModeSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,

      // LEFT
      leadingWidth: 80,
      leading: hasUnsavedChanges
          ? TextButton(
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,

      // CENTER
      title: Text(
        currentMode == ScheduleViewMode.calendar
            ? DateFormat('MMMM yyyy').format(selectedDate)
            : 'Eisenhower Matrix',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      // centerTitle: true,

      // RIGHT
      actions: [
        if (hasUnsavedChanges)
          TextButton(
            onPressed: onSave,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          // IconButton(
          //   icon: const Icon(Icons.more_vert, color: AppColors.primary),
          //   onPressed: onMore,
          // ),
          PopupMenuButton<ScheduleViewMode>(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onSelected: onModeSelected,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: ScheduleViewMode.calendar,
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 18,
                      color: currentMode == ScheduleViewMode.calendar
                          ? AppColors.primary
                          : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Calendar Mode',
                      style: TextStyle(
                        color: currentMode == ScheduleViewMode.calendar
                            ? AppColors.primary
                            : Colors.black,
                        fontWeight: currentMode == ScheduleViewMode.calendar
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    // if (currentMode == ScheduleViewMode.calendar)
                    //   const Icon(Icons.check, size: 16),
                  ],
                ),
              ),
              PopupMenuItem(
                value: ScheduleViewMode.grid,
                child: Row(
                  children: [
                    Icon(
                      Icons.grid_view,
                      size: 18,
                      color: currentMode == ScheduleViewMode.grid
                          ? AppColors.primary
                          : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Grid Mode',
                      style: TextStyle(
                        color: currentMode == ScheduleViewMode.grid
                            ? AppColors.primary
                            : Colors.black,
                        fontWeight: currentMode == ScheduleViewMode.grid
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
