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
//   final TaskController _taskController = Get.put(TaskController());
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   String _selectedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   // String _endTime = "9:30 PM";
//   String? _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
//   String? _endTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
//   String? _time = DateFormat("hh:mm a").format(DateTime.now()).toString();
//   bool _hasDate = false;
//   List<Category> listCategories = [];
//   int? _selectedCategoryId;
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
//                   MyInputField(
//                     title: "Category",
//                     hint: listCategories.isEmpty
//                         ? "No category"
//                         : listCategories
//                             .firstWhere(
//                               (cat) => cat.id == _selectedCategoryId,
//                               orElse: () => listCategories.first,
//                             )
//                             .title,
//                     widget: DropdownButton<int>(
//                       value: _selectedCategoryId,
//                       icon: const Icon(Icons.keyboard_arrow_down,
//                           color: Colors.grey),
//                       iconSize: 32,
//                       elevation: 4,
//                       items: listCategories
//                           .map<DropdownMenuItem<int>>((Category cat) {
//                         return DropdownMenuItem<int>(
//                           value: cat.id,
//                           child: Text(
//                             cat.title,
//                             style: const TextStyle(color: Colors.black),
//                           ),
//                         );
//                       }).toList(),
//                       underline: Container(height: 0),
//                       onChanged: (int? newValue) {
//                         if (newValue != null) {
//                           setState(() {
//                             _selectedCategoryId = newValue;
//                             print("Selected Category ID: $_selectedCategoryId");
//                           });
//                         }
//                       },
//                     ),
//                   ),
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
//                         SizedBox(width: 10), // Khoảng cách giữa 2 field
//                         Expanded(
//                             child: MyInputField(
//                                 title: "Start Time",
//                                 hint: _startTime,
//                                 widget: IconButton(
//                                   onPressed: () {
//                                     _getTimeFromUser(
//                                         isStartTime: true, hasDate: _hasDate);
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
//                         SizedBox(width: 20),
//                         Expanded(
//                             child: MyInputField(
//                                 title: "End Time",
//                                 hint: _endTime,
//                                 widget: IconButton(
//                                   onPressed: () {
//                                     _getTimeFromUser(
//                                         isStartTime: false, hasDate: _hasDate);
//                                   },
//                                   icon: Icon(Icons.access_time_rounded),
//                                   color: Colors.grey,
//                                 ))),
//                       ],
//                     ),
//                   ],
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       MyButton(
//                           label: "Create Task", onTap: () => _validateDate()),
//                     ],
//                   )
//                 ],
//               ),
//             )));
//   }

//   _validateDate() async {
//     if (_titleController.text.isNotEmpty) {
//       // Kiểm tra start date và end date
//       DateTime startDateTime = _combineDateTime(_selectedDate, _startTime);
//       DateTime endDateTime = _combineDateTime(_selectedEndDate, _endTime);

//       // Validation: Start date phải nhỏ hơn hoặc bằng end date
//       if (startDateTime.isAfter(endDateTime)) {
//         Get.snackbar("Invalid Date Range",
//             "Start date must be before or equal to end date!",
//             snackPosition: SnackPosition.BOTTOM,
//             backgroundColor: Colors.red,
//             colorText: Colors.white,
//             icon: Icon(Icons.error_outline, color: Colors.white));
//         return; // Dừng lại, không tạo task
//       }
//       await _addTaskToDb();

//       // Navigate đến category screen chứa task vừa tạo
//       if (_selectedCategoryId != null) {
//         // Tìm category object
//         final category = listCategories.firstWhere(
//           (cat) => cat.id == _selectedCategoryId,
//         );

//         // Navigate với success message
//         // Get.off(() => CategoryTasksPage(category: category));

//         Get.back(); // Close create task screen
//         BottomNavBarScreenState.navigateToCategoryFromAnywhere(category);
//         // Show success notification
//         // Get.snackbar(
//         //   "Success",
//         //   "Task created in ${category.title}!",
//         //   snackPosition: SnackPosition.TOP,
//         //   backgroundColor: Colors.green,
//         //   colorText: Colors.white,
//         // );
//       }
//     } else {
//       Get.snackbar("Required", "Title is required!",
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.white,
//           icon: Icon(Icons.warning_amber_rounded, color: Colors.red));
//     }
//   }

//   _addTaskToDb() async {
// // Chỉ set date/time nếu _hasDate = true, ngược lại để null
//     DateTime? startDateTime;
//     DateTime? endDateTime;

//     if (_hasDate) {
//       startDateTime = _combineDateTime(_selectedDate, _startTime);
//       endDateTime = _combineDateTime(_selectedEndDate, _endTime);
//     }
//     // Nếu _hasDate = false, startDateTime và endDateTime sẽ là null

//     await _taskController.addTask(
//       task: Task(
//         title: _titleController.text,
//         description: _noteController.text,
//         categoryId: _selectedCategoryId,
//         date: startDateTime, // 👈 Null nếu không có date
//         dueDate: endDateTime, // 👈 Null nếu không có date
//       ),
//     );

//     await Future.delayed(Duration(milliseconds: 500));
//     _taskController.getTasksByCategory(_selectedCategoryId!);
//   }

// // 👈 Thêm helper method để combine date và time
//   DateTime _combineDateTime(String date, String? time) {
//     DateTime dateOnly = DateFormat('yyyy-MM-dd').parse(date);

//     // Parse time (format: "9:30 AM")
//     DateFormat timeFormat = DateFormat("hh:mm a");
//     DateTime timeOnly = timeFormat.parse(time!);

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
//         _selectedCategoryId = categories.first.id;
//       });
//     } catch (e) {
//       print("Error loading categories: $e");
//     }
//   }

//   // _getDateFromUser() async {
//   //   DateTime? _pickerDate = await showDatePicker(
//   //       context: context,
//   //       initialDate: DateTime.now(),
//   //       firstDate: DateTime(2015),
//   //       lastDate: DateTime(2030));

//   //   if (_pickerDate != null) {
//   //     setState(() {
//   //       _selectedDate = DateFormat('yyyy-MM-dd').format(_pickerDate);
//   //       print(_selectedDate);
//   //     });
//   //   } else {
//   //     print("it's null or something is wrong");
//   //   }
//   // }
//   _getDateFromUser({required bool isStartDate}) async {
//     DateTime? _pickerDate = await showDatePicker(
//         context: context,
//         initialDate: DateTime.now(),
//         firstDate: DateTime(2015),
//         lastDate: DateTime(2030));

//     if (_pickerDate != null) {
//       setState(() {
//         if (isStartDate) {
//           _selectedDate = DateFormat('yyyy-MM-dd').format(_pickerDate);
//         } else {
//           _selectedEndDate = DateFormat('yyyy-MM-dd').format(_pickerDate);
//         }
//         print(isStartDate
//             ? 'Start Date: $_selectedDate'
//             : 'End Date: $_selectedEndDate');
//       });
//     } else {
//       print("it's null or something is wrong");
//     }
//   }

//   _getTimeFromUser({required bool isStartTime, required bool hasDate}) async {
//     var pickedTime = await _showTimePicker();
//     String _formatedTime = pickedTime.format(context);
//     if (hasDate == true) {
//       if (pickedTime == null) {
//         print("Time cancel");
//       } else if (isStartTime == true) {
//         setState(() {
//           _startTime = _formatedTime;
//         });
//       } else if (isStartTime == false) {
//         setState(() {
//           _endTime = _formatedTime;
//         });
//       }
//     } else {
//       setState(() {
//         _startTime = null;
//         _endTime = null;
//       });
//       return;
//     }
//   }

//   _showTimePicker() {
//     if (!_hasDate) {
//       setState(() {
//         _time = null;
//       });
//     } else {
//       return showTimePicker(
//           initialEntryMode: TimePickerEntryMode.input,
//           context: context,
//           initialTime: TimeOfDay(
//             hour: int.parse(_time!.split(":")[0]),
//             minute: int.parse(_time!.split(":")[1].split(" ")[0]),
//           ));
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:flutter_to_do_app/ui/widgets/input_field.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/category.dart';
import '../../data/models/task.dart';
import 'bottom_navbar_screen.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _selectedEndDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String _startTime = DateFormat("hh:mm a").format(DateTime.now());
  String _endTime = DateFormat("hh:mm a")
      .format(DateTime.now().add(Duration(hours: 1))); // End time 1 hour later
  bool _hasDate = false;
  List<Category> listCategories = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: _appBar(context),
        body: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Task",
                    //  style: headingStyle
                  ),
                  MyInputField(
                    title: "Title",
                    hint: "Enter title here",
                    controller: _titleController,
                  ),
                  MyInputField(
                    title: "Description",
                    hint: "Enter your description",
                    controller: _noteController,
                  ),
                  MyInputField(
                    title: "Category",
                    hint: listCategories.isEmpty
                        ? "No category"
                        : listCategories
                            .firstWhere(
                              (cat) => cat.id == _selectedCategoryId,
                              orElse: () => listCategories.first,
                            )
                            .title,
                    widget: DropdownButton<int>(
                      value: _selectedCategoryId,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey),
                      iconSize: 32,
                      elevation: 4,
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
                      underline: Container(height: 0),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCategoryId = newValue;
                            print("Selected Category ID: $_selectedCategoryId");
                          });
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Set Date & Time",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                        Switch(
                          value: _hasDate,
                          onChanged: (bool value) {
                            setState(() {
                              _hasDate = value;
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  if (_hasDate) ...[
                    Row(
                      children: [
                        Expanded(
                          child: MyInputField(
                              title: "Start Date",
                              hint: _selectedDate,
                              widget: IconButton(
                                  icon: Icon(Icons.calendar_today_outlined,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _getDateFromUser(isStartDate: true);
                                  })),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: MyInputField(
                                title: "Start Time",
                                hint: _startTime,
                                widget: IconButton(
                                  onPressed: () {
                                    _getTimeFromUser(isStartTime: true);
                                  },
                                  icon: Icon(Icons.access_time_rounded),
                                  color: Colors.grey,
                                ))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: MyInputField(
                              title: "End Date",
                              hint: _selectedEndDate,
                              widget: IconButton(
                                  icon: Icon(Icons.calendar_today_outlined,
                                      color: Colors.grey),
                                  onPressed: () {
                                    _getDateFromUser(isStartDate: false);
                                  })),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                            child: MyInputField(
                                title: "End Time",
                                hint: _endTime,
                                widget: IconButton(
                                  onPressed: () {
                                    _getTimeFromUser(isStartTime: false);
                                  },
                                  icon: Icon(Icons.access_time_rounded),
                                  color: Colors.grey,
                                ))),
                      ],
                    ),
                  ],
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyButton(
                          label: "Create Task", onTap: () => _validateData()),
                    ],
                  )
                ],
              ),
            )));
  }

  _validateData() async {
    if (_titleController.text.isNotEmpty) {
      // Kiểm tra nếu có set date thì validate date range
      if (_hasDate) {
        DateTime startDateTime = _combineDateTime(_selectedDate, _startTime);
        DateTime endDateTime = _combineDateTime(_selectedEndDate, _endTime);

        // Validation: Start date phải nhỏ hơn hoặc bằng end date
        if (startDateTime.isAfter(endDateTime)) {
          Get.snackbar("Invalid Date Range",
              "Start date and time must be before end date and time!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              icon: Icon(Icons.error_outline, color: Colors.white));
          return;
        }
      }

      // Validate category
      if (_selectedCategoryId == null) {
        Get.snackbar("Required", "Please select a category!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            icon: Icon(Icons.warning_amber_rounded, color: Colors.white));
        return;
      }

      await _addTaskToDb();

      // Navigate back with success
      Get.back();

      Get.snackbar(
        "Success",
        "Task created successfully!",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } else {
      Get.snackbar("Required", "Title is required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: Icon(Icons.warning_amber_rounded, color: Colors.white));
    }
  }

  _addTaskToDb() async {
    DateTime? startDateTime;
    DateTime? endDateTime;

    if (_hasDate) {
      startDateTime = _combineDateTime(_selectedDate, _startTime);
      endDateTime = _combineDateTime(_selectedEndDate, _endTime);
    }

    await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        description: _noteController.text,
        categoryId: _selectedCategoryId,
        date: startDateTime,
        dueDate: endDateTime,
      ),
    );

    await Future.delayed(Duration(milliseconds: 500));
    if (_selectedCategoryId != null) {
      _taskController.getTasksByCategory(_selectedCategoryId!);
    }
  }

  // Helper method để combine date và time
  DateTime _combineDateTime(String date, String time) {
    DateTime dateOnly = DateFormat('yyyy-MM-dd').parse(date);

    // Parse time (format: "9:30 AM" hoặc "09:30 AM")
    DateFormat timeFormat = DateFormat("hh:mm a");
    DateTime timeOnly = timeFormat.parse(time);

    // Combine date và time
    return DateTime(
      dateOnly.year,
      dateOnly.month,
      dateOnly.day,
      timeOnly.hour,
      timeOnly.minute,
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(
          Icons.arrow_back_ios,
          size: 20,
        ),
      ),
    );
  }

  Future<void> loadCategories() async {
    try {
      final categories = await CategoryService.fetchCategories();
      setState(() {
        listCategories = categories;
        if (categories.isNotEmpty) {
          _selectedCategoryId = categories.first.id;
        }
      });
    } catch (e) {
      print("Error loading categories: $e");
      Get.snackbar("Error", "Failed to load categories",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  _getDateFromUser({required bool isStartDate}) async {
    DateTime? pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime(2030));

    if (pickerDate != null) {
      setState(() {
        if (isStartDate) {
          _selectedDate = DateFormat('yyyy-MM-dd').format(pickerDate);
          print('Start Date: $_selectedDate');
        } else {
          _selectedEndDate = DateFormat('yyyy-MM-dd').format(pickerDate);
          print('End Date: $_selectedEndDate');
        }
      });
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedTime != null) {
      // Convert TimeOfDay to formatted string
      final now = DateTime.now();
      final dateTime = DateTime(
          now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final formattedTime = DateFormat("hh:mm a").format(dateTime);

      setState(() {
        if (isStartTime) {
          _startTime = formattedTime;
          print('Start Time: $_startTime');
        } else {
          _endTime = formattedTime;
          print('End Time: $_endTime');
        }
      });
    }
  }
}
