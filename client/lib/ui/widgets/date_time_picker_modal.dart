// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import 'package:intl/intl.dart';

// class DateTimePickerModal extends StatefulWidget {
//   final DateTime initialStartDate;
//   final DateTime? initialDueDate;
//   final TimeOfDay? initialStartTime;
//   final TimeOfDay? initialEndTime;
//   final bool initialIsAllDay;
//   final TimeOfDay? initialReminderTime;
//   final int? initialReminderDays;

//   final Function(
//       DateTime startDate,
//       DateTime? dueDate,
//       TimeOfDay? startTime,
//       TimeOfDay? endTime,
//       bool isAllDay,
//       TimeOfDay? initialReminderTime) onConfirm;

//   const DateTimePickerModal({
//     Key? key,
//     required this.initialStartDate,
//     this.initialDueDate,
//     this.initialStartTime,
//     this.initialEndTime,
//     this.initialIsAllDay = true,
//     this.initialReminderTime,
//     this.initialReminderDays,
//     required this.onConfirm,
//   }) : super(key: key);

//   @override
//   State<DateTimePickerModal> createState() => _DateTimePickerModalState();
// }

// class _DateTimePickerModalState extends State<DateTimePickerModal> {
//   late DateTime tempStartDate;
//   DateTime? tempDueDate;
//   TimeOfDay? tempStartTime;
//   TimeOfDay? tempEndTime;
//   late bool tempIsAllDay;
//   String selectedTab = 'Date';
//   TimeOfDay? tempReminderTime;
//   String? selectedReminderOption;
//   bool isConstantReminder = false;

//   int customReminderDays = 0;
//   int customReminderHour = 9;
//   int customReminderMinute = 0;
//   String customReminderPeriod = 'AM';

//   @override
//   void initState() {
//     super.initState();
//     tempStartDate = widget.initialStartDate;
//     tempDueDate = widget.initialDueDate;
//     tempStartTime = widget.initialStartTime;
//     tempEndTime = widget.initialEndTime;
//     tempIsAllDay = widget.initialIsAllDay;
//     tempReminderTime = widget.initialReminderTime;

//     // ✅ THÊM: Khởi tạo customReminderDays từ initialReminderDays nếu có
//     if (widget.initialReminderDays != null) {
//       customReminderDays = widget.initialReminderDays!;
//     }

//     // ✅ THÊM: Khởi tạo giờ/phút từ initialReminderTime nếu có
//     if (widget.initialReminderTime != null) {
//       customReminderHour = widget.initialReminderTime!.hour;
//       customReminderMinute = widget.initialReminderTime!.minute;

//       // Xác định AM/PM
//       if (customReminderHour >= 12) {
//         customReminderPeriod = 'PM';
//       } else {
//         customReminderPeriod = 'AM';
//       }
//     }
//   }

//   String _formatTimeOfDay(TimeOfDay time) {
//     final now = DateTime.now();
//     final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
//     return DateFormat('HH:mm').format(dt);
//   }

//   // String _getReminderDisplayText() {
//   //   if (selectedReminderOption == null) return 'None';
//   //   if (selectedReminderOption == 'Custom' && tempReminderTime != null) {
//   //     return _formatTimeOfDay(tempReminderTime!);
//   //   }
//   //   return selectedReminderOption!;
//   // }
//   String _getReminderDisplayText() {
//     if (selectedReminderOption == null) return 'None';
//     if (selectedReminderOption == 'Custom' && tempReminderTime != null) {
//       // ✅ SỬA: Hiển thị cả số ngày và thời gian cho custom reminder
//       String timeStr = _formatTimeOfDay(tempReminderTime!);
//       if (customReminderDays == 0) {
//         return 'On the day ($timeStr)';
//       } else if (customReminderDays == 1) {
//         return '1 day early ($timeStr)';
//       } else if (customReminderDays == 7) {
//         return '1 week early ($timeStr)';
//       } else {
//         return '$customReminderDays days early ($timeStr)';
//       }
//     }
//     return selectedReminderOption!;
//   }

//   String _getCustomReminderLabel() {
//     if (selectedReminderOption != 'Custom') return 'Custom';

//     // Chuyển đổi hour về định dạng 12h để hiển thị
//     int displayHour = customReminderHour;
//     String period = customReminderPeriod;

//     if (customReminderHour > 12) {
//       displayHour = customReminderHour - 12;
//       period = 'PM';
//     } else if (customReminderHour == 12) {
//       period = 'PM';
//     } else if (customReminderHour == 0) {
//       displayHour = 12;
//       period = 'AM';
//     }

//     String timeStr =
//         '${displayHour.toString().padLeft(2, '0')}:${customReminderMinute.toString().padLeft(2, '0')} $period';

//     if (customReminderDays == 0) {
//       return 'Custom (On the day, $timeStr)';
//     } else if (customReminderDays == 1) {
//       return 'Custom (1 day early, $timeStr)';
//     } else {
//       return 'Custom ($customReminderDays days early, $timeStr)';
//     }
//   }

//   void _showReminderDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Reminder',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     _buildReminderOption('None', setDialogState),
//                     _buildReminderOption('On the day (09:00)', setDialogState),
//                     _buildReminderOption('1 day early (09:00)', setDialogState),
//                     _buildReminderOption(
//                         '2 days early (09:00)', setDialogState),
//                     _buildReminderOption(
//                         '3 days early (09:00)', setDialogState),
//                     _buildReminderOption(
//                         '1 week early (09:00)', setDialogState),
//                     ListTile(
//                       contentPadding: EdgeInsets.symmetric(horizontal: 0),
//                       title: Row(
//                         children: [
//                           Radio<String>(
//                             value: 'Custom',
//                             groupValue: selectedReminderOption,
//                             onChanged: (value) {
//                               _showCustomReminderDialog(setDialogState);
//                             },
//                             activeColor: AppColors.primary,
//                           ),
//                           Expanded(
//                             child: Text(
//                               _getCustomReminderLabel(),
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: Icon(Icons.chevron_right, color: Colors.grey),
//                       onTap: () {
//                         _showCustomReminderDialog(setDialogState);
//                       },
//                     ),
//                     Divider(),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             minimumSize: Size(0, 0),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             'CANCEL',
//                             style: TextStyle(color: AppColors.primary),
//                           ),
//                         ),
//                         TextButton(
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8, vertical: 4),
//                             minimumSize: Size(0, 0),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           onPressed: () {
//                             setState(() {});
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             'OK',
//                             style: TextStyle(color: AppColors.primary),
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildReminderOption(String option, StateSetter setDialogState) {
//     return RadioListTile<String>(
//       contentPadding: EdgeInsets.symmetric(horizontal: 0),
//       title: Text(option),
//       value: option,
//       groupValue: selectedReminderOption,
//       onChanged: (value) {
//         setDialogState(() {
//           selectedReminderOption = value;
//         });
//         setState(() {
//           selectedReminderOption = value;
//         });
//       },
//       activeColor: AppColors.primary,
//     );
//   }

//   void _showCustomReminderDialog(StateSetter parentSetState) {
//     int selectedDays = customReminderDays;
//     int selectedHour = customReminderHour == 0
//         ? 12
//         : (customReminderHour > 12
//             ? customReminderHour - 12
//             : customReminderHour);
//     int selectedMinute = customReminderMinute;
//     String selectedPeriod = customReminderPeriod;
//     String customSelectedTab = 'Day';

//     // ----- HOUR (1–12) -----
//     final List<int> hourValues = List.generate(12, (i) => i + 1);
//     final List<int> repeatedHours =
//         List.generate(12 * 5, (i) => hourValues[i % 12]);
//     final int middleHourIndex = (repeatedHours.length ~/ 2) -
//         ((repeatedHours.length ~/ 2) % 12) +
//         (selectedHour - 1);
//     final FixedExtentScrollController hourController =
//         FixedExtentScrollController(initialItem: middleHourIndex);

//     // ----- MINUTE (0–59) -----
//     final List<int> minuteValues = List.generate(60, (i) => i);
//     final List<int> repeatedMinutes =
//         List.generate(60 * 5, (i) => minuteValues[i % 60]);
//     final int middleMinuteIndex = (repeatedMinutes.length ~/ 2) -
//         ((repeatedMinutes.length ~/ 2) % 60) +
//         selectedMinute;
//     final FixedExtentScrollController minuteController =
//         FixedExtentScrollController(initialItem: middleMinuteIndex);

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//           builder: (context, setCustomDialogState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               setCustomDialogState(() {
//                                 customSelectedTab = 'Day';
//                               });
//                             },
//                             child: Container(
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               decoration: BoxDecoration(
//                                 border: Border(
//                                   bottom: BorderSide(
//                                     color: customSelectedTab == 'Day'
//                                         ? AppColors.primary
//                                         : Colors.transparent,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Day',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: customSelectedTab == 'Day'
//                                       ? AppColors.primary
//                                       : Colors.grey,
//                                   fontWeight: customSelectedTab == 'Day'
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               setCustomDialogState(() {
//                                 customSelectedTab = 'Week';
//                               });
//                             },
//                             child: Container(
//                               padding: EdgeInsets.symmetric(vertical: 8),
//                               decoration: BoxDecoration(
//                                 border: Border(
//                                   bottom: BorderSide(
//                                     color: customSelectedTab == 'Week'
//                                         ? AppColors.primary
//                                         : Colors.transparent,
//                                     width: 2,
//                                   ),
//                                 ),
//                               ),
//                               child: Text(
//                                 'Week',
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: customSelectedTab == 'Week'
//                                       ? AppColors.primary
//                                       : Colors.grey,
//                                   fontWeight: customSelectedTab == 'Week'
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     Container(
//                       height: 150,
//                       child: Row(
//                         children: [
//                           //date-------------
//                           Expanded(
//                             flex: 2,
//                             child: ListWheelScrollView.useDelegate(
//                               itemExtent: 40,
//                               perspective: 0.005,
//                               diameterRatio: 1.5,
//                               physics: FixedExtentScrollPhysics(),
//                               onSelectedItemChanged: (index) {
//                                 setCustomDialogState(() {
//                                   selectedDays = index;
//                                 });
//                               },
//                               childDelegate: ListWheelChildBuilderDelegate(
//                                   childCount: 61,
//                                   builder: (context, index) {
//                                     final day = 0 + index;
//                                     final isSelected = day == selectedDays;

//                                     return Center(
//                                       child: Text(
//                                         '$day days early',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: isSelected
//                                               ? FontWeight.bold
//                                               : FontWeight.normal,
//                                           color: isSelected
//                                               ? Colors.black
//                                               : Colors.grey,
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                             ),
//                           ),
//                           // hour
//                           Expanded(
//                             flex: 1,
//                             child: ListWheelScrollView.useDelegate(
//                               controller: hourController,
//                               itemExtent: 40,
//                               perspective: 0.005,
//                               diameterRatio: 1.5,
//                               physics: FixedExtentScrollPhysics(),
//                               onSelectedItemChanged: (index) {
//                                 final hour = repeatedHours[index];

//                                 setCustomDialogState(() {
//                                   selectedHour = hour;
//                                 });

//                                 if (index <= 3 ||
//                                     index >= repeatedHours.length - 3) {
//                                   Future.microtask(() {
//                                     hourController.jumpToItem(middleHourIndex);
//                                   });
//                                 }
//                               },
//                               childDelegate: ListWheelChildBuilderDelegate(
//                                 childCount: repeatedHours.length,
//                                 builder: (context, index) {
//                                   final hour = repeatedHours[index];
//                                   final isSelected = hour == selectedHour;

//                                   return Center(
//                                     child: Text(
//                                       hour.toString().padLeft(2, '0'),
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: isSelected
//                                             ? FontWeight.bold
//                                             : FontWeight.normal,
//                                         color: isSelected
//                                             ? Colors.black
//                                             : Colors.grey,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           //minute-----------------
//                           Expanded(
//                             flex: 1,
//                             child: ListWheelScrollView.useDelegate(
//                               controller: minuteController,
//                               itemExtent: 40,
//                               perspective: 0.005,
//                               diameterRatio: 1.5,
//                               physics: FixedExtentScrollPhysics(),
//                               onSelectedItemChanged: (index) {
//                                 final minute = repeatedMinutes[index];

//                                 setCustomDialogState(() {
//                                   selectedMinute = minute;
//                                 });

//                                 if (index <= 3 ||
//                                     index >= repeatedMinutes.length - 3) {
//                                   Future.microtask(() {
//                                     minuteController
//                                         .jumpToItem(middleMinuteIndex);
//                                   });
//                                 }
//                               },
//                               childDelegate: ListWheelChildBuilderDelegate(
//                                 childCount: repeatedMinutes.length,
//                                 builder: (context, index) {
//                                   final minute = repeatedMinutes[index];
//                                   final isSelected = minute == selectedMinute;

//                                   return Center(
//                                     child: Text(
//                                       minute.toString().padLeft(2, '0'),
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: isSelected
//                                             ? FontWeight.bold
//                                             : FontWeight.normal,
//                                         color: isSelected
//                                             ? Colors.black
//                                             : Colors.grey,
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           // am/pm
//                           Expanded(
//                             flex: 1,
//                             child: ListWheelScrollView.useDelegate(
//                               itemExtent: 40,
//                               perspective: 0.005,
//                               diameterRatio: 1.5,
//                               physics: FixedExtentScrollPhysics(),
//                               onSelectedItemChanged: (index) {
//                                 setCustomDialogState(() {
//                                   selectedPeriod = index == 0 ? 'AM' : 'PM';
//                                 });
//                               },
//                               childDelegate: ListWheelChildBuilderDelegate(
//                                   childCount: 2,
//                                   builder: (context, index) {
//                                     final period = index == 0 ? 'AM' : 'PM';
//                                     final isSelected = period == selectedPeriod;

//                                     return Center(
//                                       child: Text(
//                                         period,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: isSelected
//                                               ? FontWeight.bold
//                                               : FontWeight.normal,
//                                           color: isSelected
//                                               ? Colors.black
//                                               : Colors.grey,
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'The reminder has expired.',
//                         style: TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         TextButton(
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size(0, 0),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             'CANCEL',
//                             style: TextStyle(color: AppColors.primary),
//                           ),
//                         ),
//                         SizedBox(
//                           width: 20,
//                         ),
//                         TextButton(
//                           style: TextButton.styleFrom(
//                             padding: EdgeInsets.zero,
//                             minimumSize: Size(0, 0),
//                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                           ),
//                           onPressed: () {
//                             // Chuyển đổi về 24h format để lưu
//                             int hour24 = selectedHour;
//                             if (selectedPeriod == 'PM' && selectedHour != 12) {
//                               hour24 = selectedHour + 12;
//                             } else if (selectedPeriod == 'AM' &&
//                                 selectedHour == 12) {
//                               hour24 = 0;
//                             }

//                             parentSetState(() {
//                               selectedReminderOption = 'Custom';
//                               customReminderDays = selectedDays;
//                               customReminderHour = hour24;
//                               customReminderMinute = selectedMinute;
//                               customReminderPeriod = selectedPeriod;
//                               tempReminderTime = TimeOfDay(
//                                 hour: hour24,
//                                 minute: selectedMinute,
//                               );
//                             });

//                             setState(() {
//                               selectedReminderOption = 'Custom';
//                               customReminderDays = selectedDays;
//                               customReminderHour = hour24;
//                               customReminderMinute = selectedMinute;
//                               customReminderPeriod = selectedPeriod;
//                               tempReminderTime = TimeOfDay(
//                                 hour: hour24,
//                                 minute: selectedMinute,
//                               );
//                             });

//                             Navigator.pop(context);
//                           },
//                           child: Text(
//                             'DONE',
//                             style: TextStyle(color: AppColors.primary),
//                           ),
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: 0.75,
//       minChildSize: 0.5,
//       maxChildSize: 0.9,
//       builder: (context, controller) => Container(
//         padding: const EdgeInsets.all(20),
//         child: SingleChildScrollView(
//           controller: controller,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       TextButton(
//                         onPressed: () {
//                           setState(() => selectedTab = 'Date');
//                         },
//                         child: Text(
//                           'Date',
//                           style: TextStyle(
//                             color: selectedTab == 'Date'
//                                 ? AppColors.primary
//                                 : Colors.grey,
//                             fontWeight: selectedTab == 'Date'
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           setState(() => selectedTab = 'Duration');
//                         },
//                         child: Text(
//                           'Duration',
//                           style: TextStyle(
//                             color: selectedTab == 'Duration'
//                                 ? AppColors.primary
//                                 : Colors.grey,
//                             fontWeight: selectedTab == 'Duration'
//                                 ? FontWeight.bold
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.check, color: AppColors.primary),
//                     onPressed: () {
//                       widget.onConfirm(
//                         tempStartDate,
//                         tempDueDate,
//                         tempStartTime,
//                         tempEndTime,
//                         tempIsAllDay,
//                         tempReminderTime,

//                       );
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               if (selectedTab == 'Date') ...[
//                 _buildCalendarSection(tempStartDate, (date) {
//                   setState(() => tempStartDate = date);
//                 }),
//                 const SizedBox(height: 20),
//                 ListTile(
//                   leading: Icon(Icons.access_time, color: AppColors.primary),
//                   title:
//                       Text('Time', style: TextStyle(color: AppColors.primary)),
//                   trailing: Text(
//                     tempIsAllDay
//                         ? 'None'
//                         : _formatTimeOfDay(tempStartTime ?? TimeOfDay.now()),
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   onTap: () async {
//                     if (tempIsAllDay) {
//                       setState(() {
//                         tempIsAllDay = false;
//                         tempStartTime = TimeOfDay.now();
//                         tempEndTime = TimeOfDay(
//                           hour: TimeOfDay.now().hour + 1,
//                           minute: TimeOfDay.now().minute,
//                         );
//                       });
//                     } else {
//                       TimeOfDay? picked = await showTimePicker(
//                         context: context,
//                         initialTime: tempStartTime ?? TimeOfDay.now(),
//                       );
//                       if (picked != null) {
//                         setState(() => tempStartTime = picked);
//                       }
//                     }
//                   },
//                 ),
//                 ListTile(
//                   leading:
//                       Icon(Icons.notifications_none, color: AppColors.primary),
//                   title: Text('Reminder',
//                       style: TextStyle(color: AppColors.primary)),
//                   trailing: Text(
//                     _getReminderDisplayText(),
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   onTap: _showReminderDialog,
//                 ),
//                 ListTile(
//                   leading: Icon(Icons.repeat, color: AppColors.primary),
//                   title: Text('Repeat',
//                       style: TextStyle(color: AppColors.primary)),
//                   trailing: Text('None', style: TextStyle(color: Colors.grey)),
//                   onTap: () {},
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       setState(() {
//                         tempStartDate = DateTime.now();
//                         tempDueDate = null;
//                         tempStartTime = null;
//                         tempEndTime = null;
//                         tempIsAllDay = true;
//                         tempReminderTime = null;
//                         selectedReminderOption = null;
//                         isConstantReminder = false;
//                         customReminderDays = 0;
//                         customReminderHour = 9;
//                         customReminderMinute = 0;
//                         customReminderPeriod = 'AM';
//                       });
//                     },
//                     child: Text('CLEAR',
//                         style: TextStyle(
//                             color: Colors.red, fontWeight: FontWeight.bold)),
//                   ),
//                 ),
//               ] else ...[
//                 ListTile(
//                   title: Text('Start Date',
//                       style: TextStyle(color: AppColors.primary)),
//                   subtitle: Text(
//                       DateFormat('MMM d, yyyy').format(tempStartDate),
//                       style: TextStyle(color: Colors.grey)),
//                   onTap: () async {
//                     DateTime? picked = await showDatePicker(
//                       context: context,
//                       initialDate: tempStartDate,
//                       firstDate: DateTime(2020),
//                       lastDate: DateTime(2030),
//                     );
//                     if (picked != null) setState(() => tempStartDate = picked);
//                   },
//                 ),
//                 ListTile(
//                   title: Text('Due Date',
//                       style: TextStyle(color: AppColors.primary)),
//                   subtitle: Text(
//                     tempDueDate != null
//                         ? DateFormat('MMM d, yyyy').format(tempDueDate!)
//                         : 'None',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                   onTap: () async {
//                     DateTime? picked = await showDatePicker(
//                       context: context,
//                       initialDate: tempDueDate ?? tempStartDate,
//                       firstDate: tempStartDate,
//                       lastDate: DateTime(2030),
//                     );
//                     if (picked != null) setState(() => tempDueDate = picked);
//                   },
//                   trailing: tempDueDate != null
//                       ? IconButton(
//                           icon: Icon(Icons.clear, color: Colors.grey),
//                           onPressed: () => setState(() => tempDueDate = null),
//                         )
//                       : null,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarSection(
//       DateTime selectedDate, void Function(DateTime) onDateSelected) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(DateFormat('MMMM yyyy').format(selectedDate),
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             Row(
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.chevron_left),
//                   onPressed: () {
//                     onDateSelected(
//                         DateTime(selectedDate.year, selectedDate.month - 1, 1));
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.chevron_right),
//                   onPressed: () {
//                     onDateSelected(
//                         DateTime(selectedDate.year, selectedDate.month + 1, 1));
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         _buildCalendarGrid(selectedDate, onDateSelected),
//       ],
//     );
//   }

//   Widget _buildCalendarGrid(
//       DateTime selectedDate, void Function(DateTime) onDateSelected) {
//     final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
//     final lastDayOfMonth =
//         DateTime(selectedDate.year, selectedDate.month + 1, 0);
//     final int weekdayOffset = firstDayOfMonth.weekday % 7;

//     List<Widget> dayWidgets = [];

//     for (int i = 0; i < weekdayOffset; i++) {
//       dayWidgets.add(Container());
//     }

//     for (int day = 1; day <= lastDayOfMonth.day; day++) {
//       DateTime dayDate = DateTime(selectedDate.year, selectedDate.month, day);
//       dayWidgets.add(
//         GestureDetector(
//           onTap: () => onDateSelected(dayDate),
//           child: Container(
//             margin: EdgeInsets.all(2),
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: dayDate.day == selectedDate.day
//                   ? Colors.blue
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Text("$day",
//                 style: TextStyle(
//                     color: dayDate.day == selectedDate.day
//                         ? Colors.white
//                         : Colors.black)),
//           ),
//         ),
//       );
//     }

//     return GridView.count(
//       crossAxisCount: 7,
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       children: dayWidgets,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:intl/intl.dart';

class DateTimePickerModal extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime? initialDueDate;
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;
  final bool initialIsAllDay;
  final DateTime? initialReminderTime;
  // ✅ THÊM: Parameter để nhận số ngày nhắc trước từ bên ngoài
  final int? initialReminderDays;

  final Function(
      DateTime startDate,
      DateTime? dueDate,
      TimeOfDay? startTime,
      TimeOfDay? endTime,
      bool isAllDay,
      DateTime? reminderTime,
      int? reminderDays) onConfirm; // ✅ THÊM: reminderDays parameter

  const DateTimePickerModal({
    Key? key,
    required this.initialStartDate,
    this.initialDueDate,
    this.initialStartTime,
    this.initialEndTime,
    this.initialIsAllDay = true,
    this.initialReminderTime,
    this.initialReminderDays, // ✅ THÊM: Initialize parameter
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
  String selectedTab = 'Date';
  DateTime? tempReminderTime;
  String? selectedReminderOption;
  bool isConstantReminder = false;

  // Thêm biến để lưu thông tin custom reminder
  int customReminderDays = 0;
  int customReminderHour = 9;
  int customReminderMinute = 0;
  String customReminderPeriod = 'AM';

  @override
  void initState() {
    super.initState();
    tempStartDate = widget.initialStartDate;
    tempDueDate = widget.initialDueDate;
    tempStartTime = widget.initialStartTime;
    tempEndTime = widget.initialEndTime;
    tempIsAllDay = widget.initialIsAllDay;
    tempReminderTime = widget.initialReminderTime;

    // ✅ THÊM: Khởi tạo customReminderDays từ initialReminderDays nếu có
    if (widget.initialReminderDays != null) {
      customReminderDays = widget.initialReminderDays!;
    }

    // ✅ THÊM: Khởi tạo giờ/phút từ initialReminderTime nếu có
    if (widget.initialReminderTime != null) {
      customReminderHour = widget.initialReminderTime!.hour;
      customReminderMinute = widget.initialReminderTime!.minute;

      // Xác định AM/PM
      if (customReminderHour >= 12) {
        customReminderPeriod = 'PM';
      } else {
        customReminderPeriod = 'AM';
      }
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  String _getReminderDisplayText() {
    if (selectedReminderOption == null) return 'None';
    if (selectedReminderOption == 'Custom' && tempReminderTime != null) {
      // ✅ SỬA: Hiển thị cả số ngày và thời gian cho custom reminder
      // String timeStr = _formatTimeOfDay(tempReminderTime!);
      String timeStr = DateFormat('HH:mm').format(tempReminderTime!);
      if (customReminderDays == 0) {
        return 'On the day ($timeStr)';
      } else if (customReminderDays == 1) {
        return '1 day early ($timeStr)';
      } else if (customReminderDays == 7) {
        return '1 week early ($timeStr)';
      } else {
        return '$customReminderDays days early ($timeStr)';
      }
    }
    return selectedReminderOption!;
  }

  String _getCustomReminderLabel() {
    if (selectedReminderOption != 'Custom') return 'Custom';

    // Chuyển đổi hour về định dạng 12h để hiển thị
    int displayHour = customReminderHour;
    String period = customReminderPeriod;

    if (customReminderHour > 12) {
      displayHour = customReminderHour - 12;
      period = 'PM';
    } else if (customReminderHour == 12) {
      period = 'PM';
    } else if (customReminderHour == 0) {
      displayHour = 12;
      period = 'AM';
    }

    String timeStr =
        '${displayHour.toString().padLeft(2, '0')}:${customReminderMinute.toString().padLeft(2, '0')} $period';

    if (customReminderDays == 0) {
      return 'Custom (On the day, $timeStr)';
    } else if (customReminderDays == 1) {
      return 'Custom (1 day early, $timeStr)';
    } else {
      return 'Custom ($customReminderDays days early, $timeStr)';
    }
  }

  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Reminder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    _buildReminderOption('None', setDialogState),
                    _buildReminderOption('On the day (09:00)', setDialogState),
                    _buildReminderOption('1 day early (09:00)', setDialogState),
                    _buildReminderOption(
                        '2 days early (09:00)', setDialogState),
                    _buildReminderOption(
                        '3 days early (09:00)', setDialogState),
                    _buildReminderOption(
                        '1 week early (09:00)', setDialogState),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 0),
                      title: Row(
                        children: [
                          Radio<String>(
                            value: 'Custom',
                            groupValue: selectedReminderOption,
                            onChanged: (value) {
                              _showCustomReminderDialog(setDialogState);
                            },
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: Text(
                              _getCustomReminderLabel(),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        _showCustomReminderDialog(setDialogState);
                      },
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text(
                            'OK',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReminderOption(String option, StateSetter setDialogState) {
    return RadioListTile<String>(
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      title: Text(option),
      value: option,
      groupValue: selectedReminderOption,
      onChanged: (value) {
        setDialogState(() {
          selectedReminderOption = value;
        });
        setState(() {
          selectedReminderOption = value;

          // ✅ SỬA: Tạo DateTime thay vì TimeOfDay cho preset options
          if (value == 'None') {
            tempReminderTime = null;
            customReminderDays = 0;
          } else if (value == 'On the day (09:00)') {
            customReminderDays = 0;
            customReminderHour = 9;
            customReminderMinute = 0;
            customReminderPeriod = 'AM';
            // ✅ Tạo DateTime
            tempReminderTime = DateTime(
              tempStartDate.year,
              tempStartDate.month,
              tempStartDate.day,
              9,
              0,
            );
          } else if (value == '1 day early (09:00)') {
            customReminderDays = 1;
            customReminderHour = 9;
            customReminderMinute = 0;
            customReminderPeriod = 'AM';
            // ✅ Tạo DateTime và trừ 1 ngày
            tempReminderTime = DateTime(
              tempStartDate.year,
              tempStartDate.month,
              tempStartDate.day,
              9,
              0,
            ).subtract(Duration(days: 1));
          } else if (value == '2 days early (09:00)') {
            customReminderDays = 2;
            customReminderHour = 9;
            customReminderMinute = 0;
            customReminderPeriod = 'AM';
            tempReminderTime = DateTime(
              tempStartDate.year,
              tempStartDate.month,
              tempStartDate.day,
              9,
              0,
            ).subtract(Duration(days: 2));
          } else if (value == '3 days early (09:00)') {
            customReminderDays = 3;
            customReminderHour = 9;
            customReminderMinute = 0;
            customReminderPeriod = 'AM';
            tempReminderTime = DateTime(
              tempStartDate.year,
              tempStartDate.month,
              tempStartDate.day,
              9,
              0,
            ).subtract(Duration(days: 3));
          } else if (value == '1 week early (09:00)') {
            customReminderDays = 7;
            customReminderHour = 9;
            customReminderMinute = 0;
            customReminderPeriod = 'AM';
            tempReminderTime = DateTime(
              tempStartDate.year,
              tempStartDate.month,
              tempStartDate.day,
              9,
              0,
            ).subtract(Duration(days: 7));
          }
        });
      },
      activeColor: AppColors.primary,
    );
  }

  void _showCustomReminderDialog(StateSetter parentSetState) {
    int selectedDays = customReminderDays;
    int selectedHour = customReminderHour == 0
        ? 12
        : (customReminderHour > 12
            ? customReminderHour - 12
            : customReminderHour);
    int selectedMinute = customReminderMinute;
    String selectedPeriod = customReminderPeriod;
    String customSelectedTab = 'Day';

    // ----- HOUR (1–12) -----
    final List<int> hourValues = List.generate(12, (i) => i + 1);
    final List<int> repeatedHours =
        List.generate(12 * 5, (i) => hourValues[i % 12]);
    final int middleHourIndex = (repeatedHours.length ~/ 2) -
        ((repeatedHours.length ~/ 2) % 12) +
        (selectedHour - 1);
    final FixedExtentScrollController hourController =
        FixedExtentScrollController(initialItem: middleHourIndex);

    // ----- MINUTE (0–59) -----
    final List<int> minuteValues = List.generate(60, (i) => i);
    final List<int> repeatedMinutes =
        List.generate(60 * 5, (i) => minuteValues[i % 60]);
    final int middleMinuteIndex = (repeatedMinutes.length ~/ 2) -
        ((repeatedMinutes.length ~/ 2) % 60) +
        selectedMinute;
    final FixedExtentScrollController minuteController =
        FixedExtentScrollController(initialItem: middleMinuteIndex);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setCustomDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setCustomDialogState(() {
                                customSelectedTab = 'Day';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: customSelectedTab == 'Day'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Day',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: customSelectedTab == 'Day'
                                      ? AppColors.primary
                                      : Colors.grey,
                                  fontWeight: customSelectedTab == 'Day'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Expanded(
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       setCustomDialogState(() {
                        //         customSelectedTab = 'Week';
                        //       });
                        //     },
                        //     child: Container(
                        //       padding: EdgeInsets.symmetric(vertical: 8),
                        //       decoration: BoxDecoration(
                        //         border: Border(
                        //           bottom: BorderSide(
                        //             color: customSelectedTab == 'Week'
                        //                 ? AppColors.primary
                        //                 : Colors.transparent,
                        //             width: 2,
                        //           ),
                        //         ),
                        //       ),
                        //       child: Text(
                        //         'Week',
                        //         textAlign: TextAlign.center,
                        //         style: TextStyle(
                        //           color: customSelectedTab == 'Week'
                        //               ? AppColors.primary
                        //               : Colors.grey,
                        //           fontWeight: customSelectedTab == 'Week'
                        //               ? FontWeight.bold
                        //               : FontWeight.normal,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Expanded(
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: null, // Disable tap
                                // child: Opacity(
                                // opacity: 0.5, // Làm mờ để thể hiện disabled
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Week',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                // ),
                              ),
                              Positioned(
                                top: 0,
                                right: 8,
                                child: Transform.rotate(
                                  angle: 0.6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'SOON',
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 150,
                      child: Row(
                        children: [
                          //date-------------
                          Expanded(
                            flex: 2,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setCustomDialogState(() {
                                  selectedDays = index;
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 61,
                                  builder: (context, index) {
                                    final day = 0 + index;
                                    final isSelected = day == selectedDays;

                                    return Center(
                                      child: Text(
                                        '$day days early',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                          // hour
                          Expanded(
                            flex: 1,
                            child: ListWheelScrollView.useDelegate(
                              controller: hourController,
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                final hour = repeatedHours[index];

                                setCustomDialogState(() {
                                  selectedHour = hour;
                                });

                                if (index <= 3 ||
                                    index >= repeatedHours.length - 3) {
                                  Future.microtask(() {
                                    hourController.jumpToItem(middleHourIndex);
                                  });
                                }
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: repeatedHours.length,
                                builder: (context, index) {
                                  final hour = repeatedHours[index];
                                  final isSelected = hour == selectedHour;

                                  return Center(
                                    child: Text(
                                      hour.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          //minute-----------------
                          Expanded(
                            flex: 1,
                            child: ListWheelScrollView.useDelegate(
                              controller: minuteController,
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                final minute = repeatedMinutes[index];

                                setCustomDialogState(() {
                                  selectedMinute = minute;
                                });

                                if (index <= 3 ||
                                    index >= repeatedMinutes.length - 3) {
                                  Future.microtask(() {
                                    minuteController
                                        .jumpToItem(middleMinuteIndex);
                                  });
                                }
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: repeatedMinutes.length,
                                builder: (context, index) {
                                  final minute = repeatedMinutes[index];
                                  final isSelected = minute == selectedMinute;

                                  return Center(
                                    child: Text(
                                      minute.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // am/pm
                          Expanded(
                            flex: 1,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.5,
                              physics: FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setCustomDialogState(() {
                                  selectedPeriod = index == 0 ? 'AM' : 'PM';
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 2,
                                  builder: (context, index) {
                                    final period = index == 0 ? 'AM' : 'PM';
                                    final isSelected = period == selectedPeriod;

                                    return Center(
                                      child: Text(
                                        period,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey,
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // SizedBox(height: 16),
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Text(
                    //     'The reminder has expired.',
                    //     style: TextStyle(color: Colors.red, fontSize: 12),
                    //   ),
                    // ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            // Chuyển đổi về 24h format để lưu
                            int hour24 = selectedHour;
                            if (selectedPeriod == 'PM' && selectedHour != 12) {
                              hour24 = selectedHour + 12;
                            } else if (selectedPeriod == 'AM' &&
                                selectedHour == 12) {
                              hour24 = 0;
                            }

                            // ✅ SỬA: Tạo DateTime thay vì TimeOfDay
                            DateTime reminderDateTime = DateTime(
                              tempStartDate.year,
                              tempStartDate.month,
                              tempStartDate.day,
                              hour24,
                              selectedMinute,
                            ).subtract(Duration(days: selectedDays));

                            parentSetState(() {
                              selectedReminderOption = 'Custom';
                              customReminderDays = selectedDays;
                              customReminderHour = hour24;
                              customReminderMinute = selectedMinute;
                              customReminderPeriod = selectedPeriod;
                              tempReminderTime =
                                  reminderDateTime; // ✅ Lưu DateTime
                            });

                            setState(() {
                              selectedReminderOption = 'Custom';
                              customReminderDays = selectedDays;
                              customReminderHour = hour24;
                              customReminderMinute = selectedMinute;
                              customReminderPeriod = selectedPeriod;
                              tempReminderTime =
                                  reminderDateTime; // ✅ Lưu DateTime
                            });

                            Navigator.pop(context);
                          },
                          child: Text(
                            'DONE',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                      // ✅ SỬA: Thêm customReminderDays vào onConfirm
                      widget.onConfirm(
                        tempStartDate,
                        tempDueDate,
                        tempStartTime,
                        tempEndTime,
                        tempIsAllDay,
                        tempReminderTime,
                        selectedReminderOption != null
                            ? customReminderDays
                            : null,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (selectedTab == 'Date') ...[
                _buildCalendarSection(tempStartDate, (date) {
                  setState(() => tempStartDate = date);
                }),
                const SizedBox(height: 20),
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
                ListTile(
                  leading:
                      Icon(Icons.notifications_none, color: AppColors.primary),
                  title: Text('Reminder',
                      style: TextStyle(color: AppColors.primary)),
                  trailing: Text(
                    _getReminderDisplayText(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: _showReminderDialog,
                ),
                // ListTile(
                //   leading: Icon(Icons.repeat, color: AppColors.primary),
                //   title: Text('Repeat',
                //       style: TextStyle(color: AppColors.primary)),
                //   trailing: Text('None', style: TextStyle(color: Colors.grey)),
                //   onTap: () {},
                // ),
                Stack(
                  children: [
                    ListTile(
                      leading: Icon(Icons.repeat, color: AppColors.primary),
                      title: Text('Repeat',
                          style: TextStyle(color: AppColors.primary)),
                      trailing:
                          Text('None', style: TextStyle(color: Colors.grey)),
                      onTap: () {},
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Transform.rotate(
                        angle: 0.6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SOON',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                        selectedReminderOption = null;
                        isConstantReminder = false;
                        customReminderDays = 0;
                        customReminderHour = 9;
                        customReminderMinute = 0;
                        customReminderPeriod = 'AM';
                      });
                    },
                    child: Text('CLEAR',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              ] else ...[
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

  Widget _buildCalendarGrid(
      DateTime selectedDate, void Function(DateTime) onDateSelected) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final int weekdayOffset = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(Container());
    }

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
