import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:flutter_to_do_app/ui/widgets/date_time_picker_modal.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';

class AddTaskPage extends StatefulWidget {
  final int? initialCategoryId;

  const AddTaskPage({
    Key? key,
    this.initialCategoryId,
  }) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController taskController = Get.find<TaskController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedStartDate = DateTime.now();
  DateTime? _selectedDueDate; // nullable - có thể không có due date
  TimeOfDay? _startTime; // null = all day task
  TimeOfDay? _endTime;
  DateTime? reminderTime;
  int? reminderDays;

  bool _isAllDay = true; // Mặc định là all day task
  List<Category> listCategories = [];
  int? _selectedCategoryId;
  bool _hasPriority = false;
  bool _hasReminder = false;
  int? _selectedPriority;

  final Map<int, String> priorityLabels = {
    1: 'Urgent & Important',
    2: 'Not Urgent & Important',
    3: 'Urgent & Unimportant',
    4: 'Not Urgent & Unimportant',
  };

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return "Urgent & Important";
      case 2:
        return "Not Urgent & Important";
      case 3:
        return "Urgent & Unimportant";
      case 4:
        return "Not Urgent & Unimportant";
      default:
        return "None";
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
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

  @override
  void initState() {
    super.initState();

    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
      print("✅ Pre-selected category ID: $_selectedCategoryId");
    }

    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _validateData,
            child: const Text(
              "Save",
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Action Buttons Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Date/Time Button
                    _buildActionChip(
                      icon: Icons.calendar_today_outlined,
                      label: _buildDateLabel(),
                      isSelected: true,
                      onTap: () => showModalBottomSheet(
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
                          onConfirm: (start, due, startTime, endTime, isAllDay,
                              reminder, remDays) {
                            setState(() {
                              _selectedStartDate = start;
                              _selectedDueDate = due;
                              _startTime = startTime;
                              _endTime = endTime;
                              _isAllDay = isAllDay;
                              // reminderTime = reminder;
                              // reminderDays = remDays;
                              // ✅ XỬ LÝ: Tính toán reminderTime từ start date và remDays
                              if (reminder != null && remDays != null) {
                                // Tạo DateTime cho reminder = start date - remDays
                                DateTime reminderDateTime = DateTime(
                                  start.year,
                                  start.month,
                                  start.day,
                                  reminder.hour,
                                  reminder.minute,
                                ).subtract(Duration(days: remDays));

                                reminderTime =
                                    reminderDateTime; // ✅ Lưu DateTime đã tính toán
                              } else {
                                reminderTime = null;
                              }

                              reminderDays = remDays;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Priority Button
                    _buildActionChip(
                      icon: Icons.flag_outlined,
                      label: _hasPriority
                          ? priorityLabels[_selectedPriority] ?? 'Priority'
                          : 'Priority',
                      isSelected: _hasPriority,
                      onTap: () {
                        _hasPriority = true;
                        _showPriorityBottomSheet();
                      },
                    ),

                    const SizedBox(width: 14),

                    // Reminders Button
                    // _buildActionChip(
                    //   icon: Icons.alarm,
                    //   label: 'Reminders',
                    //   isSelected: _hasReminder,
                    //   onTap: () {
                    //     // Implement reminders
                    //   },
                    // ),
                  ],
                ),
              ),

              // Category Dropdown
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.grey, width: 0.5), // viền dưới mảnh
                  ),
                  // borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category,
                            color: Colors.black, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          "List: ",
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
                            elevation: 4,
                            isExpanded: true,
                            underline: Container(height: 0),
                            items: listCategories
                                .map<DropdownMenuItem<int>>((Category cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(
                                  cat.title,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategoryId = newValue;
                                  print(
                                      "Selected Category ID: $_selectedCategoryId");
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
                  hintText: 'e.g. Call supplier tomorrow morning',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                ),
                maxLines: null,
              ),

              // Description Input
              TextField(
                controller: _noteController,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Description',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                ),
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(Duration(days: 1));
    final startDay = DateTime(_selectedStartDate.year, _selectedStartDate.month,
        _selectedStartDate.day);

    // Nếu là hôm nay và all day
    if (startDay.isAtSameMomentAs(today) && _isAllDay) {
      return 'Today';
    }

    // Nếu là ngày mai và all day
    if (startDay.isAtSameMomentAs(tomorrow) && _isAllDay) {
      return 'Tomorrow';
    }

    // Nếu có giờ cụ thể
    if (!_isAllDay && _startTime != null) {
      final timeStr = _formatTimeOfDay(_startTime!);
      if (_selectedDueDate != null && _endTime != null) {
        final dueDay = DateTime(_selectedDueDate!.year, _selectedDueDate!.month,
            _selectedDueDate!.day);
        if (startDay.isAtSameMomentAs(dueDay)) {
          // Cùng ngày: "Oct 22, 10:00 AM - 11:00 AM"
          return "${DateFormat('MMM d').format(_selectedStartDate)}, $timeStr - ${_formatTimeOfDay(_endTime!)}";
        } else {
          // Khác ngày: "Oct 22 - Oct 23"
          return "${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d').format(_selectedDueDate!)}";
        }
      }
      return "${DateFormat('MMM d').format(_selectedStartDate)}, $timeStr";
    }

    // Nếu có due date và all day
    if (_selectedDueDate != null && _isAllDay) {
      final dueDay = DateTime(_selectedDueDate!.year, _selectedDueDate!.month,
          _selectedDueDate!.day);
      if (!startDay.isAtSameMomentAs(dueDay)) {
        return "${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d').format(_selectedDueDate!)}";
      }
    }

    // Ngày khác
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
          const SizedBox(width: 2),
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

  Widget _buildWeekdayHeaders() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 40,
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayWidget(
    int day,
    DateTime date,
    DateTime selectedDate,
    Function(DateTime) onDateSelected, {
    required bool isCurrentMonth,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final selectedDateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    final isToday = dateOnly.isAtSameMomentAs(today);
    final isSelected = dateOnly.isAtSameMomentAs(selectedDateOnly);

    return InkWell(
      onTap: () {
        onDateSelected(date);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : isToday
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : isCurrentMonth
                      ? Colors.black
                      : Colors.grey[400],
              fontSize: 14,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickDateChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(color: AppColors.primary),
    );
  }

  // Method to format date for DB: "2025-10-09 14:06:00"
  String _formatDateTimeForDB(DateTime date, {TimeOfDay? time}) {
    if (time != null) {
      final dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } else {
      // All day task - set to midnight
      final dateTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    }
  }

  void _validateData() {
    if (_titleController.text.isEmpty) {
      _showErrorSnackBar("Title is required!");
      return;
    }

    // Create DateTime objects for DB
    DateTime startDateTime;
    DateTime? endDateTime;

    if (_startTime != null && !_isAllDay) {
      // Task có giờ cụ thể
      startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    } else {
      // All day task - set to midnight
      startDateTime = DateTime(
        _selectedStartDate.year,
        _selectedStartDate.month,
        _selectedStartDate.day,
        0,
        0,
        0,
      );
    }
    if (_endTime != null && _selectedDueDate == null) {
      _selectedDueDate = _selectedStartDate;
    }
    // Due date (nullable)
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

    DateTime? reminderDateTime = reminderTime;

    int? priorityToSend = _hasPriority ? _selectedPriority : null;

    Task newTask = Task(
      title: _titleController.text,
      description:
          _noteController.text.isNotEmpty ? _noteController.text : null,
      categoryId: _selectedCategoryId,
      date: startDateTime,
      dueDate: endDateTime,
      priority: priorityToSend,
      reminderTime: reminderDateTime,
    );

    print("✅ Creating task:");
    print("   Start: $startDateTime");
    print("   Due: $endDateTime");
    print("   Reminder: $reminderDateTime");
    print("   All Day: $_isAllDay");

    taskController.addTask(task: newTask);
    Get.back();
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red,
    );
  }

  Future<void> loadCategories() async {
    final categoryController = Get.find<CategoryController>();
    try {
      final categories = await CategoryService.fetchCategories();
      setState(() {
        listCategories = categoryController.categoryList;

        // ✅ Validate: nếu initialCategoryId không tồn tại trong list
        if (_selectedCategoryId != null) {
          final categoryExists =
              listCategories.any((c) => c.id == _selectedCategoryId);
          if (!categoryExists) {
            print(
                "⚠️ Category $_selectedCategoryId not found, fallback to first");
            _selectedCategoryId =
                listCategories.isNotEmpty ? listCategories.first.id : null;
          }
        } else {
          // Fallback: chọn category đầu tiên nếu chưa có gì được chọn
          _selectedCategoryId =
              listCategories.isNotEmpty ? listCategories.first.id : null;
        }
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to load categories",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set Priority',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (_hasPriority) ...[
                const SizedBox(height: 20),
                _buildPriorityOption(
                    1, 'Urgent & Important', Colors.red, setModalState),
                _buildPriorityOption(
                    2, 'Not Urgent & Important', Colors.orange, setModalState),
                _buildPriorityOption(
                    3, 'Urgent & Unimportant', Colors.blue, setModalState),
                _buildPriorityOption(
                    4, 'Not Urgent & Unimportant', Colors.green, setModalState),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      title: Text(label, style: const TextStyle(color: Colors.black)),
      trailing: _selectedPriority == value
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          if (_selectedPriority == value) {
            _selectedPriority = null; // Bỏ chọn nếu bấm lại option đang tick
          } else {
            _selectedPriority = value; // Chọn mới
          }
        });
        setModalState(() {});
      },
    );
  }
}
