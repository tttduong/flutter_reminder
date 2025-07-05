import 'package:flutter_to_do_app/db/db_helper.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/services/task_service.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;
  int? selectedCategoryId;
  @override
  void onInit() {
    super.onInit();
    getTasks(); // Fetch task khi controller khởi tạo
  }

  // lay task by category
  List<Task> getTasksByCategory(int? categoryId) {
    if (categoryId == null) {
      return taskList.where((task) => task.categoryId == null).toList();
    } else {
      return taskList.where((task) => task.categoryId == categoryId).toList();
    }
  }

  Future<void> addTask({Task? task}) async {
    print("call add task on controller");
    // return await DBHelper.insert(task!);

    if (task == null) {
      print("Task null");
      return;
    }
    // final String title = task.title.trim();
    // final String description = task.description?.trim() ?? "";
    // final String categoryId = task.categoryId;
    // final String? time = task.time;
    // print("Category ID in Task Controller: " + categoryId); // OK
    // if (title.isEmpty || description.isEmpty || categoryId.isEmpty) {
    //   print("Title, Description hoặc Catergory không được để trống");
    //   return;
    // }

    bool success = await TaskService.createTask(task: task);
    if (success) {
      print("Task service create task successfully");
      // getTasks(); // Refresh danh sách task sau khi thêm
    }
  }

  //get all the data from table
  void getTasks() async {
    taskList.value = await TaskService.fetchTasks();
  }

  Future<void> deleteTask(Task task) async {
    await TaskService.deleteTask(task);
    taskList.removeWhere((t) => t.id == task.id);
    update(); // Cập nhật UI
  }

  void updateTaskStatus(Task updatedTask, bool newStatus) async {
    // final task = taskList.firstWhere((t) => t.id == id);
    updatedTask.isCompleted = newStatus;

    // Gọi API hoặc DB để lưu trạng thái mới
    bool success = await TaskService.updateTaskStatus(updatedTask, newStatus);

    if (success) {
      taskList.refresh(); // cập nhật UI
    } else {
      print("Failed to update task status");
    }
  }
}
