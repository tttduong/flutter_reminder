// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/controller/task_controller.dart';
// import 'package:flutter_to_do_app/data/services/category_service.dart';
// import 'package:flutter_to_do_app/ui/widgets/button.dart';
// import 'package:flutter_to_do_app/ui/widgets/input_field.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../data/models/category.dart';
// import '../../data/models/task.dart';
// import 'bottom_navbar_screen.dart';

// class AddTaskPage extends StatefulWidget {
//   const AddTaskPage({Key? key}) : super(key: key);

//   @override
//   State<AddTaskPage> createState() => _AddTaskPageState();
// }

// class _AddTaskPageState extends State<AddTaskPage> {
//   // final TaskController _taskController = Get.put(TaskController());
//   final TaskController taskController = Get.find<TaskController>();

//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   String _selectedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   String _startTime = DateFormat("hh:mm a").format(DateTime.now());
//   String _endTime = DateFormat("hh:mm a")
//       .format(DateTime.now().add(Duration(hours: 1))); // End time 1 hour later
//   bool _hasDate = false;
//   List<Category> listCategories = [];
//   int? _selectedCategoryId;
//   bool _hasPriority = false;
//   int _selectedPriority = 1;

//   String _getPriorityText(int priority) {
//     switch (priority) {
//       case 1:
//         return "Urgent & Important";
//       case 2:
//         return "Not Urgent & Important";
//       case 3:
//         return "Urgent & Unimportant";
//       case 4:
//         return "Urgent & Unimportant";
//       default:
//         return "None";
//     }
//   }

//   Color _getPriorityColor(int priority) {
//     switch (priority) {
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

//   @override
//   void initState() {
//     super.initState();
//     loadCategories();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: context.theme.scaffoldBackgroundColor,
//         appBar: _appBar(context),
//         body: Container(
//             padding: const EdgeInsets.only(left: 20, right: 20),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Add Task",
//                     //  style: headingStyle
//                   ),
//                   MyInputField(
//                     title: "Title",
//                     hint: "Enter title here",
//                     controller: _titleController,
//                   ),
//                   MyInputField(
//                     title: "Description",
//                     hint: "Enter your description",
//                     controller: _noteController,
//                   ),
// MyInputField(
//   title: "Category",
//   // hint: listCategories.isEmpty
//   //     ? "No category"
//   //     : listCategories
//   //         .firstWhere(
//   //           (cat) => cat.id == _selectedCategoryId,
//   //           orElse: () => listCategories.first,
//   //         )
//   //         .title,
//   widget: DropdownButton<int>(
//     value: _selectedCategoryId,
//     icon: const Icon(Icons.keyboard_arrow_down,
//         color: Colors.grey),
//     iconSize: 32,
//     elevation: 4,
//     items: listCategories
//         .map<DropdownMenuItem<int>>((Category cat) {
//       return DropdownMenuItem<int>(
//         value: cat.id,
//         child: Text(
//           cat.title,
//           style: const TextStyle(color: Colors.black),
//         ),
//       );
//     }).toList(),
//     underline: Container(height: 0),
//     onChanged: (int? newValue) {
//       if (newValue != null) {
//         setState(() {
//           _selectedCategoryId = newValue;
//           print("Selected Category ID: $_selectedCategoryId");
//         });
//       }
//     },
//   ),
// ),

//                   //Date & Time ---------------

//                   Container(
//                     margin: const EdgeInsets.only(top: 16, bottom: 6),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Set Date & Time",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         Switch(
//                           value: _hasDate,
//                           onChanged: (bool value) {
//                             setState(() {
//                               _hasDate = value;
//                             });
//                           },
//                           activeColor: Colors.blue,
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (_hasDate) ...[
//                     Row(
//                       children: [
//                         Expanded(
//                           child: MyInputField(
//                               title: "Start Date",
//                               hint: _selectedDate,
//                               widget: IconButton(
//                                   icon: Icon(Icons.calendar_today_outlined,
//                                       color: Colors.grey),
//                                   onPressed: () {
//                                     _getDateFromUser(isStartDate: true);
//                                   })),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                             child: MyInputField(
//                                 title: "Start Time",
//                                 hint: _startTime,
//                                 widget: IconButton(
//                                   onPressed: () {
//                                     _getTimeFromUser(isStartTime: true);
//                                   },
//                                   icon: Icon(Icons.access_time_rounded),
//                                   color: Colors.grey,
//                                 ))),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: MyInputField(
//                               title: "End Date",
//                               hint: _selectedEndDate,
//                               widget: IconButton(
//                                   icon: Icon(Icons.calendar_today_outlined,
//                                       color: Colors.grey),
//                                   onPressed: () {
//                                     _getDateFromUser(isStartDate: false);
//                                   })),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                             child: MyInputField(
//                                 title: "End Time",
//                                 hint: _endTime,
//                                 widget: IconButton(
//                                   onPressed: () {
//                                     _getTimeFromUser(isStartTime: false);
//                                   },
//                                   icon: Icon(Icons.access_time_rounded),
//                                   color: Colors.grey,
//                                 ))),
//                       ],
//                     ),
//                   ],
//                   SizedBox(height: 20),

//                   //Priority ---------------

//                   Container(
//                     margin: const EdgeInsets.only(top: 16, bottom: 6),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Set Priority",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         Switch(
//                           value: _hasPriority,
//                           onChanged: (bool value) {
//                             setState(() {
//                               _hasPriority = value;
//                             });
//                           },
//                           activeColor: Colors.blue,
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (_hasPriority) ...[
//                     MyInputField(
//                       title: "Priority Level",
//                       hint: _getPriorityText(_selectedPriority),
//                       widget: DropdownButton<int>(
//                         value: _selectedPriority,
//                         icon: const Icon(Icons.keyboard_arrow_down,
//                             color: Colors.grey),
//                         iconSize: 32,
//                         elevation: 4,
//                         items: [
//                           DropdownMenuItem<int>(
//                             value: 1,
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 12,
//                                   height: 12,
//                                   decoration: BoxDecoration(
//                                     color: Colors.red,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text("Urgent & Important",
//                                     style: TextStyle(color: Colors.black)),
//                               ],
//                             ),
//                           ),
//                           DropdownMenuItem<int>(
//                             value: 2,
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 12,
//                                   height: 12,
//                                   decoration: BoxDecoration(
//                                     color: Colors.orange,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text("Not Urgent & Important",
//                                     style: TextStyle(color: Colors.black)),
//                               ],
//                             ),
//                           ),
//                           DropdownMenuItem<int>(
//                             value: 3,
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 12,
//                                   height: 12,
//                                   decoration: BoxDecoration(
//                                     color: Colors.blue,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text("Urgent & Unimportant",
//                                     style: TextStyle(color: Colors.black)),
//                               ],
//                             ),
//                           ),
//                           DropdownMenuItem<int>(
//                             value: 4,
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 12,
//                                   height: 12,
//                                   decoration: BoxDecoration(
//                                     color: Colors.green,
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text("Not Urgent & Unimportant",
//                                     style: TextStyle(color: Colors.black)),
//                               ],
//                             ),
//                           ),
//                         ],
//                         underline: Container(height: 0),
//                         onChanged: (int? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               _selectedPriority = newValue;
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                   SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       MyButton(
//                           label: "Create Task", onTap: () => _validateData()),
//                     ],
//                   )
//                 ],
//               ),
//             )));
//   }

//   _validateData() {
//     if (_titleController.text.isNotEmpty) {
//       // Combine date and time for start date
//       DateTime? startDateTime;
//       DateTime? endDateTime;

//       if (_hasDate) {
//         try {
//           // Parse start date and time
//           DateTime startDate = DateFormat('yyyy-MM-dd').parse(_selectedDate);
//           TimeOfDay startTimeOfDay = _parseTimeOfDay(_startTime);
//           startDateTime = DateTime(
//             startDate.year,
//             startDate.month,
//             startDate.day,
//             startTimeOfDay.hour,
//             startTimeOfDay.minute,
//           );

//           // Parse end date and time
//           DateTime endDate = DateFormat('yyyy-MM-dd').parse(_selectedEndDate);
//           TimeOfDay endTimeOfDay = _parseTimeOfDay(_endTime);
//           endDateTime = DateTime(
//             endDate.year,
//             endDate.month,
//             endDate.day,
//             endTimeOfDay.hour,
//             endTimeOfDay.minute,
//           );
//         } catch (e) {
//           print("Error parsing date/time: $e");
//           _showErrorSnackBar("Invalid date or time format");
//           return;
//         }
//       }

//       // Determine priority value to send
//       int? priorityToSend = _hasPriority ? _selectedPriority : null;

//       // Create task object
//       Task newTask = Task(
//         title: _titleController.text,
//         description:
//             _noteController.text.isNotEmpty ? _noteController.text : null,
//         categoryId: _selectedCategoryId,
//         date: startDateTime, // start date time
//         dueDate: endDateTime, // end date time
//         priority: priorityToSend, // Send priority value or null
//       );

//       print("Creating task with priority: $priorityToSend"); // Debug log

//       // Add task using controller
//       taskController.addTask(task: newTask);

//       // Navigate back
//       Get.back();
//     } else {
//       _showErrorSnackBar("Title is required!");
//     }
//   }

// // Helper function to parse time string to TimeOfDay
//   TimeOfDay _parseTimeOfDay(String timeString) {
//     try {
//       DateTime dateTime = DateFormat("hh:mm a").parse(timeString);
//       return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
//     } catch (e) {
//       print("Error parsing time: $e");
//       // Return current time as fallback
//       return TimeOfDay.now();
//     }
//   }

// // Helper function to show error message
//   void _showErrorSnackBar(String message) {
//     Get.snackbar(
//       "Error",
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }

//   _addTaskToDb() async {
//     DateTime? startDateTime;
//     DateTime? endDateTime;

//     if (_hasDate) {
//       startDateTime = _combineDateTime(_selectedDate, _startTime);
//       endDateTime = _combineDateTime(_selectedEndDate, _endTime);
//     }

//     await taskController.addTask(
//       task: Task(
//         title: _titleController.text,
//         description: _noteController.text,
//         categoryId: _selectedCategoryId,
//         date: startDateTime,
//         dueDate: endDateTime,
//       ),
//     );

//     await Future.delayed(Duration(milliseconds: 500));
//     if (_selectedCategoryId != null) {
//       taskController.getTasksByCategory(_selectedCategoryId!);
//     }
//   }

//   // Helper method để combine date và time
//   DateTime _combineDateTime(String date, String time) {
//     DateTime dateOnly = DateFormat('yyyy-MM-dd').parse(date);

//     // Parse time (format: "9:30 AM" hoặc "09:30 AM")
//     DateFormat timeFormat = DateFormat("hh:mm a");
//     DateTime timeOnly = timeFormat.parse(time);

//     // Combine date và time
//     return DateTime(
//       dateOnly.year,
//       dateOnly.month,
//       dateOnly.day,
//       timeOnly.hour,
//       timeOnly.minute,
//     );
//   }

//   _appBar(BuildContext context) {
//     return AppBar(
//       elevation: 0,
//       backgroundColor: context.theme.scaffoldBackgroundColor,
//       leading: GestureDetector(
//         onTap: () {
//           Get.back();
//         },
//         child: Icon(
//           Icons.arrow_back_ios,
//           size: 20,
//         ),
//       ),
//     );
//   }

//   Future<void> loadCategories() async {
//     try {
//       final categories = await CategoryService.fetchCategories();
//       setState(() {
//         listCategories = categories;
//         if (categories.isNotEmpty) {
//           _selectedCategoryId = categories.first.id;
//         }
//       });
//     } catch (e) {
//       print("Error loading categories: $e");
//       Get.snackbar("Error", "Failed to load categories",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//     }
//   }

//   _getDateFromUser({required bool isStartDate}) async {
//     DateTime? pickerDate = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime.now().subtract(Duration(days: 365)),
//         lastDate: DateTime(2030));

//     if (pickerDate != null) {
//       setState(() {
//         if (isStartDate) {
//           _selectedDate = DateFormat('yyyy-MM-dd').format(pickerDate);
//           print('Start Date: $_selectedDate');
//         } else {
//           _selectedEndDate = DateFormat('yyyy-MM-dd').format(pickerDate);
//           print('End Date: $_selectedEndDate');
//         }
//       });
//     }
//   }

//   _getTimeFromUser({required bool isStartTime}) async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       initialEntryMode: TimePickerEntryMode.input,
//     );

//     if (pickedTime != null) {
//       // Convert TimeOfDay to formatted string
//       final now = DateTime.now();
//       final dateTime = DateTime(
//           now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
//       final formattedTime = DateFormat("hh:mm a").format(dateTime);

//       setState(() {
//         if (isStartTime) {
//           _startTime = formattedTime;
//           print('Start Time: $_startTime');
//         } else {
//           _endTime = formattedTime;
//           print('End Time: $_endTime');
//         }
//       });
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';

// class AddTaskPage extends StatefulWidget {
//   final int? initialCategoryId;

//   const AddTaskPage({
//     Key? key,
//     this.initialCategoryId,
//   }) : super(key: key);

//   @override
//   State<AddTaskPage> createState() => _AddTaskPageState();
// }

// class _AddTaskPageState extends State<AddTaskPage> {
//   final TaskController taskController = Get.find<TaskController>();
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   // String _selectedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   DateTime _selectedStartDate = DateTime.now();
//   DateTime? _selectedDueDate; // nullable - có thể không có due date
//   TimeOfDay? _startTime; // null = all day task
//   TimeOfDay? _endTime;
//   // String _startTime = DateFormat("hh:mm a").format(DateTime.now());
//   // String _endTime =
//   //     DateFormat("hh:mm a").format(DateTime.now().add(Duration(hours: 1)));
//   bool _isAllDay = true; // Mặc định là all day task
//   bool _hasDate = false;
//   List<Category> listCategories = [];
//   int? _selectedCategoryId;
//   bool _hasPriority = false;
//   bool _hasReminder = false;
//   int? _selectedPriority;

//   final Map<int, String> priorityLabels = {
//     1: 'Urgent & Important',
//     2: 'Not Urgent & Important',
//     3: 'Urgent & Unimportant',
//     4: 'Not Urgent & Unimportant',
//   };

//   String _getPriorityText(int priority) {
//     switch (priority) {
//       case 1:
//         return "Urgent & Important";
//       case 2:
//         return "Not Urgent & Important";
//       case 3:
//         return "Urgent & Unimportant";
//       case 4:
//         return "Not Urgent & Unimportant";
//       default:
//         return "None";
//     }
//   }

//   Color _getPriorityColor(int priority) {
//     switch (priority) {
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

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Set categoryId NGAY nếu có initialCategoryId
//     if (widget.initialCategoryId != null) {
//       _selectedCategoryId = widget.initialCategoryId;
//       print("✅ Pre-selected category ID: $_selectedCategoryId");
//     }
//     // Load categories ngầm ở background
//     loadCategories();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: AppColors.background,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: AppColors.primary),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: _validateData,
//             child: const Text(
//               "Save",
//               style: TextStyle(color: AppColors.primary),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 8),
//               // Action Buttons Row
//               SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     // Date/Time Button
//                     _buildActionChip(
//                       icon: Icons.calendar_today_outlined,
//                       label: _buildDateLabel(),
//                       isSelected: true, // Luôn sáng vì mặc định là Today
//                       onTap: () => _showDateTimeBottomSheet(),
//                     ),

//                     const SizedBox(width: 14),

//                     // Priority Button

//                     // _buildActionChip(
//                     //   icon: Icons.flag_outlined,
//                     //   label: _hasPriority && _selectedPriority != null
//                     //       ? 'P$_selectedPriority'
//                     //       : 'Priority',
//                     //   isSelected: _hasPriority && _selectedPriority != null,
//                     //   onTap: () {
//                     //     _hasPriority = true;
//                     //     _showPriorityBottomSheet();
//                     //   },
//                     // ),
//                     _buildActionChip(
//                       icon: Icons.flag_outlined,
//                       label: _hasPriority
//                           ? priorityLabels[_selectedPriority] ?? 'Priority'
//                           : 'Priority',
//                       isSelected: _hasPriority,
//                       onTap: () {
//                         _hasPriority = true;
//                         _showPriorityBottomSheet();
//                       },
//                     ),

//                     const SizedBox(width: 14),

//                     // // Reminders Button (Placeholder)
//                     _buildActionChip(
//                       icon: Icons.alarm,
//                       label: _hasPriority ? 'Reminders' : 'Reminders',
//                       isSelected: _hasReminder,
//                       onTap: () {
//                         // Implement reminders
//                       },
//                     ),
//                   ],
//                 ),
//               ),

//               // Category Dropdown
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.transparent,
//                   border: Border(
//                     bottom: BorderSide(
//                         color: Colors.grey, width: 0.5), // viền dưới mảnh
//                   ),
//                   // borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.category,
//                             color: Colors.black, size: 16),
//                         const SizedBox(width: 2),
//                         Text(
//                           "List: ",
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: DropdownButton<int>(
//                             value: _selectedCategoryId,
//                             icon: Icon(Icons.keyboard_arrow_down,
//                                 color: Colors.grey[600]),
//                             iconSize: 24,
//                             elevation: 4,
//                             isExpanded: true,
//                             underline: Container(height: 0),
//                             items: listCategories
//                                 .map<DropdownMenuItem<int>>((Category cat) {
//                               return DropdownMenuItem<int>(
//                                 value: cat.id,
//                                 child: Text(
//                                   cat.title,
//                                   style: const TextStyle(color: Colors.black),
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (int? newValue) {
//                               if (newValue != null) {
//                                 setState(() {
//                                   _selectedCategoryId = newValue;
//                                   print(
//                                       "Selected Category ID: $_selectedCategoryId");
//                                 });
//                               }
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Title Input
//               TextField(
//                 controller: _titleController,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 18,
//                   fontWeight: FontWeight.w500,
//                 ),
//                 decoration: const InputDecoration(
//                   hintText: 'e.g. Call supplier tomorrow morning',
//                   hintStyle: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 18,
//                   ),
//                   border: InputBorder.none,
//                   filled: true, // bật nền
//                   fillColor: AppColors.background, // màu nền
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 2, vertical: 6),
//                 ),
//                 maxLines: null,
//               ),

//               TextField(
//                 controller: _noteController,
//                 style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 14,
//                 ),
//                 decoration: const InputDecoration(
//                   hintText: 'Description',
//                   hintStyle: TextStyle(
//                     color: Colors.grey,
//                     fontSize: 14,
//                   ),
//                   border: InputBorder.none,
//                   filled: true, // bật nền
//                   fillColor: AppColors.background, // màu nền
//                   contentPadding:
//                       EdgeInsets.symmetric(horizontal: 2, vertical: 6),
//                 ),
//                 maxLines: null,
//               ),
//               // Description Input

//               // const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _buildDateLabel() {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final tomorrow = today.add(Duration(days: 1));
//     final startDay = DateTime(_selectedStartDate.year, _selectedStartDate.month,
//         _selectedStartDate.day);

//     // Nếu là hôm nay và all day
//     if (startDay.isAtSameMomentAs(today) && _isAllDay) {
//       return 'Today';
//     }

//     // Nếu là ngày mai và all day
//     if (startDay.isAtSameMomentAs(tomorrow) && _isAllDay) {
//       return 'Tomorrow';
//     }

//     // Nếu có giờ cụ thể
//     if (!_isAllDay && _startTime != null) {
//       final timeStr = _formatTimeOfDay(_startTime!);
//       if (_selectedDueDate != null && _endTime != null) {
//         final dueDay = DateTime(_selectedDueDate!.year, _selectedDueDate!.month,
//             _selectedDueDate!.day);
//         if (startDay.isAtSameMomentAs(dueDay)) {
//           // Cùng ngày: "Oct 22, 10:00 AM - 11:00 AM"
//           return "${DateFormat('MMM d').format(_selectedStartDate)}, $timeStr - ${_formatTimeOfDay(_endTime!)}";
//         } else {
//           // Khác ngày: "Oct 22 - Oct 23"
//           return "${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d').format(_selectedDueDate!)}";
//         }
//       }
//       return "${DateFormat('MMM d').format(_selectedStartDate)}, $timeStr";
//     }

//     // Nếu có due date và all day
//     if (_selectedDueDate != null && _isAllDay) {
//       final dueDay = DateTime(_selectedDueDate!.year, _selectedDueDate!.month,
//           _selectedDueDate!.day);
//       if (!startDay.isAtSameMomentAs(dueDay)) {
//         return "${DateFormat('MMM d').format(_selectedStartDate)} - ${DateFormat('MMM d').format(_selectedDueDate!)}";
//       }
//     }

//     // Ngày khác
//     return DateFormat('MMM d').format(_selectedStartDate);
//   }

//   String _formatTimeOfDay(TimeOfDay time) {
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }

//   Widget _buildActionChip({
//     required IconData icon,
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon,
//               color: isSelected ? AppColors.primary : Colors.grey, size: 18),
//           const SizedBox(width: 2),
//           Text(
//             label,
//             style: TextStyle(
//               color: isSelected ? AppColors.primary : Colors.grey,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // String _buildDateRangeLabel() {
//   //   try {
//   //     final startDate = DateFormat('yyyy-MM-dd').parse(_selectedDate);
//   //     final endDate = DateFormat('yyyy-MM-dd').parse(_selectedEndDate);

//   //     // Nếu start = end -> chỉ hiển thị ngày và khoảng giờ
//   //     if (startDate.isAtSameMomentAs(endDate)) {
//   //       return "${DateFormat('MMM d').format(startDate)}, $_startTime - $_endTime";
//   //     } else {
//   //       // Nếu khác ngày -> hiển thị từ ngày này đến ngày kia
//   //       return "${DateFormat('MMM d').format(startDate)} - ${DateFormat('MMM d').format(endDate)}";
//   //     }
//   //   } catch (e) {
//   //     return "Invalid date";
//   //   }
//   // }

//   // void _showDateTimeBottomSheet() {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true, // 👈 Cho phép chiếm gần hết màn hình
//   //     backgroundColor: AppColors.background,
//   //     shape: const RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//   //     ),
//   //     builder: (context) => DraggableScrollableSheet(
//   //       expand: false,
//   //       initialChildSize: 0.6, // Chiếm 60% màn hình khi mở
//   //       minChildSize: 0.4,
//   //       maxChildSize: 0.9, // Kéo lên được tối đa 90%
//   //       builder: (_, controller) => StatefulBuilder(
//   //         builder: (context, setModalState) => Container(
//   //           padding: const EdgeInsets.all(20),
//   //           child: SingleChildScrollView(
//   //             controller: controller,
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                   children: [
//   //                     const Text(
//   //                       'Set Date & Time',
//   //                       style: TextStyle(
//   //                         color: AppColors.primary,
//   //                         fontSize: 18,
//   //                         fontWeight: FontWeight.bold,
//   //                       ),
//   //                     ),
//   //                     // Switch(
//   //                     //   value: _hasDate,
//   //                     //   onChanged: (value) {
//   //                     //     setState(() => _hasDate = value);
//   //                     //     setModalState(() {});
//   //                     //   },
//   //                     //   activeColor: Colors.blue,
//   //                     // ),
//   //                   ],
//   //                 ),
//   //                 const SizedBox(height: 20),

//   //                 // Luôn hiển thị Start Date
//   //                 ListTile(
//   //                   leading: const Icon(Icons.calendar_today,
//   //                       color: AppColors.primary),
//   //                   title: const Text('Start Date',
//   //                       style: TextStyle(color: AppColors.primary)),
//   //                   subtitle: Text(_selectedDate,
//   //                       style: const TextStyle(color: Colors.grey)),
//   //                   onTap: () async {
//   //                     DateTime? picked = await showDatePicker(
//   //                       context: context,
//   //                       initialDate: DateTime.now(),
//   //                       firstDate:
//   //                           DateTime.now().subtract(const Duration(days: 365)),
//   //                       lastDate: DateTime(2030),
//   //                     );
//   //                     if (picked != null) {
//   //                       setState(() => _selectedDate =
//   //                           DateFormat('yyyy-MM-dd').format(picked));
//   //                       setModalState(() {});
//   //                     }
//   //                   },
//   //                 ),

//   //                 // Start Time
//   //                 ListTile(
//   //                   leading:
//   //                       const Icon(Icons.access_time, color: AppColors.primary),
//   //                   title: const Text('Start Time',
//   //                       style: TextStyle(color: AppColors.primary)),
//   //                   subtitle: Text(_startTime,
//   //                       style: const TextStyle(color: Colors.grey)),
//   //                   onTap: () async {
//   //                     TimeOfDay? picked = await showTimePicker(
//   //                       context: context,
//   //                       initialTime: TimeOfDay.now(),
//   //                     );
//   //                     if (picked != null) {
//   //                       final now = DateTime.now();
//   //                       final dateTime = DateTime(now.year, now.month, now.day,
//   //                           picked.hour, picked.minute);
//   //                       setState(() => _startTime =
//   //                           DateFormat("hh:mm a").format(dateTime));
//   //                       setModalState(() {});
//   //                     }
//   //                   },
//   //                 ),

//   //                 // End Date
//   //                 ListTile(
//   //                   leading: const Icon(Icons.calendar_today,
//   //                       color: AppColors.primary),
//   //                   title: const Text('End Date',
//   //                       style: TextStyle(color: AppColors.primary)),
//   //                   subtitle: Text(_selectedEndDate,
//   //                       style: const TextStyle(color: Colors.grey)),
//   //                   onTap: () async {
//   //                     DateTime? picked = await showDatePicker(
//   //                       context: context,
//   //                       initialDate: DateTime.now(),
//   //                       firstDate:
//   //                           DateTime.now().subtract(const Duration(days: 365)),
//   //                       lastDate: DateTime(2030),
//   //                     );
//   //                     if (picked != null) {
//   //                       setState(() => _selectedEndDate =
//   //                           DateFormat('yyyy-MM-dd').format(picked));
//   //                       setModalState(() {});
//   //                     }
//   //                   },
//   //                 ),

//   //                 // End Time
//   //                 ListTile(
//   //                   leading:
//   //                       const Icon(Icons.access_time, color: AppColors.primary),
//   //                   title: const Text('End Time',
//   //                       style: TextStyle(color: AppColors.primary)),
//   //                   subtitle: Text(_endTime,
//   //                       style: const TextStyle(color: Colors.grey)),
//   //                   onTap: () async {
//   //                     TimeOfDay? picked = await showTimePicker(
//   //                       context: context,
//   //                       initialTime: TimeOfDay.now(),
//   //                     );
//   //                     if (picked != null) {
//   //                       final now = DateTime.now();
//   //                       final dateTime = DateTime(now.year, now.month, now.day,
//   //                           picked.hour, picked.minute);
//   //                       setState(() =>
//   //                           _endTime = DateFormat("hh:mm a").format(dateTime));
//   //                       setModalState(() {});
//   //                     }
//   //                   },
//   //                 ),

//   //                 const SizedBox(height: 10),
//   //                 // SizedBox(
//   //                 //   width: double.infinity,
//   //                 //   child: ElevatedButton(
//   //                 //     onPressed: () => Navigator.pop(context),
//   //                 //     style: ElevatedButton.styleFrom(
//   //                 //       backgroundColor: AppColors.primary,
//   //                 //       padding: const EdgeInsets.symmetric(vertical: 14),
//   //                 //       shape: RoundedRectangleBorder(
//   //                 //         borderRadius: BorderRadius.circular(8),
//   //                 //       ),
//   //                 //     ),
//   //                 //     child: const Text('Done',
//   //                 //         style: TextStyle(color: Colors.white)),
//   //                 //   ),
//   //                 // ),
//   //                 SizedBox(
//   //                   width: double.infinity,
//   //                   child: ElevatedButton(
//   //                     onPressed: () {
//   //                       setState(() {
//   //                         _hasDate = true; // ✅ Khi nhấn Done thì bật flag
//   //                       });
//   //                       Navigator.pop(context);
//   //                     },
//   //                     style: ElevatedButton.styleFrom(
//   //                       backgroundColor: AppColors.primary,
//   //                       padding: const EdgeInsets.symmetric(vertical: 14),
//   //                       shape: RoundedRectangleBorder(
//   //                         borderRadius: BorderRadius.circular(8),
//   //                       ),
//   //                     ),
//   //                     child: const Text(
//   //                       'Done',
//   //                       style: TextStyle(color: Colors.white),
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//   void _showDateTimeBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: AppColors.background,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => DraggableScrollableSheet(
//         expand: false,
//         initialChildSize: 0.75,
//         minChildSize: 0.5,
//         maxChildSize: 0.9,
//         builder: (_, controller) => StatefulBuilder(
//           builder: (context, setModalState) {
//             // Local variables for modal
//             DateTime tempStartDate = _selectedStartDate;
//             DateTime? tempDueDate = _selectedDueDate;
//             TimeOfDay? tempStartTime = _startTime;
//             TimeOfDay? tempEndTime = _endTime;
//             bool tempIsAllDay = _isAllDay;
//             String selectedTab = 'Date'; // Date or Duration

//             return Container(
//               padding: const EdgeInsets.all(20),
//               child: SingleChildScrollView(
//                 controller: controller,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header with tabs
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             TextButton(
//                               onPressed: () {
//                                 setModalState(() => selectedTab = 'Date');
//                               },
//                               child: Text(
//                                 'Date',
//                                 style: TextStyle(
//                                   color: selectedTab == 'Date'
//                                       ? AppColors.primary
//                                       : Colors.grey,
//                                   fontSize: 16,
//                                   fontWeight: selectedTab == 'Date'
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                             TextButton(
//                               onPressed: () {
//                                 setModalState(() => selectedTab = 'Duration');
//                               },
//                               child: Text(
//                                 'Duration',
//                                 style: TextStyle(
//                                   color: selectedTab == 'Duration'
//                                       ? AppColors.primary
//                                       : Colors.grey,
//                                   fontSize: 16,
//                                   fontWeight: selectedTab == 'Duration'
//                                       ? FontWeight.bold
//                                       : FontWeight.normal,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.check, color: AppColors.primary),
//                           onPressed: () {
//                             setState(() {
//                               _selectedStartDate = tempStartDate;
//                               _selectedDueDate = tempDueDate;
//                               _startTime = tempStartTime;
//                               _endTime = tempEndTime;
//                               _isAllDay = tempIsAllDay;
//                             });
//                             Navigator.pop(context);
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),

//                     if (selectedTab == 'Date') ...[
//                       // Calendar View (simplified - you should use a proper calendar widget)
//                       _buildCalendarSection(tempStartDate, (date) {
//                         setModalState(() => tempStartDate = date);
//                       }),

//                       const SizedBox(height: 20),

//                       // Time Section
//                       ListTile(
//                         leading:
//                             Icon(Icons.access_time, color: AppColors.primary),
//                         title: Text(
//                           'Time',
//                           style: TextStyle(color: AppColors.primary),
//                         ),
//                         trailing: Text(
//                           tempIsAllDay
//                               ? 'None'
//                               : _formatTimeOfDay(
//                                   tempStartTime ?? TimeOfDay.now()),
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         onTap: () async {
//                           if (tempIsAllDay) {
//                             // Chuyển sang có giờ
//                             setModalState(() {
//                               tempIsAllDay = false;
//                               tempStartTime = TimeOfDay.now();
//                               tempEndTime = TimeOfDay(
//                                 hour: TimeOfDay.now().hour + 1,
//                                 minute: TimeOfDay.now().minute,
//                               );
//                             });
//                           } else {
//                             // Chọn giờ
//                             TimeOfDay? picked = await showTimePicker(
//                               context: context,
//                               initialTime: tempStartTime ?? TimeOfDay.now(),
//                             );
//                             if (picked != null) {
//                               setModalState(() => tempStartTime = picked);
//                             }
//                           }
//                         },
//                       ),

//                       // Reminder
//                       ListTile(
//                         leading: Icon(Icons.notifications_none,
//                             color: AppColors.primary),
//                         title: Text(
//                           'Reminder',
//                           style: TextStyle(color: AppColors.primary),
//                         ),
//                         trailing: Text(
//                           'None',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         onTap: () {
//                           // Implement reminder
//                         },
//                       ),

//                       // Repeat
//                       ListTile(
//                         leading: Icon(Icons.repeat, color: AppColors.primary),
//                         title: Text(
//                           'Repeat',
//                           style: TextStyle(color: AppColors.primary),
//                         ),
//                         trailing: Text(
//                           'None',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         onTap: () {
//                           // Implement repeat
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // Clear button
//                       Center(
//                         child: TextButton(
//                           onPressed: () {
//                             setModalState(() {
//                               tempStartDate = DateTime.now();
//                               tempDueDate = null;
//                               tempStartTime = null;
//                               tempEndTime = null;
//                               tempIsAllDay = true;
//                             });
//                           },
//                           child: Text(
//                             'CLEAR',
//                             style: TextStyle(
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ] else ...[
//                       // Duration tab - Start date and Due date
//                       ListTile(
//                         title: Text('Start Date',
//                             style: TextStyle(color: AppColors.primary)),
//                         subtitle: Text(
//                           DateFormat('MMM d, yyyy').format(tempStartDate),
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         onTap: () async {
//                           DateTime? picked = await showDatePicker(
//                             context: context,
//                             initialDate: tempStartDate,
//                             firstDate: DateTime(2020),
//                             lastDate: DateTime(2030),
//                           );
//                           if (picked != null) {
//                             setModalState(() => tempStartDate = picked);
//                           }
//                         },
//                       ),

//                       ListTile(
//                         title: Text('Due Date',
//                             style: TextStyle(color: AppColors.primary)),
//                         subtitle: Text(
//                           tempDueDate != null
//                               ? DateFormat('MMM d, yyyy').format(tempDueDate!)
//                               : 'None',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         onTap: () async {
//                           DateTime? picked = await showDatePicker(
//                             context: context,
//                             initialDate: tempDueDate ?? tempStartDate,
//                             firstDate: tempStartDate,
//                             lastDate: DateTime(2030),
//                           );
//                           if (picked != null) {
//                             setModalState(() => tempDueDate = picked);
//                           }
//                         },
//                         trailing: tempDueDate != null
//                             ? IconButton(
//                                 icon: Icon(Icons.clear, color: Colors.grey),
//                                 onPressed: () {
//                                   setModalState(() => tempDueDate = null);
//                                 },
//                               )
//                             : null,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildCalendarSection(
//       DateTime selectedDate, Function(DateTime) onDateSelected) {
//     return Container(
//       padding: EdgeInsets.all(8),
//       child: Column(
//         children: [
//           // Month/Year header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 DateFormat('MMMM yyyy').format(selectedDate),
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     icon: Icon(Icons.chevron_left, color: AppColors.primary),
//                     onPressed: () {
//                       onDateSelected(DateTime(
//                         selectedDate.year,
//                         selectedDate.month - 1,
//                         selectedDate.day,
//                       ));
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.chevron_right, color: AppColors.primary),
//                     onPressed: () {
//                       onDateSelected(DateTime(
//                         selectedDate.year,
//                         selectedDate.month + 1,
//                         selectedDate.day,
//                       ));
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           // Quick date buttons
//           Wrap(
//             spacing: 8,
//             children: [
//               _buildQuickDateChip('Today', () {
//                 onDateSelected(DateTime.now());
//               }),
//               _buildQuickDateChip('Tomorrow', () {
//                 onDateSelected(DateTime.now().add(Duration(days: 1)));
//               }),
//               _buildQuickDateChip('Next Week', () {
//                 onDateSelected(DateTime.now().add(Duration(days: 7)));
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickDateChip(String label, VoidCallback onTap) {
//     return ActionChip(
//       label: Text(label),
//       onPressed: onTap,
//       backgroundColor: Colors.grey[200],
//       labelStyle: TextStyle(color: AppColors.primary),
//     );
//   }

// // Method to format date for DB: "2025-10-09 14:06:00"
//   String _formatDateTimeForDB(DateTime date, {TimeOfDay? time}) {
//     if (time != null) {
//       final dateTime = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         time.hour,
//         time.minute,
//       );
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
//     } else {
//       // All day task - set to midnight
//       final dateTime = DateTime(date.year, date.month, date.day, 0, 0, 0);
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
//     }
//   }

//   void _showPriorityBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: AppColors.background,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) => Container(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'Set Priority',
//                     style: TextStyle(
//                       color: AppColors.primary,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   // Switch(
//                   //   value: _hasPriority,
//                   //   onChanged: (value) {
//                   //     setState(() => _hasPriority = value);
//                   //     setModalState(() {});
//                   //   },
//                   //   activeColor: Colors.blue,
//                   // ),
//                 ],
//               ),
//               if (_hasPriority) ...[
//                 const SizedBox(height: 20),
//                 _buildPriorityOption(
//                     1, 'Urgent & Important', Colors.red, setModalState),
//                 _buildPriorityOption(
//                     2, 'Not Urgent & Important', Colors.orange, setModalState),
//                 _buildPriorityOption(
//                     3, 'Urgent & Unimportant', Colors.blue, setModalState),
//                 _buildPriorityOption(
//                     4, 'Not Urgent & Unimportant', Colors.green, setModalState),
//               ],
//               const SizedBox(height: 10),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child:
//                       const Text('Done', style: TextStyle(color: Colors.white)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPriorityOption(
//       int value, String label, Color color, StateSetter setModalState) {
//     return ListTile(
//       leading: Container(
//         width: 12,
//         height: 12,
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(6),
//         ),
//       ),
//       title: Text(label, style: const TextStyle(color: Colors.black)),
//       trailing: _selectedPriority == value
//           ? const Icon(Icons.check, color: Colors.blue)
//           : null,
//       onTap: () {
//         setState(() {
//           if (_selectedPriority == value) {
//             _selectedPriority = null; // Bỏ chọn nếu bấm lại option đang tick
//           } else {
//             _selectedPriority = value; // Chọn mới
//           }
//         });
//         setModalState(() {});
//       },
//     );
//   }

//   void _showCategoryBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xFF2A2A2A),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Select Category',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 20),
//             ...listCategories.map((category) => ListTile(
//                   title: Text(category.title,
//                       style: const TextStyle(color: Colors.white)),
//                   trailing: _selectedCategoryId == category.id
//                       ? const Icon(Icons.check, color: Colors.blue)
//                       : null,
//                   onTap: () {
//                     setState(() => _selectedCategoryId = category.id);
//                     Navigator.pop(context);
//                   },
//                 )),
//           ],
//         ),
//       ),
//     );
//   }

//   void _validateData() {
//     if (_titleController.text.isEmpty) {
//       _showErrorSnackBar("Title is required!");
//       return;
//     }

//     // Create DateTime objects for DB
//     DateTime startDateTime;
//     DateTime? endDateTime;

//     if (_startTime != null && !_isAllDay) {
//       // Task có giờ cụ thể
//       startDateTime = DateTime(
//         _selectedStartDate.year,
//         _selectedStartDate.month,
//         _selectedStartDate.day,
//         _startTime!.hour,
//         _startTime!.minute,
//       );
//     } else {
//       // All day task - set to midnight
//       startDateTime = DateTime(
//         _selectedStartDate.year,
//         _selectedStartDate.month,
//         _selectedStartDate.day,
//         0,
//         0,
//         0,
//       );
//     }

//     // Due date (nullable)
//     if (_selectedDueDate != null) {
//       if (_endTime != null && !_isAllDay) {
//         endDateTime = DateTime(
//           _selectedDueDate!.year,
//           _selectedDueDate!.month,
//           _selectedDueDate!.day,
//           _endTime!.hour,
//           _endTime!.minute,
//         );
//       } else {
//         endDateTime = DateTime(
//           _selectedDueDate!.year,
//           _selectedDueDate!.month,
//           _selectedDueDate!.day,
//           0,
//           0,
//           0,
//         );
//       }
//     }

//     int? priorityToSend = _hasPriority ? _selectedPriority : null;

//     Task newTask = Task(
//       title: _titleController.text,
//       description:
//           _noteController.text.isNotEmpty ? _noteController.text : null,
//       categoryId: _selectedCategoryId,
//       date: startDateTime,
//       dueDate: endDateTime,
//       priority: priorityToSend,
//     );

//     print("✅ Creating task:");
//     print("   Start: $startDateTime");
//     print("   Due: $endDateTime");
//     print("   All Day: $_isAllDay");

//     taskController.addTask(task: newTask);
//     Get.back();
//   }

//   // TimeOfDay _parseTimeOfDay(String timeString) {
//   //   try {
//   //     DateTime dateTime = DateFormat("hh:mm a").parse(timeString);
//   //     return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
//   //   } catch (e) {
//   //     return TimeOfDay.now();
//   //   }
//   // }

//   void _showErrorSnackBar(String message) {
//     Get.snackbar(
//       "Error",
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red,
//       colorText: Colors.white,
//     );
//   }

//   Future<void> loadCategories() async {
//     final categoryController = Get.find<CategoryController>();
//     try {
//       final categories = await CategoryService.fetchCategories();
//       // setState(() {
//       //   listCategories = categories!;
//       //   if (categories.isNotEmpty) {
//       //     _selectedCategoryId = categories.first.id;
//       //   }
//       // });
//       setState(() {
//         listCategories = categoryController.categoryList;

//         // ✅ Validate: nếu initialCategoryId không tồn tại trong list
//         if (_selectedCategoryId != null) {
//           final categoryExists =
//               listCategories.any((c) => c.id == _selectedCategoryId);
//           if (!categoryExists) {
//             print(
//                 "⚠️ Category $_selectedCategoryId not found, fallback to first");
//             _selectedCategoryId =
//                 listCategories.isNotEmpty ? listCategories.first.id : null;
//           }
//         } else {
//           // Fallback: chọn category đầu tiên nếu chưa có gì được chọn
//           _selectedCategoryId =
//               listCategories.isNotEmpty ? listCategories.first.id : null;
//         }
//       });
//     } catch (e) {
//       Get.snackbar("Error", "Failed to load categories",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white);
//     }
//   }
// }
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
                      isSelected: true, // Luôn sáng vì mặc định là Today
                      onTap: () => _showDateTimeBottomSheet(),
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
                    _buildActionChip(
                      icon: Icons.alarm,
                      label: 'Reminders',
                      isSelected: _hasReminder,
                      onTap: () {
                        // Implement reminders
                      },
                    ),
                  ],
                ),
              ),

              // Category Dropdown
              // Container(
              //   decoration: BoxDecoration(
              //     color: Colors.transparent,
              //     border: Border(
              //       bottom: BorderSide(color: Colors.grey, width: 0.5),
              //     ),
              //   ),
              //   child: Column(
              //     children: [
              //       const SizedBox(height: 8),
              //       Row(
              //         children: [
              //           const Icon(Icons.category,
              //               color: Colors.black, size: 16),
              //           const SizedBox(width: 2),
              //           Text(
              //             "List: ",
              //             style: TextStyle(
              //               color: Colors.black,
              //               fontSize: 16,
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //           const SizedBox(width: 8),
              //           Expanded(
              //             child: DropdownButton<int>(
              //               value: _selectedCategoryId,
              //               icon: Icon(Icons.keyboard_arrow_down,
              //                   color: Colors.grey[600]),
              //               iconSize: 24,
              //               elevation: 4,
              //               isExpanded: true,
              //               underline: Container(height: 0),
              //               items: listCategories
              //                   .map<DropdownMenuItem<int>>((Category cat) {
              //                 return DropdownMenuItem<int>(
              //                   value: cat.id,
              //                   child: Text(
              //                     cat.title,
              //                     style: const TextStyle(color: Colors.black),
              //                   ),
              //                 );
              //               }).toList(),
              //               onChanged: (int? newValue) {
              //                 if (newValue != null) {
              //                   setState(() {
              //                     _selectedCategoryId = newValue;
              //                     print(
              //                         "Selected Category ID: $_selectedCategoryId");
              //                   });
              //                 }
              //               },
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 8),
              //     ],
              //   ),
              // ),
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

  // void _showDateTimeBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: AppColors.background,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => DraggableScrollableSheet(
  //       expand: false,
  //       initialChildSize: 0.75,
  //       minChildSize: 0.5,
  //       maxChildSize: 0.9,
  //       builder: (_, controller) => StatefulBuilder(
  //         builder: (context, setModalState) {
  //           // Local variables for modal
  //           DateTime tempStartDate = _selectedStartDate;
  //           DateTime? tempDueDate = _selectedDueDate;
  //           TimeOfDay? tempStartTime = _startTime;
  //           TimeOfDay? tempEndTime = _endTime;
  //           bool tempIsAllDay = _isAllDay;
  //           String selectedTab = 'Date'; // Date or Duration

  //           return Container(
  //             padding: const EdgeInsets.all(20),
  //             child: SingleChildScrollView(
  //               controller: controller,
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   // Header with tabs
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           TextButton(
  //                             onPressed: () {
  //                               setModalState(() => selectedTab = 'Date');
  //                             },
  //                             child: Text(
  //                               'Date',
  //                               style: TextStyle(
  //                                 color: selectedTab == 'Date'
  //                                     ? AppColors.primary
  //                                     : Colors.grey,
  //                                 fontSize: 16,
  //                                 fontWeight: selectedTab == 'Date'
  //                                     ? FontWeight.bold
  //                                     : FontWeight.normal,
  //                               ),
  //                             ),
  //                           ),
  //                           TextButton(
  //                             onPressed: () {
  //                               setModalState(() => selectedTab = 'Duration');
  //                             },
  //                             child: Text(
  //                               'Duration',
  //                               style: TextStyle(
  //                                 color: selectedTab == 'Duration'
  //                                     ? AppColors.primary
  //                                     : Colors.grey,
  //                                 fontSize: 16,
  //                                 fontWeight: selectedTab == 'Duration'
  //                                     ? FontWeight.bold
  //                                     : FontWeight.normal,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       IconButton(
  //                         icon: Icon(Icons.check, color: AppColors.primary),
  //                         onPressed: () {
  //                           setState(() {
  //                             _selectedStartDate = tempStartDate;
  //                             _selectedDueDate = tempDueDate;
  //                             _startTime = tempStartTime;
  //                             _endTime = tempEndTime;
  //                             _isAllDay = tempIsAllDay;
  //                           });
  //                           Navigator.pop(context);
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                   // const SizedBox(height: 20),

  //                   if (selectedTab == 'Date') ...[
  //                     // Calendar View (simplified - you should use a proper calendar widget)
  //                     _buildCalendarSection(tempStartDate, (date) {
  //                       setModalState(() => tempStartDate = date);
  //                     }),

  //                     const SizedBox(height: 20),

  //                     // Time Section
  //                     ListTile(
  //                       leading:
  //                           Icon(Icons.access_time, color: AppColors.primary),
  //                       title: Text(
  //                         'Time',
  //                         style: TextStyle(color: AppColors.primary),
  //                       ),
  //                       trailing: Text(
  //                         tempIsAllDay
  //                             ? 'None'
  //                             : _formatTimeOfDay(
  //                                 tempStartTime ?? TimeOfDay.now()),
  //                         style: TextStyle(color: Colors.grey),
  //                       ),
  //                       onTap: () async {
  //                         if (tempIsAllDay) {
  //                           // Chuyển sang có giờ
  //                           setModalState(() {
  //                             tempIsAllDay = false;
  //                             tempStartTime = TimeOfDay.now();
  //                             tempEndTime = TimeOfDay(
  //                               hour: TimeOfDay.now().hour + 1,
  //                               minute: TimeOfDay.now().minute,
  //                             );
  //                           });
  //                         } else {
  //                           // Chọn giờ
  //                           TimeOfDay? picked = await showTimePicker(
  //                             context: context,
  //                             initialTime: tempStartTime ?? TimeOfDay.now(),
  //                           );
  //                           if (picked != null) {
  //                             setModalState(() => tempStartTime = picked);
  //                           }
  //                         }
  //                       },
  //                     ),

  //                     // Reminder
  //                     ListTile(
  //                       leading: Icon(Icons.notifications_none,
  //                           color: AppColors.primary),
  //                       title: Text(
  //                         'Reminder',
  //                         style: TextStyle(color: AppColors.primary),
  //                       ),
  //                       trailing: Text(
  //                         'None',
  //                         style: TextStyle(color: Colors.grey),
  //                       ),
  //                       onTap: () {
  //                         // Implement reminder
  //                       },
  //                     ),

  //                     // Repeat
  //                     ListTile(
  //                       leading: Icon(Icons.repeat, color: AppColors.primary),
  //                       title: Text(
  //                         'Repeat',
  //                         style: TextStyle(color: AppColors.primary),
  //                       ),
  //                       trailing: Text(
  //                         'None',
  //                         style: TextStyle(color: Colors.grey),
  //                       ),
  //                       onTap: () {
  //                         // Implement repeat
  //                       },
  //                     ),

  //                     const SizedBox(height: 20),

  //                     // Clear button
  //                     Center(
  //                       child: TextButton(
  //                         onPressed: () {
  //                           setModalState(() {
  //                             tempStartDate = DateTime.now();
  //                             tempDueDate = null;
  //                             tempStartTime = null;
  //                             tempEndTime = null;
  //                             tempIsAllDay = true;
  //                           });
  //                         },
  //                         child: Text(
  //                           'CLEAR',
  //                           style: TextStyle(
  //                             color: Colors.red,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ] else ...[
  //                     // Duration tab - Start date and Due date
  //                     ListTile(
  //                       title: Text('Start Date',
  //                           style: TextStyle(color: AppColors.primary)),
  //                       subtitle: Text(
  //                         DateFormat('MMM d, yyyy').format(tempStartDate),
  //                         style: TextStyle(color: Colors.grey),
  //                       ),
  //                       onTap: () async {
  //                         DateTime? picked = await showDatePicker(
  //                           context: context,
  //                           initialDate: tempStartDate,
  //                           firstDate: DateTime(2020),
  //                           lastDate: DateTime(2030),
  //                         );
  //                         if (picked != null) {
  //                           setModalState(() => tempStartDate = picked);
  //                         }
  //                       },
  //                     ),

  //                     ListTile(
  //                       title: Text('Due Date',
  //                           style: TextStyle(color: AppColors.primary)),
  //                       subtitle: Text(
  //                         tempDueDate != null
  //                             ? DateFormat('MMM d, yyyy').format(tempDueDate!)
  //                             : 'None',
  //                         style: TextStyle(color: Colors.grey),
  //                       ),
  //                       onTap: () async {
  //                         DateTime? picked = await showDatePicker(
  //                           context: context,
  //                           initialDate: tempDueDate ?? tempStartDate,
  //                           firstDate: tempStartDate,
  //                           lastDate: DateTime(2030),
  //                         );
  //                         if (picked != null) {
  //                           setModalState(() => tempDueDate = picked);
  //                         }
  //                       },
  //                       trailing: tempDueDate != null
  //                           ? IconButton(
  //                               icon: Icon(Icons.clear, color: Colors.grey),
  //                               onPressed: () {
  //                                 setModalState(() => tempDueDate = null);
  //                               },
  //                             )
  //                           : null,
  //                     ),
  //                   ],
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildCalendarSection(
  //     DateTime selectedDate, Function(DateTime) onDateSelected) {
  //   return Container(
  //     padding: EdgeInsets.all(8),
  //     child: Column(
  //       children: [
  //         // Month/Year header
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Text(
  //               DateFormat('MMMM').format(selectedDate),
  //               style: TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black,
  //               ),
  //             ),
  //             Row(
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
  //                   padding: EdgeInsets.zero,
  //                   constraints: BoxConstraints(),
  //                   onPressed: () {
  //                     onDateSelected(DateTime(
  //                       selectedDate.year,
  //                       selectedDate.month - 1,
  //                       1,
  //                     ));
  //                   },
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
  //                   padding: EdgeInsets.zero,
  //                   constraints: BoxConstraints(),
  //                   onPressed: () {
  //                     onDateSelected(DateTime(
  //                       selectedDate.year,
  //                       selectedDate.month + 1,
  //                       1,
  //                     ));
  //                   },
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 4),

  //         // Weekday headers
  //         _buildWeekdayHeaders(),
  //         const SizedBox(height: 8),

  //         // Calendar grid
  //         _buildCalendarGrid(selectedDate, onDateSelected),
  //       ],
  //     ),
  //   );
  // }

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

    int? priorityToSend = _hasPriority ? _selectedPriority : null;

    Task newTask = Task(
      title: _titleController.text,
      description:
          _noteController.text.isNotEmpty ? _noteController.text : null,
      categoryId: _selectedCategoryId,
      date: startDateTime,
      dueDate: endDateTime,
      priority: priorityToSend,
    );

    print("✅ Creating task:");
    print("   Start: $startDateTime");
    print("   Due: $endDateTime");
    print("   All Day: $_isAllDay");

    taskController.addTask(task: newTask);
    Get.back();
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> loadCategories() async {
    final categoryController = Get.find<CategoryController>();
    try {
      final categories = await CategoryService.fetchCategories();
      // setState(() {
      //   listCategories = categories!;
      //   if (categories.isNotEmpty) {
      //     _selectedCategoryId = categories.first.id;
      //   }
      // });
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
                  // Switch(
                  //   value: _hasPriority,
                  //   onChanged: (value) {
                  //     setState(() => _hasPriority = value);
                  //     setModalState(() {});
                  //   },
                  //   activeColor: Colors.blue,
                  // ),
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

  void _showDateTimeBottomSheet() {
    DateTime tempStartDate = _selectedStartDate;
    DateTime? tempDueDate = _selectedDueDate;
    TimeOfDay? tempStartTime = _startTime;
    TimeOfDay? tempEndTime = _endTime;
    bool tempIsAllDay = _isAllDay;
    String selectedTab = 'Date';
    DateTime focusedMonth =
        DateTime(tempStartDate.year, tempStartDate.month, 1);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with tabs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                setModalState(() => selectedTab = 'Date');
                              },
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  color: selectedTab == 'Date'
                                      ? AppColors.primary
                                      : Colors.grey,
                                  fontSize: 16,
                                  fontWeight: selectedTab == 'Date'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setModalState(() => selectedTab = 'Duration');
                              },
                              child: Text(
                                'Duration',
                                style: TextStyle(
                                  color: selectedTab == 'Duration'
                                      ? AppColors.primary
                                      : Colors.grey,
                                  fontSize: 16,
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
                            setState(() {
                              _selectedStartDate = tempStartDate;
                              _selectedDueDate = tempDueDate;
                              _startTime = tempStartTime;
                              _endTime = tempEndTime;
                              _isAllDay = tempIsAllDay;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),

                    if (selectedTab == 'Date') ...[
                      // Calendar View
                      _buildCalendarSection(
                        tempStartDate,
                        focusedMonth,
                        (date) {
                          setModalState(() {
                            tempStartDate = date;
                          });
                        },
                        (month) {
                          setModalState(() {
                            focusedMonth = month;
                          });
                        },
                      ),

                      const SizedBox(height: 20),

                      // Time Section
                      ListTile(
                        leading:
                            Icon(Icons.access_time, color: AppColors.primary),
                        title: Text(
                          'Time',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        // trailing: Text(
                        //   tempIsAllDay
                        //       ? 'None'
                        //       : _formatTimeOfDay(
                        //           tempStartTime ?? TimeOfDay.now()),
                        //   style: TextStyle(color: Colors.grey),
                        // ),
                        trailing: tempIsAllDay
                            ? const Text(
                                'None',
                                style: TextStyle(color: Colors.grey),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTimeOfDay(
                                        tempStartTime ?? TimeOfDay.now()),
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        size: 18, color: Colors.grey),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      setModalState(() {
                                        tempIsAllDay = true;
                                        tempStartTime = null;
                                        tempEndTime = null;
                                      });
                                    },
                                  ),
                                ],
                              ),

                        onTap: () async {
                          if (tempIsAllDay) {
                            // Nếu đang là All Day → bật chế độ có giờ mặc định
                            setModalState(() {
                              tempIsAllDay = false;
                              tempStartTime = TimeOfDay.now();
                              tempEndTime = TimeOfDay(
                                hour: (TimeOfDay.now().hour + 1) % 24,
                                minute: TimeOfDay.now().minute,
                              );
                            });
                          } else {
                            // Nếu đã có giờ → cho chọn lại giờ ngay
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: tempStartTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setModalState(() => tempStartTime = picked);
                            }
                          }
                        },
                      ),

                      // Reminder
                      ListTile(
                        leading: Icon(Icons.notifications_none,
                            color: AppColors.primary),
                        title: Text(
                          'Reminder',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        trailing: Text(
                          'None',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // Implement reminder
                        },
                      ),

                      // Repeat
                      ListTile(
                        leading: Icon(Icons.repeat, color: AppColors.primary),
                        title: Text(
                          'Repeat',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        trailing: Text(
                          'None',
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () {
                          // Implement repeat
                        },
                      ),

                      const SizedBox(height: 20),

                      // Clear button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempStartDate = DateTime.now();
                              tempDueDate = null;
                              tempStartTime = null;
                              tempEndTime = null;
                              tempIsAllDay = true;
                              focusedMonth = DateTime(
                                  DateTime.now().year, DateTime.now().month, 1);
                            });
                          },
                          child: Text(
                            'CLEAR',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Duration tab - Start date and Due date
                      ListTile(
                        title: Text('Start Date',
                            style: TextStyle(color: AppColors.primary)),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(tempStartDate),
                          style: TextStyle(color: Colors.grey),
                        ),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: tempStartDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => tempStartDate = picked);
                          }
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
                          if (picked != null) {
                            setModalState(() => tempDueDate = picked);
                          }
                        },
                        trailing: tempDueDate != null
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setModalState(() => tempDueDate = null);
                                },
                              )
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarSection(
    DateTime selectedDate,
    DateTime focusedMonth,
    Function(DateTime) onDateSelected,
    Function(DateTime) onMonthChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          // Month/Year header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(focusedMonth),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      final newMonth = DateTime(
                        focusedMonth.year,
                        focusedMonth.month - 1,
                        1,
                      );
                      onMonthChanged(newMonth);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    onPressed: () {
                      final newMonth = DateTime(
                        focusedMonth.year,
                        focusedMonth.month + 1,
                        1,
                      );
                      onMonthChanged(newMonth);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Weekday headers
          _buildWeekdayHeaders(),
          const SizedBox(height: 8),

          // Calendar grid
          _buildCalendarGrid(focusedMonth, selectedDate, onDateSelected),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    DateTime focusedMonth,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    // Điều chỉnh để Monday = 0, Sunday = 6
    int firstDayWeekday = firstDayOfMonth.weekday % 7;
    if (firstDayWeekday == 0) firstDayWeekday = 7; // Sunday
    firstDayWeekday = firstDayWeekday - 1; // Shift to 0-indexed (Mon=0)

    final previousMonth =
        DateTime(focusedMonth.year, focusedMonth.month - 1, 1);
    final previousMonthLastDay =
        DateTime(focusedMonth.year, focusedMonth.month, 0).day;
    final daysFromPreviousMonth = firstDayWeekday;

    final totalCells = 42; // 6 weeks × 7 days
    final daysInCurrentMonth = lastDayOfMonth.day;
    final daysFromNextMonth =
        totalCells - daysFromPreviousMonth - daysInCurrentMonth;

    List<Widget> dayWidgets = [];

    // Previous month days (grayed out)
    for (int i = daysFromPreviousMonth; i > 0; i--) {
      final day = previousMonthLastDay - i + 1;
      final date = DateTime(previousMonth.year, previousMonth.month, day);
      dayWidgets.add(_buildDayWidget(
        day,
        date,
        selectedDate,
        onDateSelected,
        isCurrentMonth: false,
      ));
    }

    // Current month days
    for (int day = 1; day <= daysInCurrentMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month, day);
      dayWidgets.add(_buildDayWidget(
        day,
        date,
        selectedDate,
        onDateSelected,
        isCurrentMonth: true,
      ));
    }

    // Next month days (grayed out)
    for (int day = 1; day <= daysFromNextMonth; day++) {
      final date = DateTime(focusedMonth.year, focusedMonth.month + 1, day);
      dayWidgets.add(_buildDayWidget(
        day,
        date,
        selectedDate,
        onDateSelected,
        isCurrentMonth: false,
      ));
    }

    return Column(
      children: [
        for (int week = 0; week < 6; week++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: dayWidgets.skip(week * 7).take(7).toList(),
            ),
          ),
      ],
    );
  }
}
