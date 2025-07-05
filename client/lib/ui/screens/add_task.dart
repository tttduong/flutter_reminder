import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:flutter_to_do_app/ui/widgets/input_field.dart';
import 'package:get/get.dart';

import '../../data/models/category.dart';
import '../../data/models/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
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
                  // MyInputField(
                  //   title: "Category",
                  //   hint: listCategories
                  //       .firstWhere(
                  //         (cat) => cat.id == _selectedCategoryId,
                  //         orElse: () => Category(
                  //             id: -1,
                  //             title: 'None',
                  //             color: Colors.black,
                  //             icon: Icons.category),
                  //       )
                  //       .title,
                  //   widget: DropdownButton<int>(
                  //     value:
                  //         _selectedCategoryId, // _selectedCategoryId phải là int?
                  //     icon: const Icon(
                  //       Icons.keyboard_arrow_down,
                  //       color: Colors.grey,
                  //     ),
                  //     iconSize: 32,
                  //     elevation: 4,
                  //     items: listCategories
                  //         .map<DropdownMenuItem<int>>((Category cat) {
                  //       return DropdownMenuItem<int>(
                  //         value: cat.id, // ID kiểu int
                  //         child: Text(
                  //           cat.title,
                  //           style: const TextStyle(color: Colors.black),
                  //         ),
                  //       );
                  //     }).toList(),
                  //     underline: Container(height: 0),
                  //     onChanged: (int? newValue) {
                  //       setState(() {
                  //         _selectedCategoryId = newValue!;
                  //         print("Selected Category ID: $_selectedCategoryId");
                  //       });
                  //     },
                  //   ),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyButton(
                          label: "Create Task", onTap: () => _validateDate()),
                    ],
                  )
                ],
              ),
            )));
  }

  _validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty
        // && (_selectedCategoryId != "")
        ) {
      _addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty
        // || (_selectedCategoryId == "")
        ) {
      Get.snackbar("Required", "All fields are required!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          // colorText: pinkClr,
          icon: Icon(Icons.warning_amber_rounded, color: Colors.red));
    }
  }

  _addTaskToDb() async {
    await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        description: _noteController.text,
        // categoryId: _selectedCategoryId,
      ),
    );

    await Future.delayed(Duration(milliseconds: 500)); // Chờ API cập nhật
    _taskController.getTasks();
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
      });
    } catch (e) {
      print("Error loading categories: $e");
    }
  }
}
