import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/calendar_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/widgets/grid_painter.dart';
import 'package:flutter_to_do_app/ui/widgets/hover_indicator.dart';
import 'package:flutter_to_do_app/ui/widgets/task_widget.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class DayColumn extends StatelessWidget {
  final DateTime date;
  final CalendarController controller;
  final ScrollController scrollController;
  final double hourHeight;

  const DayColumn({
    Key? key,
    required this.date,
    required this.controller,
    required this.scrollController,
    required this.hourHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tasksForDay = controller.getTasksForDay(date);

      return DragTarget<Task>(
          onAcceptWithDetails: (details) => _handleDrop(context, details),
          onMove: (details) => _handleMove(context, details),
          onLeave: (_) => controller.clearHover(),
          // builder: (context, candidateData, rejectedData) {
          //   return Container(
          //     color: Colors.transparent,
          //     child: Stack(
          //       children: [
          //         CustomPaint(
          //           size: Size.infinite,
          //           painter: GridPainter(hourHeight: hourHeight),
          //         ),
          //         if (controller.hasHover.value)
          //           HoverIndicator(
          //             hour: controller.hoverHour.value,
          //             hourHeight: hourHeight,
          //           ),
          //         ...tasksForDay.map((task) {
          //           return TaskWidget(
          //             task: task,
          //             date: date,
          //             controller: controller,
          //             hourHeight: hourHeight,
          //           );
          //         }).toList(),
          //       ],
          //     ),
          //   );
          // },

          builder: (context, candidateData, rejectedData) {
            return Obx(() => Container(
                  // ⚠️ Wrap bằng Obx()
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size.infinite,
                        painter: GridPainter(hourHeight: hourHeight),
                      ),
                      // ✅ Hiển thị hover indicator
                      if (controller.hoverHour.value != null)
                        Positioned(
                          top: controller.hoverHour.value! * hourHeight,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.3),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${(controller.hoverHour.value! * 60).toInt()} min',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ...tasksForDay.map((task) {
                        return TaskWidget(
                          task: task,
                          date: date,
                          controller: controller,
                          hourHeight: hourHeight,
                        );
                      }).toList(),
                    ],
                  ),
                ));
          });
    });
  }

  void _handleDrop(BuildContext context, DragTargetDetails<Task> details) {
    if (!scrollController.hasClients) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.offset);
    final scrollOffset = scrollController.offset;
    final actualY = localPosition.dy + scrollOffset;
    final hourDecimal = actualY / hourHeight - 2.4;

    final hour = hourDecimal.floor().clamp(0, 23);
    final minutes = ((hourDecimal - hour) * 60).round().clamp(0, 59);

    final newStart = DateTime(date.year, date.month, date.day, hour, minutes);
    final task = details.data;
    final duration =
        task.dueDate?.difference(task.date!) ?? const Duration(hours: 1);
    final newEnd = newStart.add(duration);

    controller.updateTaskPosition(task, newStart, newEnd);
    controller.clearHover();
  }

  void _handleMove(BuildContext context, DragTargetDetails<Task> details) {
    if (!scrollController.hasClients) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.offset);
    final scrollOffset = scrollController.offset;
    final actualY = localPosition.dy + scrollOffset;
    final hourDecimal = actualY / hourHeight;

    controller.setHoverPosition(hourDecimal - 2.4);
  }
}
