import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/model/category.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/service/category_service.dart';
import 'package:flutter_to_do_app/service/theme_services.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:flutter_to_do_app/ui/widgets/input_field.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  // String _endTime = "9:30 PM";
  String _time = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _selectedRemind = "5";
  List<String> remindList = ["5", "10", "15", "20"];
  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily", "Weekly", "Monthly"];
  List<Category> listCategories = [];
  String _selectedCategoryId = "";
  String _selectedColor = "0";

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
                  Text("Add Task", style: headingStyle),
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
                      hint: listCategories
                          .firstWhere(
                            (cat) => cat.id == _selectedCategoryId,
                            orElse: () => Category(
                                id: '',
                                title: 'None',
                                color: Colors.black,
                                icon: Icons.category),
                          )
                          .title,
                      widget: DropdownButton<String>(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          iconSize: 32,
                          elevation: 4,
                          style: subTitleStyle,
                          items: listCategories
                              .map<DropdownMenuItem<String>>((Category cat) {
                            return DropdownMenuItem<String>(
                              value: cat.id, // ID (giá trị được lưu)
                              child: Text(
                                cat.title, // tên hiển thị
                                style: const TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          underline: Container(
                            height: 0,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategoryId = newValue!;
                              print("Selected Category ID: " +
                                  _selectedCategoryId);
                            });
                          })),
                  MyInputField(
                      title: "Date",
                      hint: DateFormat.yMd().format(_selectedDate),
                      widget: IconButton(
                          icon: Icon(Icons.calendar_today_outlined,
                              color: Colors.grey),
                          onPressed: () {
                            _getDateFromUser();
                          })),
                  Row(
                    children: [
                      Expanded(
                          child: MyInputField(
                              title: "Time",
                              hint: _time,
                              widget: IconButton(
                                onPressed: () {
                                  _getTimeFromUser(isStartTime: true);
                                },
                                icon: Icon(Icons.access_time_rounded),
                                color: Colors.grey,
                              ))),
                      // SizedBox(width: 20),
                      // Expanded(
                      //     child: MyInputField(
                      //         title: "EndTime",
                      //         hint: _endTime,
                      //         widget: IconButton(
                      //           onPressed: () {
                      //             _getTimeFromUser(isStartTime: false);
                      //           },
                      //           icon: Icon(Icons.access_time_rounded),
                      //           color: Colors.grey,
                      //         ))),
                    ],
                  ),
                  MyInputField(
                      title: "Remind",
                      hint: "$_selectedRemind minutes early",
                      widget: DropdownButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          iconSize: 32,
                          elevation: 4,
                          style: subTitleStyle,
                          items: remindList
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                                value: value.toString(),
                                // child: Text(value.toString()));
                                child: Text(value));
                          }).toList(),
                          underline: Container(
                            height: 0,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              // _selectedRemind = int.parse(newValue!);
                              _selectedRemind = newValue!;
                            });
                          })),
                  MyInputField(
                      title: "Repeat",
                      hint: "$_selectedRepeat",
                      widget: DropdownButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                          iconSize: 32,
                          elevation: 4,
                          style: subTitleStyle,
                          items: repeatList
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  value!,
                                  style: TextStyle(color: Colors.grey),
                                ));
                          }).toList(),
                          underline: Container(
                            height: 0,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedRepeat = newValue!;
                            });
                          })),
                  SizedBox(
                    height: 18,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // _colorPallete(),
                      MyButton(
                          label: "Create Task", onTap: () => _validateDate()),
                    ],
                  )
                ],
              ),
            )));
  }

  Future<void> loadCategories() async {
    try {
      final categories = await CategoryService.fetchCategories();
      setState(() {
        listCategories = categories;
      });
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty &&
        _noteController.text.isNotEmpty &&
        (_selectedCategoryId != "")) {
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty ||
        _noteController.text.isEmpty ||
        (_selectedCategoryId == "")) {
      Get.snackbar("Required", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red));
    }
  }

  _addTaskToDb() async {
    await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        description: _noteController.text,
        categoryId: _selectedCategoryId,
        isCompleted: false,
        date: _selectedDate,
        time: _time,
        // endTime: _endTime,
        // color: _selectedColor.toString(), // Đổi thành string
        // remind: _selectedRemind.toString(), // Đổi thành string
        // repeat: _selectedRepeat,
      ),
    );
    print("Category ID saved to db: " + _selectedCategoryId);
    await Future.delayed(Duration(milliseconds: 500)); // Chờ API cập nhật
    // Cập nhật danh sách task ngay sau khi tạo thành công
    _taskController.getTasks();

    // print("My id is $value");
  }

  // _colorPallete() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "Color",
  //         style: titleStyle,
  //       ),
  //       SizedBox(height: 8.0),
  //       Wrap(
  //         children: List<Widget>.generate(3, (int index) {
  //           return GestureDetector(
  //             onTap: () {
  //               setState(() {
  //                 _selectedColor = index.toString();
  //               });
  //             },
  //             child: Padding(
  //               padding: EdgeInsets.only(right: 8.0),
  //               child: CircleAvatar(
  //                   radius: 14,
  //                   backgroundColor: index == 0
  //                       ? primaryClr
  //                       : index == 1
  //                           ? pinkClr
  //                           : yellowClr,
  //                   child: _selectedColor == index
  //                       ? Icon(Icons.done, color: Colors.white, size: 16)
  //                       : Container()),
  //             ),
  //           );
  //         }),
  //       )
  //     ],
  //   );
  // }

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
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage("images/profile.jpg"),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015),
        lastDate: DateTime(2030));

    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
        print(_selectedDate);
      });
    } else {
      print("it's null or something is wrong");
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _formatedTime = pickedTime.format(context);
    if (pickedTime == null) {
      print("Time cancel");
    } else if (isStartTime == true) {
      setState(() {
        _time = _formatedTime;
      });
    }
    // else if (isStartTime == false) {
    //   setState(() {
    //     _endTime = _formatedTime;
    //   });
    // }
  }

  _showTimePicker() {
    return showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
          hour: int.parse(_time.split(":")[0]),
          minute: int.parse(_time.split(":")[1].split(" ")[0]),
        ));
  }
}
