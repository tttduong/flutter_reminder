import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/ui/widgets/day_column.dart';
import 'package:flutter_to_do_app/ui/widgets/time_column.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class WeeklyCalendar extends StatefulWidget {
  final CalendarController controller;

  const WeeklyCalendar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<WeeklyCalendar> createState() => _WeeklyCalendarState();
}

class _WeeklyCalendarState extends State<WeeklyCalendar> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToInitialPosition = false;
  static const double hourHeight = 80.0;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (_scrollController.hasClients && !_hasScrolledToInitialPosition) {
    //     _scrollController.jumpTo(7 * hourHeight);
    //     _hasScrolledToInitialPosition = true;
    //   }
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && !_hasScrolledToInitialPosition) {
        _scrollController.jumpTo(7 * hourHeight);
        _hasScrolledToInitialPosition = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final taskController = Get.find<TaskController>();

      if (taskController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: 24 * hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TimeColumn(hourHeight: hourHeight),
              ...widget.controller.displayedDays.map((date) {
                return Expanded(
                  child: DayColumn(
                    date: date,
                    controller: widget.controller,
                    scrollController: _scrollController,
                    hourHeight: hourHeight,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

// class TimeColumn extends StatelessWidget {
//   final double hourHeight;

//   const TimeColumn({
//     Key? key,
//     required this.hourHeight,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 50,
//       child: Column(
//         children: List.generate(24, (hour) {
//           return SizedBox(
//             height: hourHeight,
//             child: Text(
//               '${hour.toString().padLeft(2, '0')}:00',
//               style: const TextStyle(fontSize: 12),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
