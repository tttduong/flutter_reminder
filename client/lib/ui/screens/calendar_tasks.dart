import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/models/task_position.dart';
import 'package:flutter_to_do_app/ui/screens/detail_task.dart';
import 'package:flutter_to_do_app/ui/screens/eisenhower_matrix.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_floating_button.dart';
import 'package:flutter_to_do_app/ui/widgets/schedule_appbar.dart';
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
  final _taskController = Get.find<TaskController>();
  final ScrollController _scrollController = ScrollController();

  late List<DateTime> _displayedDays;
  static const double hourHeight = 80.0;

  double? _hoverHour;
  final List<Task> _multiDayTasks = [];
  bool _hasScrolledToInitialPosition = false;

  // 🆕 Tracking changes
  final Map<int, TaskPosition> _originalPositions = {};
  final Map<int, TaskPosition> _currentPositions = {};
  bool _hasUnsavedChanges = false;
  ScheduleViewMode _viewMode = ScheduleViewMode.calendar;

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

    // Load tasks cho cả 3 ngày
    await _taskController.getTasksForDateRange(
      _displayedDays.first, // Ngày trước
      _displayedDays.last, // Ngày sau
    );

    await _taskController.getFullDayTasks(_selectedDate);
    _taskController.isLoading.value = false;
  }

  // 🆕 Save original position when drag starts
  void _saveOriginalPosition(Task task) {
    if (!_originalPositions.containsKey(task.id)) {
      _originalPositions[task.id!] = TaskPosition(
        date: task.date!,
        dueDate: task.dueDate!,
      );
    }
  }

  // 🆕 Update current position
  void _updateCurrentPosition(
      Task task, DateTime newDate, DateTime newDueDate) {
    _currentPositions[task.id!] = TaskPosition(
      date: newDate,
      dueDate: newDueDate,
    );

    setState(() {
      task.date = newDate;
      task.dueDate = newDueDate;
      _hasUnsavedChanges = true;
    });
  }

  // 🆕 Save all changes
  Future<void> _saveAllChanges() async {
    if (!_hasUnsavedChanges) return;

    try {
      _taskController.isLoading.value = true;

      // Update all changed tasks
      for (var taskId in _currentPositions.keys) {
        final task = _taskController.taskList.firstWhere((t) => t.id == taskId);
        final position = _currentPositions[taskId]!;

        task.date = position.date;
        task.dueDate = position.dueDate;

        await _taskController.updateTask(task);
      }

      // Clear tracking
      _originalPositions.clear();
      _currentPositions.clear();

      setState(() {
        _hasUnsavedChanges = false;
      });

      Get.snackbar(
        '✅ Success',
        'Tasks updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      await _loadTasksForDisplayedDays();
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to update tasks: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _taskController.isLoading.value = false;
    }
  }

  // 🆕 Cancel all changes
  void _cancelAllChanges() {
    if (!_hasUnsavedChanges) return;

    setState(() {
      // Revert all tasks to original positions
      for (var taskId in _originalPositions.keys) {
        final task = _taskController.taskList.firstWhere((t) => t.id == taskId);
        final originalPosition = _originalPositions[taskId]!;

        task.date = originalPosition.date;
        task.dueDate = originalPosition.dueDate;
      }

      // Clear tracking
      _originalPositions.clear();
      _currentPositions.clear();
      _hasUnsavedChanges = false;
    });

    Get.snackbar(
      'ℹ️ Cancelled',
      'Changes discarded',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: Colors.white,
    );
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
      appBar: ScheduleAppBar(
        selectedDate: _selectedDate,
        hasUnsavedChanges: _hasUnsavedChanges,
        currentMode: _viewMode,
        onCancel: _cancelAllChanges,
        onSave: _saveAllChanges,
        onModeSelected: (mode) {
          setState(() {
            _viewMode = mode;
          });
        },
      ),
      body: Column(
        children: [
          if (_viewMode == ScheduleViewMode.calendar) ...[
            _buildMiniCalendar(),
            _buildMultiDayBanner(),
            _buildFullDayBanner(),
            Expanded(
              child: _buildWeeklyCalendar(),
            ),
          ] else
            Expanded(
              child: EisenhowerMatrix(),
            ),
        ],
      ),
      floatingActionButton: const ChatFloatingButton(
        showBadge: true,
        unreadCount: 3,
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final weekdayNames =
        _displayedDays.map((date) => DateFormat('E').format(date)).toList();

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekdayNames.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          final date = _displayedDays[index];
          final isSelected = index == 1;

          return GestureDetector(
              onTap: _hasUnsavedChanges
                  ? null // Disable khi đang có thay đổi chưa lưu
                  : () async {
                      setState(() {
                        _selectedDate = date;
                        _updateDisplayedDays();
                      });
                      await _loadTasksForDisplayedDays();
                    },
              child: Opacity(
                opacity: _hasUnsavedChanges ? 0.5 : 1.0, // Làm mờ khi disable
                child: Padding(
                  padding: const EdgeInsets.only(left: 30),
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
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ));
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

        final actualY = localPosition.dy + scrollOffset;

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

        // 🆕 Update position tracking instead of directly modifying task
        _updateCurrentPosition(task, newStart, newEnd);

        setState(() {
          _hoverHour = null;
        });
      },
      onMove: (details) {
        if (!_scrollController.hasClients) return;

        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.offset);
        final scrollOffset = _scrollController.offset;

        final actualY = localPosition.dy + scrollOffset;
        final hourDecimal = actualY / hourHeight;

        setState(() {
          _hoverHour = hourDecimal - 2.4;
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
              ...tasksForDay.map((task) {
                return _buildTaskWidget(task, date);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

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

    final baseColor = category?.color ?? pastelColor(AppColors.primary)!;
    final normalColor = pastelColor(baseColor);
    final completedColor = extraPastelColor(baseColor);
    final draggedColor = pastelColor(baseColor);

    final hasChanges = _currentPositions.containsKey(task.id);
    final isCompleted = task.isCompleted;

    final taskColor = isCompleted ? completedColor : normalColor;

    return Positioned(
      top: top,
      left: 4,
      right: 4,
      child: LongPressDraggable<Task>(
        data: task,
        onDragStarted: () {
          _saveOriginalPosition(task);
        },
        feedback: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
          child: Container(
            width: 120,
            height: height,
            decoration: BoxDecoration(
              color: draggedColor,
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: Colors.white, width: 1), // Thêm viền trắng
            ),
          ),
        ),
        childWhenDragging: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Colors.white, width: 1), // Thêm viền trắng
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
              color: hasChanges ? draggedColor : taskColor,
              borderRadius: BorderRadius.circular(8),
              // Kết hợp viền trắng với viền primary khi hasChanges
              border: hasChanges
                  ? Border.all(color: AppColors.primary, width: 2)
                  : Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1), // Viền trắng mỏng
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 11,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey[600],
                          decorationThickness: 2,
                          color: isCompleted ? Colors.grey[600] : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasChanges)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                Text(
                  '${DateFormat('HH:mm').format(task.date!)}'
                  '${task.dueDate != null ? '-${DateFormat('HH:mm').format(task.dueDate!)}' : ''}',
                  style: TextStyle(
                    fontSize: 10,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.grey[600],
                    color: isCompleted ? Colors.grey[600] : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Màu nhạt cho task bình thường (trộn 40% trắng)
  Color pastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.4)!;
  }

  // Màu nhạt hơn cho task hoàn thành (trộn 70% trắng)
  Color extraPastelColor(Color color) {
    return Color.lerp(color, Colors.white, 0.7)!;
  }

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
                  'Day $currentDay/$totalDays',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  ' • $remainingDays days left',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                // const Spacer(),
                // Text(
                //   '${(progress * 100).toInt()}%',
                //   style: TextStyle(
                //     fontSize: 10,
                //     fontWeight: FontWeight.w600,
                //     color: baseColor.withOpacity(0.8),
                //   ),
                // ),
              ],
            ),
            // const SizedBox(height: 4),
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(2),
            //   child: LinearProgressIndicator(
            //     value: progress,
            //     backgroundColor: Colors.grey.shade200,
            //     valueColor:
            //         AlwaysStoppedAnimation<Color>(baseColor.withOpacity(0.8)),
            //     minHeight: 3,
            //   ),
            // ),
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
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.1),
        ),
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
                        Text(
                          'All Day Events (${fullDayTasks.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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
            ),
            if (isExpanded) const Divider(height: 1),
            if (isExpanded)
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 180, // ✅ Giới hạn chiều cao tối đa
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(), // ✅ Cho phép scroll
                  padding: const EdgeInsets.all(8),
                  itemCount: fullDayTasks.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    return _buildFullDayTaskCard(fullDayTasks[index]);
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFullDayTaskCard(Task task) {
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
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                await _toggleTaskCompletion(task);

                // Reload lại tasks từ database
                await _loadTasksForDisplayedDays();
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  task.isCompleted == true
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: task.isCompleted == true
                      ? task.categoryColor?.withOpacity(0.5)
                      : task.categoryColor,
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
                      color: task.isCompleted == true
                          ? Colors.grey.shade400
                          : Colors.grey.shade800,
                      decoration: task.isCompleted == true
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
                        color: task.isCompleted == true
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        decoration: task.isCompleted == true
                            ? TextDecoration.lineThrough
                            : null,
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
    final linePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 0.5;

    // ===== Chia cột =====
    final double colWidth = size.width / 2;

    // ===== Horizontal lines (theo giờ) =====
    for (double y = 0; y < size.height; y += hourHeight) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    canvas.drawLine(
      Offset(colWidth * 2, 0),
      Offset(colWidth * 2, size.height),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
