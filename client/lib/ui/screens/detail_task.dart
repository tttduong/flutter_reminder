import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:flutter_to_do_app/ui/widgets/date_time_picker_modal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TaskDetailBottomSheet extends StatefulWidget {
  final int taskId;

  const TaskDetailBottomSheet({
    Key? key,
    required this.taskId,
  }) : super(key: key);

  @override
  State<TaskDetailBottomSheet> createState() => _TaskDetailBottomSheetState();
}

class _TaskDetailBottomSheetState extends State<TaskDetailBottomSheet> {
  final TaskController taskController = Get.find<TaskController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isLoading = true;
  Task? _task;

  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedDueDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? reminderTime;
  int? reminderDays;

  bool _isAllDay = true;
  List<Category> listCategories = [];
  int? _selectedCategoryId;
  bool _hasPriority = false;
  int? _selectedPriority;
  bool _isCompleted = false;
  final Map<int, String> priorityLabels = {
    1: 'Urgent & Important',
    2: 'Not Urgent & Important',
    3: 'Urgent & Unimportant',
    4: 'Not Urgent & Unimportant',
  };

  @override
  void initState() {
    super.initState();
    // _loadTaskDetails();
    // _loadCategories();
    // ✅ Đợi build xong mới load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTaskDetails();
      _loadCategories();
    });
  }

  Future<void> _loadTaskDetails() async {
    print(">>> TaskDetailBottomSheet opened with id = ${widget.taskId}");
    print("TaskController hash = ${taskController.hashCode}");

    try {
      // Gọi API để lấy task details
      final task = await taskController.getTaskById(widget.taskId);

      if (task != null) {
        setState(() {
          _task = task;
          _titleController.text = task.title;
          _noteController.text = task.description ?? '';
          _selectedCategoryId = task.categoryId;
          _isCompleted = task.isCompleted;
          // Parse date
          if (task.date != null) {
            _selectedStartDate = task.date!;
            // Check if has specific time
            if (task.date!.hour != 0 || task.date!.minute != 0) {
              _isAllDay = false;
              _startTime =
                  TimeOfDay(hour: task.date!.hour, minute: task.date!.minute);
            }
          }

          // Parse due date
          if (task.dueDate != null) {
            _selectedDueDate = task.dueDate;
            if (task.dueDate!.hour != 0 || task.dueDate!.minute != 0) {
              _endTime = TimeOfDay(
                  hour: task.dueDate!.hour, minute: task.dueDate!.minute);
            }
          }

          // Parse reminder
          if (task.reminderTime != null) {
            reminderTime = task.reminderTime;
            // Calculate reminder days
            if (task.date != null) {
              reminderDays = task.date!.difference(task.reminderTime!).inDays;
            }
          }

          // Parse priority
          if (task.priority != null) {
            _hasPriority = true;
            _selectedPriority = task.priority;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading task: $e');
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load task details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  Future<void> _loadCategories() async {
    final categoryController = Get.find<CategoryController>();
    try {
      await CategoryService.fetchCategories();
      setState(() {
        listCategories = categoryController.categoryList;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Header
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          onPressed: _updateTask,
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            // padding: const EdgeInsets.symmetric(
                            //     horizontal: 12, vertical: 8),
                            // decoration: BoxDecoration(
                            //   color: _isCompleted
                            //       ? Colors.green
                            //       : Colors.grey.shade200,
                            //   borderRadius: BorderRadius.circular(20),
                            // ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isCompleted = !_isCompleted;
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isCompleted
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: _isCompleted
                                        ? AppColors.primary
                                        : AppColors.primary,
                                    size: 28, // Kích thước icon lớn hơn
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isCompleted
                                        ? 'Completed'
                                        : 'Mark Complete',
                                    style: TextStyle(
                                      color: _isCompleted
                                          ? AppColors.primary
                                          : Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Action Buttons
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildActionChip(
                                  icon: Icons.calendar_today_outlined,
                                  label: _buildDateLabel(),
                                  isSelected: true,
                                  onTap: () => _showDateTimePicker(),
                                ),
                                const SizedBox(width: 14),
                                _buildActionChip(
                                  icon: Icons.flag_outlined,
                                  label: _hasPriority
                                      ? priorityLabels[_selectedPriority] ??
                                          'Priority'
                                      : 'Priority',
                                  isSelected: _hasPriority,
                                  onTap: () {
                                    setState(() => _hasPriority = true);
                                    _showPriorityBottomSheet();
                                  },
                                ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 16),

                          // Category Dropdown
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 0.5),
                              ),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.category,
                                        color: Colors.black, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'List: ',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<int>(
                                        value: _selectedCategoryId,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: Colors.grey[600]),
                                        iconSize: 24,
                                        isExpanded: true,
                                        underline: Container(height: 0),
                                        items:
                                            listCategories.map((Category cat) {
                                          return DropdownMenuItem<int>(
                                            value: cat.id,
                                            child: Text(cat.title,
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          if (newValue != null) {
                                            setState(() =>
                                                _selectedCategoryId = newValue);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),

                          // Title Input
                          TextField(
                            controller: _titleController,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Task title',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            maxLines: null,
                          ),

                          // Description Input
                          TextField(
                            controller: _noteController,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Description',
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            maxLines: null,
                            minLines: 3,
                          ),

                          const SizedBox(height: 24),

                          // Delete Button
                          Center(
                            child: TextButton.icon(
                              onPressed: _deleteTask,
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              label: const Text(
                                'Delete Task',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _buildDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final startDay = DateTime(_selectedStartDate.year, _selectedStartDate.month,
        _selectedStartDate.day);

    if (startDay.isAtSameMomentAs(today) && _isAllDay) {
      return 'Today';
    }

    if (startDay.isAtSameMomentAs(tomorrow) && _isAllDay) {
      return 'Tomorrow';
    }

    if (!_isAllDay && _startTime != null) {
      final timeStr = _formatTimeOfDay(_startTime!);
      if (_selectedDueDate != null && _endTime != null) {
        final dueDay = DateTime(_selectedDueDate!.year, _selectedDueDate!.month,
            _selectedDueDate!.day);
        if (startDay.isAtSameMomentAs(dueDay)) {
          return "${DateFormat('MMM d').format(_selectedStartDate)}, $timeStr - ${_formatTimeOfDay(_endTime!)}";
        } else {
          return "${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d').format(_selectedDueDate!)}";
        }
      }
      return "${DateFormat('MMM d').format(_selectedStartDate)}, $timeStr";
    }

    if (_selectedDueDate != null && _isAllDay) {
      final dueDay = DateTime(_selectedDueDate!.year, _selectedDueDate!.month,
          _selectedDueDate!.day);
      if (!startDay.isAtSameMomentAs(dueDay)) {
        return "${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d').format(_selectedDueDate!)}";
      }
    }

    return DateFormat('MMM d').format(_selectedStartDate);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? AppColors.primary : Colors.grey, size: 18),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDateTimePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DateTimePickerModal(
        initialStartDate: _selectedStartDate,
        initialDueDate: _selectedDueDate,
        initialStartTime: _startTime,
        initialEndTime: _endTime,
        initialIsAllDay: _isAllDay,
        initialReminderTime: reminderTime,
        initialReminderDays: reminderDays,
        onConfirm:
            (start, due, startTime, endTime, isAllDay, reminder, remDays) {
          setState(() {
            _selectedStartDate = start;
            _selectedDueDate = due;
            _startTime = startTime;
            _endTime = endTime;
            _isAllDay = isAllDay;

            if (reminder != null && remDays != null) {
              DateTime reminderDateTime = DateTime(
                start.year,
                start.month,
                start.day,
                reminder.hour,
                reminder.minute,
              ).subtract(Duration(days: remDays));
              reminderTime = reminderDateTime;
            } else {
              reminderTime = null;
            }

            reminderDays = remDays;
          });
        },
      ),
    );
  }

  void _showPriorityBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Priority',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildPriorityOption(
                  1, 'Urgent & Important', Colors.red, setModalState),
              _buildPriorityOption(
                  2, 'Not Urgent & Important', Colors.orange, setModalState),
              _buildPriorityOption(
                  3, 'Urgent & Unimportant', Colors.blue, setModalState),
              _buildPriorityOption(
                  4, 'Not Urgent & Unimportant', Colors.green, setModalState),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child:
                      const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(
      int value, String label, Color color, StateSetter setModalState) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      ),
      title: Text(label, style: const TextStyle(color: Colors.black)),
      trailing: _selectedPriority == value
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _selectedPriority = _selectedPriority == value ? null : value;
        });
        setModalState(() {});
      },
    );
  }

  void _updateTask() async {
    if (_titleController.text.isEmpty) {
      Get.snackbar('Error', 'Title is required!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    DateTime startDateTime;
    DateTime? endDateTime;

    if (_startTime != null && !_isAllDay) {
      startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    } else {
      startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        0,
        0,
        0,
      );
    }

    if (_selectedDueDate != null) {
      if (_endTime != null && !_isAllDay) {
        endDateTime = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      } else {
        endDateTime = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          0,
          0,
          0,
        );
      }
    }

    Task updatedTask = Task(
      id: widget.taskId,
      title: _titleController.text,
      description:
          _noteController.text.isNotEmpty ? _noteController.text : null,
      categoryId: _selectedCategoryId,
      date: startDateTime,
      dueDate: endDateTime,
      priority: _hasPriority ? _selectedPriority : null,
      reminderTime: reminderTime,
      isCompleted: _isCompleted,
    );

    bool success = await taskController.updateTask(updatedTask);

    if (success) {
      Get.back();
      Get.snackbar('Success', 'Task updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    }
  }

  void _deleteTask() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      bool success = await taskController.deleteTask(taskId: widget.taskId);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Task deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
