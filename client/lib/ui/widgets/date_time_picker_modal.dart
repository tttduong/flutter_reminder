import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:intl/intl.dart';

class DateTimePickerModal extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime? initialDueDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final bool initialIsAllDay;
  final TimeOfDay? initialReminderTime;

  final Function(
      DateTime startDate,
      DateTime? dueDate,
      TimeOfDay? startTime,
      TimeOfDay? endTime,
      bool isAllDay,
      TimeOfDay? initialReminderTime) onConfirm;

  const DateTimePickerModal({
    Key? key,
    required this.initialStartDate,
    this.initialDueDate,
    this.initialStartTime,
    this.initialEndTime,
    this.initialIsAllDay = true,
    this.initialReminderTime,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<DateTimePickerModal> createState() => _DateTimePickerModalState();
}

class _DateTimePickerModalState extends State<DateTimePickerModal> {
  late DateTime tempStartDate;
  DateTime? tempDueDate;
  TimeOfDay? tempStartTime;
  TimeOfDay? tempEndTime;
  late bool tempIsAllDay;
  String selectedTab = 'Date'; // Date or Duration
  TimeOfDay? tempReminderTime;

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.initialStartDate;
    tempDueDate = widget.initialDueDate;
    tempStartTime = widget.initialStartTime;
    tempEndTime = widget.initialEndTime;
    tempIsAllDay = widget.initialIsAllDay;
    tempReminderTime = widget.initialReminderTime;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, controller) => Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with tabs and confirm
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() => selectedTab = 'Date');
                        },
                        child: Text(
                          'Date',
                          style: TextStyle(
                            color: selectedTab == 'Date'
                                ? AppColors.primary
                                : Colors.grey,
                            fontWeight: selectedTab == 'Date'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => selectedTab = 'Duration');
                        },
                        child: Text(
                          'Duration',
                          style: TextStyle(
                            color: selectedTab == 'Duration'
                                ? AppColors.primary
                                : Colors.grey,
                            fontWeight: selectedTab == 'Duration'
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: AppColors.primary),
                    onPressed: () {
                      widget.onConfirm(
                        tempStartDate,
                        tempDueDate,
                        tempStartTime,
                        tempEndTime,
                        tempIsAllDay,
                        tempReminderTime,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (selectedTab == 'Date') ...[
                // Calendar (simplified)
                // _buildCalendarSection(),

                _buildCalendarSection(tempStartDate, (date) {
                  setState(() => tempStartDate = date);
                }),
                const SizedBox(height: 20),

                // Time
                ListTile(
                  leading: Icon(Icons.access_time, color: AppColors.primary),
                  title:
                      Text('Time', style: TextStyle(color: AppColors.primary)),
                  trailing: Text(
                    tempIsAllDay
                        ? 'None'
                        : _formatTimeOfDay(tempStartTime ?? TimeOfDay.now()),
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    if (tempIsAllDay) {
                      setState(() {
                        tempIsAllDay = false;
                        tempStartTime = TimeOfDay.now();
                        tempEndTime = TimeOfDay(
                          hour: TimeOfDay.now().hour + 1,
                          minute: TimeOfDay.now().minute,
                        );
                      });
                    } else {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: tempStartTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => tempStartTime = picked);
                      }
                    }
                  },
                ),

                // Reminder & Repeat placeholders
                // Reminder
                ListTile(
                  leading:
                      Icon(Icons.notifications_none, color: AppColors.primary),
                  title: Text('Reminder',
                      style: TextStyle(color: AppColors.primary)),
                  trailing: Text(
                    tempReminderTime != null
                        ? _formatTimeOfDay(tempReminderTime!)
                        : 'None',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    // Chọn giờ cho reminder
                    TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: tempReminderTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => tempReminderTime = picked);
                    }
                  },
                ),

                ListTile(
                  leading: Icon(Icons.repeat, color: AppColors.primary),
                  title: Text('Repeat',
                      style: TextStyle(color: AppColors.primary)),
                  trailing: Text('None', style: TextStyle(color: Colors.grey)),
                  onTap: () {},
                ),

                const SizedBox(height: 20),

                // Clear
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        tempStartDate = DateTime.now();
                        tempDueDate = null;
                        tempStartTime = null;
                        tempEndTime = null;
                        tempIsAllDay = true;
                        tempReminderTime = null;
                      });
                    },
                    child: Text('CLEAR',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
                // Duration tab
                ListTile(
                  title: Text('Start Date',
                      style: TextStyle(color: AppColors.primary)),
                  subtitle: Text(
                      DateFormat('MMM d, yyyy').format(tempStartDate),
                      style: TextStyle(color: Colors.grey)),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: tempStartDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => tempStartDate = picked);
                  },
                ),
                ListTile(
                  title: Text('Due Date',
                      style: TextStyle(color: AppColors.primary)),
                  subtitle: Text(
                    tempDueDate != null
                        ? DateFormat('MMM d, yyyy').format(tempDueDate!)
                        : 'None',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: tempDueDate ?? tempStartDate,
                      firstDate: tempStartDate,
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => tempDueDate = picked);
                  },
                  trailing: tempDueDate != null
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => setState(() => tempDueDate = null),
                        )
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ================= Calendar Section =================
  Widget _buildCalendarSection(
      DateTime selectedDate, void Function(DateTime) onDateSelected) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMMM yyyy').format(selectedDate),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    onDateSelected(
                        DateTime(selectedDate.year, selectedDate.month - 1, 1));
                  },
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    onDateSelected(
                        DateTime(selectedDate.year, selectedDate.month + 1, 1));
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildCalendarGrid(selectedDate, onDateSelected),
      ],
    );
  }

  // ================= Calendar Grid =================
  Widget _buildCalendarGrid(
      DateTime selectedDate, void Function(DateTime) onDateSelected) {
    // tính ngày đầu tuần của tháng
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final int weekdayOffset = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // thêm ngày trống trước ngày đầu tháng
    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(Container());
    }

    // thêm ngày thực tế
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      DateTime dayDate = DateTime(selectedDate.year, selectedDate.month, day);
      dayWidgets.add(
        GestureDetector(
          onTap: () => onDateSelected(dayDate),
          child: Container(
            margin: EdgeInsets.all(2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dayDate.day == selectedDate.day
                  ? Colors.blue
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text("$day",
                style: TextStyle(
                    color: dayDate.day == selectedDate.day
                        ? Colors.white
                        : Colors.black)),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }
}
