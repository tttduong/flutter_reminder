import 'package:flutter_to_do_app/db/db_helper.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/service/task_service.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;
  @override
  void onInit() {
    super.onInit();
    getTasks(); // Fetch task khi controller khởi tạo
  }

  Future<void> addTask({Task? task}) async {
    print("call add task om controller");
    // return await DBHelper.insert(task!);
    final String title = task?.title.trim() ?? "";
    final String description = task?.description?.trim() ?? "";

    if (title.isEmpty || description.isEmpty) {
      print("Title và Description không được để trống");
      return;
    }

    bool success = await TaskService.createTask(task: task);
    if (success) {
      getTasks(); // Refresh danh sách task sau khi thêm
    }
  }

  //get all the data from table
  void getTasks() async {
    taskList.value = await TaskService.fetchTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await TaskService.deleteTask(taskId);
    taskList.removeWhere(
        (task) => task.id == taskId); // Cập nhật danh sách sau khi xoá
    update(); // Cập nhật UI
  }

  Future<void> updateTaskStatus(int status) async {}
}
