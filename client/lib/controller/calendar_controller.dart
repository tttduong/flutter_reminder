import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/ui/widgets/schedule_appbar.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/models/task_position.dart';

class CalendarController extends GetxController {
  final TaskController _taskController = Get.find<TaskController>();

  // Observable state
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DateTime> displayedDays = <DateTime>[].obs;
  final RxList<Task> multiDayTasks = <Task>[].obs;
  // final RxDouble hoverHour = 0.0.obs;
  // final RxBool hasHover = false.obs;
  final RxBool hasUnsavedChanges = false.obs;
  final Rx<ScheduleViewMode> viewMode = ScheduleViewMode.calendar.obs;
  final Rx<double?> hoverHour = Rx<double?>(null);
  final RxBool hasHover = false.obs;
  // Change tracking
  final RxMap<int, TaskPosition> originalPositions = <int, TaskPosition>{}.obs;
  final RxMap<int, TaskPosition> currentPositions = <int, TaskPosition>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeSelectedDate();
    _updateDisplayedDays();
    _loadInitialData();
    _setupListeners();
  }

  void _initializeSelectedDate() {
    selectedDate.value = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
  }

  void _updateDisplayedDays() {
    displayedDays.value = [
      selectedDate.value.subtract(const Duration(days: 1)),
      selectedDate.value,
      selectedDate.value.add(const Duration(days: 1)),
    ];
  }

  void _loadInitialData() async {
    await _taskController.getTasks();
    await _taskController.getFullDayTasks(selectedDate.value);
    _updateMultiDayTasks();
  }

  void _setupListeners() {
    ever(_taskController.taskList, (_) {
      _updateMultiDayTasks();
    });
  }

  void _updateMultiDayTasks() {
    multiDayTasks.value = _taskController.taskList.where((task) {
      if (task.date == null || task.dueDate == null) return false;
      final dayDiff = task.dueDate!.difference(task.date!).inDays;
      return dayDiff >= 1;
    }).toList();
  }

  // Date selection
  Future<void> selectDate(DateTime date) async {
    selectedDate.value = date;
    _updateDisplayedDays();
    await loadTasksForDisplayedDays();
  }

  Future<void> loadTasksForDisplayedDays() async {
    _taskController.isLoading.value = true;
    await _taskController.getTasksByDate(selectedDate.value);
    await _taskController.getFullDayTasks(selectedDate.value);
    _taskController.isLoading.value = false;
  }

  // Drag & Drop operations
  void saveOriginalPosition(Task task) {
    if (!originalPositions.containsKey(task.id)) {
      originalPositions[task.id!] = TaskPosition(
        date: task.date!,
        dueDate: task.dueDate!,
      );
    }
  }

  void updateTaskPosition(Task task, DateTime newDate, DateTime newDueDate) {
    currentPositions[task.id!] = TaskPosition(
      date: newDate,
      dueDate: newDueDate,
    );

    task.date = newDate;
    task.dueDate = newDueDate;
    hasUnsavedChanges.value = true;
    _taskController.taskList.refresh();
  }

  void setHoverPosition(double hour) {
    hoverHour.value = hour;
    hasHover.value = true;
  }

  // void clearHover() {
  //   hasHover.value = false;
  // }
  void clearHover() {
    hoverHour.value = null;
    hasHover.value = false;
  }

  // Save/Cancel changes
  Future<void> saveAllChanges() async {
    if (!hasUnsavedChanges.value) return;

    try {
      _taskController.isLoading.value = true;

      for (var taskId in currentPositions.keys) {
        final task = _taskController.taskList.firstWhere((t) => t.id == taskId);
        final position = currentPositions[taskId]!;

        task.date = position.date;
        task.dueDate = position.dueDate;
        await _taskController.updateTask(task);
      }

      _clearChangeTracking();

      Get.snackbar(
        '✅ Success',
        'Tasks updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      await loadTasksForDisplayedDays();
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

  void cancelAllChanges() {
    if (!hasUnsavedChanges.value) return;

    for (var taskId in originalPositions.keys) {
      final task = _taskController.taskList.firstWhere((t) => t.id == taskId);
      final originalPosition = originalPositions[taskId]!;

      task.date = originalPosition.date;
      task.dueDate = originalPosition.dueDate;
    }

    _clearChangeTracking();
    _taskController.taskList.refresh();

    Get.snackbar(
      'ℹ️ Cancelled',
      'Changes discarded',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.withOpacity(0.8),
      colorText: Colors.white,
    );
  }

  void _clearChangeTracking() {
    originalPositions.clear();
    currentPositions.clear();
    hasUnsavedChanges.value = false;
  }

  // View mode
  void setViewMode(ScheduleViewMode mode) {
    viewMode.value = mode;
  }

  // Task filtering
  List<Task> getTasksForDay(DateTime date) {
    return _taskController.taskList.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      final isSameDay = task.date!.year == date.year &&
          task.date!.month == date.month &&
          task.date!.day == date.day;

      final isMultiDay = task.dueDate!.difference(task.date!).inDays >= 1;

      return isSameDay && !isMultiDay;
    }).toList()
      ..sort((a, b) {
        final durA = a.dueDate?.difference(a.date!).inMinutes ?? 60;
        final durB = b.dueDate?.difference(b.date!).inMinutes ?? 60;
        return durB.compareTo(durA);
      });
  }

  List<Task> getMultiDayTasksForSelectedDate() {
    return multiDayTasks.where((task) {
      if (task.date == null || task.dueDate == null) return false;

      final startDate = DateTime(
        task.date!.year,
        task.date!.month,
        task.date!.day,
      );
      final endDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      final selected = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
      );

      return !selected.isBefore(startDate) && !selected.isAfter(endDate);
    }).toList();
  }

  bool hasTaskChanges(int taskId) {
    return currentPositions.containsKey(taskId);
  }

  Future<void> toggleTaskCompletion(Task task) async {
    await _taskController.toggleTaskCompletion(task);
    await _taskController.getFullDayTasks(selectedDate.value);
  }
}
