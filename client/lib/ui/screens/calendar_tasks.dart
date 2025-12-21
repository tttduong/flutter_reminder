// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import 'package:flutter_to_do_app/controller/category_controller.dart';
// import 'package:flutter_to_do_app/controller/task_controller.dart';
// import 'package:flutter_to_do_app/data/models/task.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';

// class CalendarTasks extends StatefulWidget {
//   const CalendarTasks({Key? key}) : super(key: key);

//   @override
//   State<CalendarTasks> createState() => _CalendarTasksState();
// }

// class _CalendarTasksState extends State<CalendarTasks> {
//   DateTime _selectedDate = DateTime.now();
//   final _taskController = Get.put(TaskController());
//   final ScrollController _scrollController = ScrollController();

//   late List<DateTime> _displayedDays;
//   static const double hourHeight = 80.0;

//   double? _hoverHour;
//   final List<Task> _multiDayTasks = [];
//   bool _hasScrolledToInitialPosition = false;

//   List<Task> _getMultiDayTasks() {
//     return _taskController.taskList.where((task) {
//       if (task.date == null || task.dueDate == null) return false;
//       final startDate = task.date!;
//       final endDate = task.dueDate!;
//       final dayDiff = endDate.difference(startDate).inDays;
//       return dayDiff >= 1;
//     }).toList();
//   }

//   @override
//   void initState() {
//     super.initState();

//     _selectedDate = DateTime(
//       _selectedDate.year,
//       _selectedDate.month,
//       _selectedDate.day,
//     );

//     _updateDisplayedDays();

//     final taskController = Get.find<TaskController>();
//     taskController.getTasks();
//     taskController.getFullDayTasks(_selectedDate);

//     ever(taskController.taskList, (_) {
//       if (!mounted) return;
//       setState(() {
//         _multiDayTasks
//           ..clear()
//           ..addAll(_getMultiDayTasks());
//       });
//     });
//     // ← Thêm listener cho fullDayTaskList
//     ever(taskController.fullDayTaskList, (_) {
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   void _updateDisplayedDays() {
//     _displayedDays = [
//       _selectedDate.subtract(const Duration(days: 1)),
//       _selectedDate,
//       _selectedDate.add(const Duration(days: 1)),
//     ];
//   }

//   Future<void> _loadTasksForDisplayedDays() async {
//     _taskController.isLoading.value = true;
//     await _taskController.getTasksByDate(_selectedDate);
//     await _taskController.getFullDayTasks(_selectedDate);
//     _taskController.isLoading.value = false;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_hasScrolledToInitialPosition && _scrollController.hasClients) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_scrollController.hasClients) {
//           _scrollController.jumpTo(7 * hourHeight);
//           _hasScrolledToInitialPosition = true;
//         }
//       });
//     }

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Column(
//         children: [
//           _buildAppBar(),
//           _buildMiniCalendar(),
//           _buildMultiDayBanner(),
//           _buildFullDayBanner(),
//           Expanded(
//             child: _buildWeeklyCalendar(),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       leadingWidth: 0,
//       automaticallyImplyLeading: false,
//       // leading: IconButton(
//       //   icon: const Icon(Icons.menu, color: Colors.black),
//       //   onPressed: () {},
//       // ),
//       title: Text(
//         DateFormat('MMMM').format(_selectedDate),
//         style: GoogleFonts.inter(
//           fontSize: 18,
//           fontWeight: FontWeight.w600,
//           color: Colors.black,
//         ),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.more_vert, color: Colors.black),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }

//   Widget _buildMiniCalendar() {
//     final weekdayNames =
//         _displayedDays.map((date) => DateFormat('E').format(date)).toList();

//     return Container(
//       color: Colors.transparent,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: weekdayNames.asMap().entries.map((entry) {
//           final index = entry.key;
//           final day = entry.value;
//           final date = _displayedDays[index];
//           final isSelected = index == 1;

//           return GestureDetector(
//             onTap: () async {
//               setState(() {
//                 _selectedDate = date;
//                 _updateDisplayedDays();
//               });
//               await _loadTasksForDisplayedDays();
//             },
//             child: Column(
//               children: [
//                 Text(
//                   day,
//                   style: GoogleFonts.inter(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0xFF4285F4)
//                         : Colors.transparent,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text(
//                       date.day.toString(),
//                       style: GoogleFonts.inter(
//                         fontSize: 16,
//                         fontWeight:
//                             isSelected ? FontWeight.w600 : FontWeight.w400,
//                         color: isSelected ? Colors.white : Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildWeeklyCalendar() {
//     return Obx(() {
//       if (_taskController.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       return SingleChildScrollView(
//         controller: _scrollController,
//         child: SizedBox(
//           height: 24 * hourHeight,
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTimeColumn(),
//               ..._displayedDays.map((date) {
//                 return Expanded(
//                   child: _buildDayColumn(date),
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       );
//     });
//   }

//   Widget _buildTimeColumn() {
//     return Container(
//       width: 50,
//       color: Colors.transparent,
//       child: Column(
//         children: List.generate(24, (hour) {
//           return Container(
//             height: hourHeight,
//             alignment: Alignment.topRight,
//             padding: const EdgeInsets.only(right: 8, top: 4),
//             child: Text(
//               '${hour.toString().padLeft(2, '0')}',
//               style: GoogleFonts.inter(
//                 fontSize: 10,
//                 color: Colors.grey[600],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildDayColumn(DateTime date) {
//     final tasksForDay = _taskController.taskList.where((task) {
//       if (task.date == null || task.dueDate == null) return false;

//       final isSameDay = task.date!.year == date.year &&
//           task.date!.month == date.month &&
//           task.date!.day == date.day;

//       final isMultiDay = task.dueDate!.difference(task.date!).inDays >= 1;

//       return isSameDay && !isMultiDay;
//     }).toList();

//     tasksForDay.sort((a, b) {
//       final durA = a.dueDate?.difference(a.date!).inMinutes ?? 60;
//       final durB = b.dueDate?.difference(b.date!).inMinutes ?? 60;
//       return durB.compareTo(durA);
//     });

//     return DragTarget<Task>(
//       onAcceptWithDetails: (details) {
//         final renderBox = context.findRenderObject() as RenderBox?;
//         if (renderBox == null) return;
//         final localOffset = renderBox.globalToLocal(details.offset);
//         final dy = localOffset.dy;

//         final newHour = dy / hourHeight;
//         final hour = newHour.floor();
//         final minutes = ((newHour - hour) * 60).round();

//         final newStart = DateTime(
//           date.year,
//           date.month,
//           date.day,
//           hour,
//           minutes,
//         );

//         final task = details.data;
//         final duration =
//             task.dueDate?.difference(task.date!) ?? const Duration(hours: 1);
//         final newEnd = newStart.add(duration);

//         setState(() {
//           task.date = newStart;
//           task.dueDate = newEnd;
//         });
//       },
//       onMove: (details) {
//         final renderBox = context.findRenderObject() as RenderBox?;
//         if (renderBox == null) return;
//         final localOffset = renderBox.globalToLocal(details.offset);
//         final dy = localOffset.dy;

//         final newHour = dy / hourHeight;
//         final slot = (newHour * 12).floor() / 12;

//         setState(() {
//           _hoverHour = slot;
//         });
//       },
//       onLeave: (data) => setState(() => _hoverHour = null),
//       builder: (context, candidateData, rejectedData) {
//         return Container(
//           color: Colors.transparent,
//           child: Stack(
//             children: [
//               CustomPaint(
//                 size: Size.infinite,
//                 painter: _GridPainter(hourHeight: hourHeight),
//               ),
//               ...tasksForDay.map((task) {
//                 return _buildTaskWidget(task, date);
//               }).toList(),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTaskWidget(Task task, DateTime date) {
//     final categoryController = Get.find<CategoryController>();
//     final category = categoryController.categoryList
//         .firstWhereOrNull((c) => c.id == task.categoryId);

//     final startHour = task.date!.hour + task.date!.minute / 60.0;
//     final duration = task.dueDate != null
//         ? task.dueDate!.difference(task.date!).inMinutes / 60.0
//         : 1.0;

//     final top = startHour * hourHeight;
//     const double minHeight = 70.0;
//     final height = (duration * hourHeight).clamp(minHeight, double.infinity);

//     final color = pastelColor(category?.color ?? Colors.red[200]!);

//     return Positioned(
//       top: top,
//       left: 4,
//       right: 4,
//       child: LongPressDraggable<Task>(
//         data: task,
//         feedback: Material(
//           elevation: 4,
//           borderRadius: BorderRadius.circular(8),
//           child: Container(
//             width: 120,
//             height: height,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.8),
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//         childWhenDragging: Container(
//           height: height,
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Container(
//           height: height,
//           decoration: BoxDecoration(
//             color: color,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           padding: const EdgeInsets.all(8),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 task.title ?? '',
//                 style: const TextStyle(fontSize: 11),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 '${DateFormat('HH:mm').format(task.date!)}'
//                 '${task.dueDate != null ? '-${DateFormat('HH:mm').format(task.dueDate!)}' : ''}',
//                 style: const TextStyle(fontSize: 10),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color pastelColor(Color color) {
//     return Color.lerp(color, Colors.white, 0.4)!;
//   }

//   Color extraPastelColor(Color color) {
//     return Color.lerp(color, Colors.white, 0.7)!;
//   }

//   Widget _buildMultiDayBanner() {
//     final tasksForSelectedDate = _multiDayTasks.where((task) {
//       if (task.date == null || task.dueDate == null) return false;

//       final startDate =
//           DateTime(task.date!.year, task.date!.month, task.date!.day);
//       final endDate =
//           DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
//       final selected =
//           DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

//       return !selected.isBefore(startDate) && !selected.isAfter(endDate);
//     }).toList();

//     if (tasksForSelectedDate.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       height: 105,
//       decoration: BoxDecoration(
//         color: Colors.transparent,
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//       ),
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         scrollDirection: Axis.horizontal,
//         itemCount: tasksForSelectedDate.length,
//         itemBuilder: (context, index) {
//           final task = tasksForSelectedDate[index];
//           return _buildMultiDayCard(task);
//         },
//       ),
//     );
//   }

//   Widget _buildMultiDayCard(Task task) {
//     final categoryController = Get.find<CategoryController>();
//     final category = categoryController.categoryList
//         .firstWhereOrNull((c) => c.id == task.categoryId);

//     final startDate = task.date!;
//     final endDate = task.dueDate!;
//     final totalDays = endDate.difference(startDate).inDays + 1;
//     final currentDay = DateTime.now().difference(startDate).inDays + 1;
//     final double progress = (currentDay / totalDays).clamp(0.0, 1.0);
//     final remainingDays = (totalDays - currentDay).clamp(0, totalDays);

//     final baseColor = category?.color ?? Colors.blueAccent;
//     final pastelColor = extraPastelColor(baseColor);

//     return Container(
//       width: 280,
//       margin: const EdgeInsets.only(right: 8),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: pastelColor.withOpacity(0.5),
//         borderRadius: BorderRadius.circular(8),
//         border: Border(
//           left: BorderSide(color: baseColor.withOpacity(0.8), width: 3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: pastelColor.withOpacity(0.3),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.calendar_today_rounded,
//                   size: 14, color: baseColor.withOpacity(0.8)),
//               const SizedBox(width: 6),
//               Expanded(
//                 child: Text(
//                   task.title,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             '${startDate.toString().split(' ')[0]} → ${endDate.toString().split(' ')[0]}',
//             style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Text(
//                 'Ngày $currentDay/$totalDays',
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               Text(
//                 ' • Còn $remainingDays ngày',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey.shade600,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '${(progress * 100).toInt()}%',
//                 style: TextStyle(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: baseColor.withOpacity(0.8),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(2),
//             child: LinearProgressIndicator(
//               value: progress,
//               backgroundColor: Colors.grey.shade200,
//               valueColor:
//                   AlwaysStoppedAnimation<Color>(baseColor.withOpacity(0.8)),
//               minHeight: 3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget hiển thị full day tasks banner
//   // Widget _buildFullDayBanner() {
//   //   return Obx(() {
//   //     // Debug: In ra để kiểm tra
//   //     // print('=== Full Day Banner Debug ===');
//   //     // print('Selected Date: $_selectedDate');
//   //     // print(
//   //     //     'Full Day Task List count: ${_taskController.fullDayTaskList.length}');
//   //     // _taskController.fullDayTaskList.forEach((task) {
//   //     //   print(
//   //     //       'Task: ${task.title}, date: ${task.date}, dueDate: ${task.dueDate}');
//   //     // });

//   //     final fullDayTasks =
//   //         _taskController.getFullDayTasksForDate(_selectedDate);
//   //     // print('Filtered tasks for selected date: ${fullDayTasks.length}');

//   //     if (fullDayTasks.isEmpty) {
//   //       return const SizedBox.shrink();
//   //     }
//   //     return Container(
//   //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   //       // decoration: BoxDecoration(
//   //       // color: Colors.blue.shade50,
//   //       // borderRadius: BorderRadius.circular(12),
//   //       // border: Border.all(color: Colors.blue.shade200, width: 1),
//   //       // ),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           Padding(
//   //             padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//   //             child: Row(
//   //               children: [
//   //                 Icon(
//   //                   Icons.event_available,
//   //                   size: 20,
//   //                   color: Colors.blue.shade700,
//   //                 ),
//   //                 const SizedBox(width: 8),
//   //                 Text(
//   //                   'All Day Events (${fullDayTasks.length})',
//   //                   style: TextStyle(
//   //                     fontSize: 14,
//   //                     fontWeight: FontWeight.w600,
//   //                     color: Colors.blue.shade700,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //           const Divider(height: 1),
//   //           ListView.separated(
//   //             shrinkWrap: true,
//   //             physics: const NeverScrollableScrollPhysics(),
//   //             padding: const EdgeInsets.all(8),
//   //             itemCount: fullDayTasks.length,
//   //             separatorBuilder: (context, index) => const SizedBox(height: 6),
//   //             itemBuilder: (context, index) {
//   //               return _buildFullDayTaskCard(fullDayTasks[index]);
//   //             },
//   //           ),
//   //         ],
//   //       ),
//   //     );
//   //   });
//   // }
//   Widget _buildFullDayBanner() {
//     return Obx(() {
//       final fullDayTasks =
//           _taskController.getFullDayTasksForDate(_selectedDate);
//       if (fullDayTasks.isEmpty) {
//         return const SizedBox.shrink();
//       }

//       // Trạng thái mở rộng / thu gọn
//       final isExpanded = _taskController.isFullDayExpanded.value;

//       return Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         // decoration: BoxDecoration(
//         //   color: Colors.blue.shade50,
//         //   borderRadius: BorderRadius.circular(12),
//         //   border: Border.all(color: Colors.blue.shade200, width: 1),
//         // ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header: "All Day Events"
//             InkWell(
//               borderRadius: BorderRadius.circular(12),
//               onTap: () {
//                 _taskController.isFullDayExpanded.toggle();
//               },
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.event_available,
//                           size: 20,
//                           color: Colors.blue.shade700,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'All Day Events (${fullDayTasks.length})',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.blue.shade700,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // Mũi tên xuống / lên
//                     AnimatedRotation(
//                       duration: const Duration(milliseconds: 200),
//                       turns: isExpanded ? 0.5 : 0.0, // 0.5 vòng = xoay 180°
//                       child: Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: Colors.blue.shade700,
//                         size: 22,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             if (isExpanded) const Divider(height: 1),

//             // Danh sách task (chỉ hiện khi mở rộng)
//             if (isExpanded)
//               ListView.separated(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 padding: const EdgeInsets.all(8),
//                 itemCount: fullDayTasks.length,
//                 separatorBuilder: (context, index) => const SizedBox(height: 6),
//                 itemBuilder: (context, index) {
//                   return _buildFullDayTaskCard(fullDayTasks[index]);
//                 },
//               ),
//           ],
//         ),
//       );
//     });
//   }

// // Widget card cho từng full day task
//   Widget _buildFullDayTaskCard(Task task) {
//     return Container(
//       // padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color.fromRGBO(0, 0, 0, 0),
//         // borderRadius: BorderRadius.circular(8),
//         // border: Border.all(
//         //   color: _getPriorityColor(task.priority).withOpacity(0.3),
//         //   width: 1.5,
//         // ),
//         // boxShadow: [
//         //   BoxShadow(
//         //     color: Colors.black.withOpacity(0.05),
//         //     blurRadius: 4,
//         //     offset: const Offset(0, 2),
//         //   ),
//         // ],
//       ),
//       child: Row(
//         children: [
//           // Priority indicator
//           // Container(
//           //   width: 10,
//           //   height: 10,
//           //   decoration: BoxDecoration(
//           //     color: _getPriorityColor(task.priority),
//           //     borderRadius: BorderRadius.circular(2),
//           //   ),
//           // ),
//           // Completion checkbox
//           InkWell(
//             onTap: () {
//               _toggleTaskCompletion(task);
//             },
//             borderRadius: BorderRadius.circular(4),
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               child: Icon(
//                 task.isCompleted == 1
//                     ? Icons.check_circle
//                     : Icons.circle_outlined,
//                 color: task.isCompleted == 1
//                     ? _getPriorityColor(task.priority)
//                     : _getPriorityColor(task.priority).withOpacity(0.4),
//                 size: 24,
//               ),
//             ),
//           ),
//           const SizedBox(width: 4),
//           // Task info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   task.title ?? 'Untitled',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey.shade800,
//                     decoration: task.isCompleted == 1
//                         ? TextDecoration.lineThrough
//                         : null,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 if (task.description?.isNotEmpty ?? false) ...[
//                   const SizedBox(height: 4),
//                   Text(
//                     task.description!,
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey.shade600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

// // Helper: Lấy màu theo priority
//   Color _getPriorityColor(int? priority) {
//     switch (priority) {
//       case 0:
//         return AppColors.black;
//       case 1:
//         return Colors.red;
//       case 2:
//         return Colors.orange;
//       case 3:
//         return Colors.blue;
//       case 4:
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

// // Toggle task completion
// // Toggle task completion
//   Future<void> _toggleTaskCompletion(Task task) async {
//     _taskController.toggleTaskCompletion(task);
//     await _taskController.getFullDayTasks(_selectedDate);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

// class _GridPainter extends CustomPainter {
//   final double hourHeight;
//   _GridPainter({required this.hourHeight});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.grey[300]!
//       ..strokeWidth = 0.5;

//     for (double y = 0; y < size.height; y += hourHeight) {
//       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_to_do_app/consts.dart';
// // import 'package:flutter_to_do_app/controller/category_controller.dart';
// // import 'package:flutter_to_do_app/controller/task_controller.dart';
// // import 'package:flutter_to_do_app/data/models/task.dart';
// // import 'package:flutter_to_do_app/ui/screens/base_app.dart';
// // import 'package:get/get.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:intl/intl.dart';

// // class CalendarTasks extends StatefulWidget {
// //   const CalendarTasks({Key? key}) : super(key: key);

// //   @override
// //   State<CalendarTasks> createState() => _CalendarTasksState();
// // }

// // class _CalendarTasksState extends State<CalendarTasks> {
// //   DateTime _selectedDate = DateTime.now();
// //   final _taskController = Get.put(TaskController());
// //   final ScrollController _scrollController = ScrollController();

// //   // Danh sách 3 ngày hiển thị
// //   late List<DateTime> _displayedDays;
// //   // Chiều cao của 1 giờ (pixels)
// //   static const double hourHeight = 80.0; // Tăng từ 60 lên 80

// //   // Task? _draggingTask;
// //   double? _hoverHour; // 👉 lưu slot giờ đang hover
// //   final List<Task> _multiDayTasks = [];

// //   // Lấy multi-day tasks (task > 1 ngày)
// //   List<Task> _getMultiDayTasks() {
// //     return _taskController.taskList.where((task) {
// //       if (task.date == null || task.dueDate == null) return false;

// //       // Parse dates
// //       final startDate = task.date!;
// //       final endDate = task.dueDate!;

// //       // Tính số ngày
// //       final dayDiff = endDate.difference(startDate).inDays;

// //       // Task nhiều ngày nếu >= 1 ngày
// //       return dayDiff >= 1;
// //     }).toList();
// //   }

// //   @override
// //   void initState() {
// //     super.initState();

// //     // Đảm bảo selectedDate chỉ lấy ngày (ko có giờ phút)
// //     _selectedDate = DateTime(
// //       _selectedDate.year,
// //       _selectedDate.month,
// //       _selectedDate.day,
// //     );

// //     _updateDisplayedDays();

// //     // Lấy controller
// //     final taskController = Get.find<TaskController>();

// //     // 🧠 Gọi API thật để lấy tasks
// //     taskController.getTasks();

// //     // 🌀 Lắng nghe khi danh sách task thay đổi
// //     ever(taskController.taskList, (_) {
// //       if (!mounted) return;
// //       setState(() {
// //         _multiDayTasks
// //           ..clear()
// //           ..addAll(_getMultiDayTasks());
// //       });
// //     });

// //     // Cuộn đến 7 giờ sáng sau khi build xong
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _scrollController.jumpTo(7 * hourHeight);
// //     });
// //   }

// //   void _updateDisplayedDays() {
// //     _displayedDays = [
// //       _selectedDate.subtract(const Duration(days: 1)),
// //       _selectedDate,
// //       _selectedDate.add(const Duration(days: 1)),
// //     ];
// //   }

// //   Future<void> _loadTasksForDisplayedDays() async {
// //     _taskController.isLoading.value = true;
// //     // Load tasks cho cả 3 ngày
// //     await _taskController.getTasksByDate(_selectedDate);
// //     _taskController.isLoading.value = false;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // return BaseAppScreen(
// //     //   showAppBar: false, // không hiện appbar chung
// //     // appBar: _buildAppBar(),
// //     return Scaffold(
// //       backgroundColor: Colors.transparent,
// //       appBar: AppBar(
// //         backgroundColor: Colors.transparent,
// //         elevation: 0,
// //         leading: Builder(
// //           builder: (context) => IconButton(
// //             icon: Icon(Icons.arrow_back_ios_new_rounded,
// //                 color: AppColors.primary),
// //             onPressed: () {
// //               Scaffold.of(context).openDrawer(); // 👈 Mở drawer
// //             },
// //           ),
// //         ),
// //         title: const Text(
// //           'Calendar View', // 👉 Text bạn muốn hiển thị
// //           style: TextStyle(
// //             color: AppColors.primary, // màu chữ
// //             fontWeight: FontWeight.w600,
// //             fontSize: 20,
// //           ),
// //         ),
// //       ),
// //       body: Column(
// //         children: [
// //           _buildMiniCalendar(),
// //           _buildMultiDayBanner(),
// //           Expanded(
// //             child: _buildWeeklyCalendar(),
// //           ),
// //         ],
// //       ),
// //       // body: CalendarView(), // phần nội dung riêng
// //     );

// //     // return Scaffold(
// //     //   backgroundColor: Colors.white,

// //     // );
// //   }

// //   PreferredSizeWidget _buildAppBar() {
// //     return AppBar(
// //       backgroundColor: Colors.white,
// //       elevation: 0,
// //       leading: IconButton(
// //         icon: const Icon(Icons.menu, color: Colors.black),
// //         onPressed: () {},
// //       ),
// //       title: Text(
// //         DateFormat('MMMM').format(_selectedDate),
// //         style: GoogleFonts.inter(
// //           fontSize: 18,
// //           fontWeight: FontWeight.w600,
// //           color: Colors.black,
// //         ),
// //       ),
// //       actions: [
// //         IconButton(
// //           icon: const Icon(Icons.more_vert, color: Colors.black),
// //           onPressed: () {},
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildMiniCalendar() {
// //     // Lấy tên thứ động từ date
// //     final weekdayNames =
// //         _displayedDays.map((date) => DateFormat('E').format(date)).toList();

// //     return Container(
// //       color: Colors.white,
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: weekdayNames.asMap().entries.map((entry) {
// //           final index = entry.key;
// //           final day = entry.value;
// //           final date = _displayedDays[index];
// //           final isSelected = index == 1; // Ngày giữa được chọn

// //           return GestureDetector(
// //             onTap: () async {
// //               setState(() {
// //                 _selectedDate = date;
// //                 _updateDisplayedDays();
// //               });
// //               await _loadTasksForDisplayedDays();
// //             },
// //             child: Column(
// //               children: [
// //                 Text(
// //                   day,
// //                   style: GoogleFonts.inter(
// //                     fontSize: 12,
// //                     color: Colors.grey[600],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Container(
// //                   width: 40,
// //                   height: 40,
// //                   decoration: BoxDecoration(
// //                     color: isSelected
// //                         ? const Color(0xFF4285F4)
// //                         : Colors.transparent,
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       date.day.toString(),
// //                       style: GoogleFonts.inter(
// //                         fontSize: 16,
// //                         fontWeight:
// //                             isSelected ? FontWeight.w600 : FontWeight.w400,
// //                         color: isSelected ? Colors.white : Colors.black,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }

// //   Widget _buildWeeklyCalendar() {
// //     return Obx(() {
// //       if (_taskController.isLoading.value) {
// //         return const Center(child: CircularProgressIndicator());
// //       }

// //       return SingleChildScrollView(
// //         controller: _scrollController,
// //         child: SizedBox(
// //           height: 24 * hourHeight,
// //           child: Row(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               _buildTimeColumn(),
// //               Expanded(
// //                 child: Row(
// //                   children: _displayedDays.map((date) {
// //                     return Expanded(
// //                       child: _buildDayColumn(date),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     });
// //   }

// //   Widget _buildTimeColumn() {
// //     return Container(
// //       width: 50,
// //       color: Colors.white,
// //       child: SingleChildScrollView(
// //         controller: _scrollController,
// //         child: Column(
// //           children: List.generate(24, (hour) {
// //             return Container(
// //               height: hourHeight,
// //               alignment: Alignment.topRight,
// //               padding: const EdgeInsets.only(right: 8, top: 4),
// //               child: Text(
// //                 '${hour.toString().padLeft(2, '0')}',
// //                 style: GoogleFonts.inter(
// //                   fontSize: 10,
// //                   color: Colors.grey[600],
// //                 ),
// //               ),
// //             );
// //           }),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDayColumn(DateTime date) {
// //     final tasksForDay = _taskController.taskList.where((task) {
// //       if (task.date == null || task.dueDate == null) return false;

// //       final isSameDay = task.date!.year == date.year &&
// //           task.date!.month == date.month &&
// //           task.date!.day == date.day;

// //       // ✅ Loại bỏ task nhiều ngày
// //       final isMultiDay = task.dueDate!.difference(task.date!).inDays >= 1;

// //       return isSameDay && !isMultiDay;
// //     }).toList();

// //     // Sort: dài trước, ngắn sau => khi render, ngắn sẽ được vẽ sau cùng => nằm trên
// //     tasksForDay.sort((a, b) {
// //       final durA = a.dueDate?.difference(a.date!).inMinutes ?? 60;
// //       final durB = b.dueDate?.difference(b.date!).inMinutes ?? 60;
// //       return durB.compareTo(durA); // dài lớn trước
// //     });

// //     return Expanded(
// //       child: LayoutBuilder(
// //         builder: (context, constraints) {
// //           return DragTarget<Task>(
// //             onAcceptWithDetails: (details) {
// //               final renderBox = context.findRenderObject() as RenderBox?;
// //               if (renderBox == null) return;
// //               final localOffset = renderBox.globalToLocal(details.offset);
// //               final dy = localOffset.dy;

// //               final newHour = dy / hourHeight;
// //               final hour = newHour.floor();
// //               final minutes = ((newHour - hour) * 60).round();

// //               final newStart = DateTime(
// //                 date.year,
// //                 date.month,
// //                 date.day,
// //                 hour,
// //                 minutes,
// //               );

// //               final task = details.data;
// //               final duration = task.dueDate?.difference(task.date!) ??
// //                   const Duration(hours: 1);
// //               final newEnd = newStart.add(duration);

// //               setState(() {
// //                 task.date = newStart;
// //                 task.dueDate = newEnd;
// //               });
// //             },
// //             onMove: (details) {
// //               final renderBox = context.findRenderObject() as RenderBox?;
// //               if (renderBox == null) return;
// //               final localOffset = renderBox.globalToLocal(details.offset);
// //               final dy = localOffset.dy;

// //               final newHour = dy / hourHeight;
// //               final slot = (newHour * 12).floor() / 12;

// //               setState(() {
// //                 _hoverHour = slot;
// //               });
// //             },
// //             onLeave: (data) => setState(() => _hoverHour = null),
// //             builder: (context, candidateData, rejectedData) {
// //               return Stack(
// //                 children: [
// //                   // background trắng (hoặc grid nếu muốn)
// //                   Container(color: Colors.white),
// //                   CustomPaint(
// //                     size: Size.infinite,
// //                     painter: _GridPainter(hourHeight: hourHeight),
// //                   ),

// //                   // render tasks theo thứ tự đã sort
// //                   ...tasksForDay.map((t) => _buildTaskBlock(t)).toList(),
// //                 ],
// //               );
// //             },
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildTaskBlock(Task task) {
// //     final categoryController = Get.find<CategoryController>();
// //     final category = categoryController.categoryList.firstWhereOrNull(
// //       (c) => c.id == task.categoryId,
// //     );

// //     final startHour = task.date!.hour + task.date!.minute / 60.0;
// //     final duration = task.dueDate != null
// //         ? task.dueDate!.difference(task.date!).inMinutes / 60.0
// //         : 1.0;

// //     final top = startHour * hourHeight;
// //     const double minHeight = 70.0;
// //     final height = (duration * hourHeight).clamp(minHeight, double.infinity);

// //     final color = pastelColor(category?.color ?? Colors.red[200]!);

// //     return Positioned(
// //       top: top,
// //       left: 4,
// //       right: 4,
// //       child: LongPressDraggable<Task>(
// //         data: task,
// //         feedback: Material(
// //           elevation: 4,
// //           borderRadius: BorderRadius.circular(8),
// //           child: Container(
// //             width: 120,
// //             height: height,
// //             decoration: BoxDecoration(
// //               color: color.withOpacity(0.8),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //           ),
// //         ),
// //         childWhenDragging: Container(
// //           height: height,
// //           decoration: BoxDecoration(
// //             color: Colors.grey[300],
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //         ),
// //         child: Container(
// //           height: height,
// //           decoration: BoxDecoration(
// //             color: color,
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           padding: const EdgeInsets.all(8),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 task.title ?? '',
// //                 style: TextStyle(fontSize: 11),
// //                 maxLines: 3,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               Text(
// //                 '${DateFormat('HH:mm').format(task.date!)}'
// //                 '${task.dueDate != null ? '-${DateFormat('HH:mm').format(task.dueDate!)}' : ''}',
// //                 style: const TextStyle(fontSize: 10),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Color pastelColor(Color color) {
// //     return Color.lerp(color, Colors.white, 0.4)!; // 0.0 = đậm, 1.0 = trắng
// //   }

// //   Color extraPastelColor(Color color) {
// //     // mix 70% white
// //     return Color.lerp(color, Colors.white, 0.7)!;
// //   }

// //   Widget _buildMultiDayBanner() {
// //     // 👉 Lọc chỉ những multi-day task có liên quan tới ngày đang chọn
// //     final tasksForSelectedDate = _multiDayTasks.where((task) {
// //       if (task.date == null || task.dueDate == null) return false;

// //       final startDate =
// //           DateTime(task.date!.year, task.date!.month, task.date!.day);
// //       final endDate =
// //           DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
// //       final selected =
// //           DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

// //       // Chỉ hiển thị nếu ngày được chọn nằm trong khoảng start → end
// //       return !selected.isBefore(startDate) && !selected.isAfter(endDate);
// //     }).toList();

// //     if (tasksForSelectedDate.isEmpty) {
// //       return const SizedBox.shrink();
// //     }

// //     return Container(
// //       height: 105,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         border: Border(
// //           bottom: BorderSide(
// //             color: Colors.grey.shade200,
// //             width: 1,
// //           ),
// //         ),
// //       ),
// //       child: ListView.builder(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //         scrollDirection: Axis.horizontal,
// //         itemCount: tasksForSelectedDate.length,
// //         itemBuilder: (context, index) {
// //           final task = tasksForSelectedDate[index];
// //           return _buildMultiDayCard(task);
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildMultiDayCard(Task task) {
// //     final categoryController = Get.find<CategoryController>();
// //     final category = categoryController.categoryList.firstWhereOrNull(
// //       (c) => c.id == task.categoryId,
// //     );

// //     final startDate = task.date!;
// //     final endDate = task.dueDate!;
// //     final totalDays = endDate.difference(startDate).inDays + 1;
// //     final currentDay = DateTime.now().difference(startDate).inDays +
// //         1; // Ngày hiện tại trong chuỗi
// //     // final progress = (currentDay / totalDays).clamp(0, 1);
// //     final double progress = (currentDay / totalDays).clamp(0.0, 1.0);
// //     final remainingDays = (totalDays - currentDay).clamp(0, totalDays);

// //     // Màu có thể tùy theo category hoặc random
// //     final baseColor = category?.color ?? Colors.blueAccent;
// //     final pastelColor = extraPastelColor(baseColor);

// //     return Container(
// //       width: 280,
// //       margin: const EdgeInsets.only(right: 8),
// //       padding: const EdgeInsets.all(10),
// //       decoration: BoxDecoration(
// //         color: pastelColor.withOpacity(0.5), // nền dịu mắt hơn
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border(
// //           left: BorderSide(color: baseColor.withOpacity(0.8), width: 3),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: pastelColor.withOpacity(0.3),
// //             blurRadius: 4,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           // Title row
// //           Row(
// //             children: [
// //               Icon(Icons.calendar_today_rounded,
// //                   size: 14, color: baseColor.withOpacity(0.8)),
// //               const SizedBox(width: 6),
// //               Expanded(
// //                 child: Text(
// //                   task.title,
// //                   style: TextStyle(
// //                     fontSize: 13,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.grey.shade800,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 6),

// //           // Date range
// //           Text(
// //             '${startDate.toString().split(' ')[0]} → ${endDate.toString().split(' ')[0]}',
// //             style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
// //           ),
// //           const SizedBox(height: 6),

// //           // Progress info
// //           Row(
// //             children: [
// //               Text(
// //                 'Ngày $currentDay/$totalDays',
// //                 style: TextStyle(
// //                   fontSize: 11,
// //                   fontWeight: FontWeight.w500,
// //                   color: Colors.grey.shade700,
// //                 ),
// //               ),
// //               Text(
// //                 ' • Còn $remainingDays ngày',
// //                 style: TextStyle(
// //                   fontSize: 11,
// //                   color: Colors.grey.shade600,
// //                 ),
// //               ),
// //               const Spacer(),
// //               Text(
// //                 '${(progress * 100).toInt()}%',
// //                 style: TextStyle(
// //                   fontSize: 10,
// //                   fontWeight: FontWeight.w600,
// //                   color: baseColor.withOpacity(0.8),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 4),

// //           // Progress bar
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(2),
// //             child: LinearProgressIndicator(
// //               value: progress,
// //               backgroundColor: Colors.grey.shade200,
// //               valueColor:
// //                   AlwaysStoppedAnimation<Color>(baseColor.withOpacity(0.8)),
// //               minHeight: 3,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     super.dispose();
// //   }
// // }

// // class _GridPainter extends CustomPainter {
// //   final double hourHeight;
// //   _GridPainter({required this.hourHeight});

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.grey[300]! // màu của đường kẻ
// //       ..strokeWidth = 0.5;

// //     // vẽ từng dòng theo mỗi giờ
// //     for (double y = 0; y < size.height; y += hourHeight) {
// //       canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
// //     }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// // }

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/detail_task.dart'; // ← Import detail sheet
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarTasks extends StatefulWidget {
  const CalendarTasks({Key? key}) : super(key: key);

  @override
  State<CalendarTasks> createState() => _CalendarTasksState();
}

class _CalendarTasksState extends State<CalendarTasks> {
  DateTime _selectedDate = DateTime.now();
  // final _taskController = Get.put(TaskController());
  final _taskController = Get.find<TaskController>();

  final ScrollController _scrollController = ScrollController();

  late List<DateTime> _displayedDays;
  static const double hourHeight = 80.0;

  double? _hoverHour;
  final List<Task> _multiDayTasks = [];
  bool _hasScrolledToInitialPosition = false;

  List<Task> _getMultiDayTasks() {
    return _taskController.taskList.where((task) {
      if (task.date == null || task.dueDate == null) return false;
      final startDate = task.date!;
      final endDate = task.dueDate!;
      final dayDiff = endDate.difference(startDate).inDays;
      return dayDiff >= 1;
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    _updateDisplayedDays();

    final taskController = Get.find<TaskController>();
    taskController.getTasks();
    taskController.getFullDayTasks(_selectedDate);

    ever(taskController.taskList, (_) {
      if (!mounted) return;
      setState(() {
        _multiDayTasks
          ..clear()
          ..addAll(_getMultiDayTasks());
      });
    });

    ever(taskController.fullDayTaskList, (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _updateDisplayedDays() {
    _displayedDays = [
      _selectedDate.subtract(const Duration(days: 1)),
      _selectedDate,
      _selectedDate.add(const Duration(days: 1)),
    ];
  }

  Future<void> _loadTasksForDisplayedDays() async {
    _taskController.isLoading.value = true;
    await _taskController.getTasksByDate(_selectedDate);
    await _taskController.getFullDayTasks(_selectedDate);
    _taskController.isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasScrolledToInitialPosition && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(7 * hourHeight);
          _hasScrolledToInitialPosition = true;
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildAppBar(),
          _buildMiniCalendar(),
          _buildMultiDayBanner(),
          _buildFullDayBanner(),
          Expanded(
            child: _buildWeeklyCalendar(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      title: Text(
        DateFormat('MMMM').format(_selectedDate),
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMiniCalendar() {
    final weekdayNames =
        _displayedDays.map((date) => DateFormat('E').format(date)).toList();

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekdayNames.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = _displayedDays[index];
          final isSelected = index == 1;

          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedDate = date;
                _updateDisplayedDays();
              });
              await _loadTasksForDisplayedDays();
            },
            child: Column(
              children: [
                Text(
                  day,
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
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Obx(() {
      if (_taskController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        controller: _scrollController,
        child: SizedBox(
          height: 24 * hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeColumn(),
              ..._displayedDays.map((date) {
                return Expanded(
                  child: _buildDayColumn(date),
                );
              }).toList(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTimeColumn() {
    return Container(
      width: 50,
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

  Widget _buildDayColumn(DateTime date) {
    final tasksForDay = _taskController.taskList.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      final isSameDay = task.date!.year == date.year &&
          task.date!.month == date.month &&
          task.date!.day == date.day;

      final isMultiDay = task.dueDate!.difference(task.date!).inDays >= 1;

      return isSameDay && !isMultiDay;
    }).toList();

    tasksForDay.sort((a, b) {
      final durA = a.dueDate?.difference(a.date!).inMinutes ?? 60;
      final durB = b.dueDate?.difference(b.date!).inMinutes ?? 60;
      return durB.compareTo(durA);
    });

    return DragTarget<Task>(
      onAcceptWithDetails: (details) {
        if (!_scrollController.hasClients) return;

        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.offset);
        final scrollOffset = _scrollController.offset;

        // ✅ Cộng scroll để có vị trí thực trong calendar
        final actualY = localPosition.dy + scrollOffset;

        // ✅ Thả ở đâu thì rơi ngay đó (không snap)
        final hourDecimal = actualY / hourHeight - 2.4;
        final hour = hourDecimal.floor().clamp(0, 23);
        final minutes = ((hourDecimal - hour) * 60).round().clamp(0, 59);

        final newStart = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minutes,
        );

        final task = details.data;
        final duration =
            task.dueDate?.difference(task.date!) ?? const Duration(hours: 1);
        final newEnd = newStart.add(duration);

        setState(() {
          task.date = newStart;
          task.dueDate = newEnd;
          _hoverHour = null;
        });
      },
      onMove: (details) {
        if (!_scrollController.hasClients) return;

        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.offset);
        final scrollOffset = _scrollController.offset;

        // ✅ Cộng scroll để có vị trí thực trong calendar
        final actualY = localPosition.dy + scrollOffset;

        // ✅ Hover đi theo feedback (không snap vào grid)
        final hourDecimal = actualY / hourHeight;

        setState(() {
          _hoverHour = hourDecimal -
              2.4; // Không làm tròn, đi theo chính xác vị trí ngón tay
        });
      },
      onLeave: (data) => setState(() {
        _hoverHour = null;
      }),
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: _GridPainter(hourHeight: hourHeight),
              ),

              // ✅ Hover indicator - snap vào grid
              if (_hoverHour != null)
                Positioned(
                  top: _hoverHour! * hourHeight,
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
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${(_hoverHour! * 60).toInt()} min',
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

              // Tasks
              ...tasksForDay.map((task) {
                return _buildTaskWidget(task, date);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // ✅ Task widget - Feedback tự do di chuyển theo ngón tay
  Widget _buildTaskWidget(Task task, DateTime date) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categoryList
        .firstWhereOrNull((c) => c.id == task.categoryId);

    final startHour = task.date!.hour + task.date!.minute / 60.0;
    final duration = task.dueDate != null
        ? task.dueDate!.difference(task.date!).inMinutes / 60.0
        : 1.0;

    final top = startHour * hourHeight;
    const double minHeight = 70.0;
    final height = (duration * hourHeight).clamp(minHeight, double.infinity);

    final color = pastelColor(category?.color ?? Colors.red[200]!);

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      child: LongPressDraggable<Task>(
        data: task,
        // ✅ Feedback đi theo ngón tay, không snap
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
          child: Container(
            width: 120,
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        childWhenDragging: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => TaskDetailBottomSheet(taskId: task.id!),
            ).then((_) {
              _loadTasksForDisplayedDays();
            });
          },
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? '',
                  style: const TextStyle(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${DateFormat('HH:mm').format(task.date!)}'
                  '${task.dueDate != null ? '-${DateFormat('HH:mm').format(task.dueDate!)}' : ''}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color pastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.4)!;
  }

  Color extraPastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.7)!;
  }

  // ✅ CẬP NHẬT: _buildMultiDayCard với tap để mở detail
  Widget _buildMultiDayBanner() {
    final tasksForSelectedDate = _multiDayTasks.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      final startDate =
          DateTime(task.date!.year, task.date!.month, task.date!.day);
      final endDate =
          DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
      final selected =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

      return !selected.isBefore(startDate) && !selected.isAfter(endDate);
    }).toList();

    if (tasksForSelectedDate.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: tasksForSelectedDate.length,
        itemBuilder: (context, index) {
          final task = tasksForSelectedDate[index];
          return _buildMultiDayCard(task);
        },
      ),
    );
  }

  // ✅ Thêm GestureDetector để mở detail
  Widget _buildMultiDayCard(Task task) {
    final categoryController = Get.find<CategoryController>();
    final category = categoryController.categoryList
        .firstWhereOrNull((c) => c.id == task.categoryId);

    final startDate = task.date!;
    final endDate = task.dueDate!;
    final totalDays = endDate.difference(startDate).inDays + 1;
    final currentDay = DateTime.now().difference(startDate).inDays + 1;
    final double progress = (currentDay / totalDays).clamp(0.0, 1.0);
    final remainingDays = (totalDays - currentDay).clamp(0, totalDays);

    final baseColor = category?.color ?? Colors.blueAccent;
    final pastelColor = extraPastelColor(baseColor);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailBottomSheet(taskId: task.id!),
        ).then((_) {
          _loadTasksForDisplayedDays();
        });
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: pastelColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: baseColor.withOpacity(0.8), width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: pastelColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: baseColor.withOpacity(0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${startDate.toString().split(' ')[0]} → ${endDate.toString().split(' ')[0]}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'Ngày $currentDay/$totalDays',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  ' • Còn $remainingDays ngày',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: baseColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor:
                    AlwaysStoppedAnimation<Color>(baseColor.withOpacity(0.8)),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullDayBanner() {
    return Obx(() {
      final fullDayTasks =
          _taskController.getFullDayTasksForDate(_selectedDate);
      if (fullDayTasks.isEmpty) {
        return const SizedBox.shrink();
      }

      final isExpanded = _taskController.isFullDayExpanded.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _taskController.isFullDayExpanded.toggle();
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'All Day Events (${fullDayTasks.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.5 : 0.0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.blue.shade700,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) const Divider(height: 1),
            if (isExpanded)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: fullDayTasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  return _buildFullDayTaskCard(fullDayTasks[index]);
                },
              ),
          ],
        ),
      );
    });
  }

  // ✅ CẬP NHẬT: Wrap full day task card với GestureDetector
  Widget _buildFullDayTaskCard(Task task) {
    return GestureDetector(
      onTap: () {
        // Mở detail sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => TaskDetailBottomSheet(taskId: task.id!),
        ).then((_) {
          // Refresh sau khi đóng
          _loadTasksForDisplayedDays();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                _toggleTaskCompletion(task);
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  task.isCompleted == 1
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: task.isCompleted == 1
                      ? _getPriorityColor(task.priority)
                      : _getPriorityColor(task.priority).withOpacity(0.4),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title ?? 'Untitled',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      decoration: task.isCompleted == 1
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (task.description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int? priority) {
    switch (priority) {
      case 0:
        return AppColors.black;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    _taskController.toggleTaskCompletion(task);
    await _taskController.getFullDayTasks(_selectedDate);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _GridPainter extends CustomPainter {
  final double hourHeight;
  _GridPainter({required this.hourHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 0.5;

    for (double y = 0; y < size.height; y += hourHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
