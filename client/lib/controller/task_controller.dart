import 'package:flutter_to_do_app/db/db_helper.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<void> addTask({Task? task}) async {
    print("call add task om controller");
    // return await DBHelper.insert(task!);
    final String title = task?.title.trim() ?? "";
    final String description = task?.description?.trim() ?? "";

    if (title.isEmpty || description.isEmpty) {
      print("Title và Description không được để trống");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/tasks/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer your_access_token", // Nếu API cần token
        },
        body: jsonEncode({
          "title": title,
          "description": description,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Task created successfully!");
      } else {
        print("Failed to create task: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  //get all the data from table
  void getTasks() async {
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/tasks/"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        taskList
            .assignAll(jsonData.map((item) => Task.fromJson(item)).toList());
      }
    } catch (e) {
      print("Error loading tasks: $e");
    }
  }
}
