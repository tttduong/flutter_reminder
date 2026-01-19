import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:flutter_to_do_app/ui/widgets/schedule_appbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class CalendarHeader extends StatelessWidget implements PreferredSizeWidget {
  final CalendarController controller;

  const CalendarHeader({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ScheduleAppBar(
          selectedDate: controller.selectedDate.value,
          hasUnsavedChanges: controller.hasUnsavedChanges.value,
          currentMode: controller.viewMode.value,
          onCancel: controller.cancelAllChanges,
          onSave: controller.saveAllChanges,
          onModeSelected: controller.setViewMode,
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
