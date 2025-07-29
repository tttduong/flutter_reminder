import 'dart:async';

import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/services/task_service.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  // final _tasksStreamController = StreamController<List<Task>>.broadcast();
  @override
  void onReady() {
    super.onReady();
  }

  // var taskList = <Task>[].obs;
  var isLoading = false.obs;
  int? selectedCategoryId;
  final RxList<Task> taskList = <Task>[].obs;
  final RxMap<int, bool> pendingUpdates = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getTasks(); // Fetch task khi controller khởi tạo
  }

  // Toggle method với String key fix
  Future<void> toggleTaskStatus(Task task, bool newStatus) async {
    final taskId = task.id;

    // Update immediately
    task.isCompleted = newStatus;
    pendingUpdates[taskId!] = newStatus;
    taskList.refresh();

    try {
      await updateTaskStatus(task, newStatus);
      pendingUpdates.remove(taskId);
    } catch (e) {
      // Revert on error
      task.isCompleted = !newStatus;
      pendingUpdates.remove(taskId);
      taskList.refresh();

      Get.snackbar('Error', 'Failed to update task');
    }
  }

  // Check if task is pending
  bool isTaskPending(int taskId) {
    return pendingUpdates.containsKey(taskId.toString());
  }

  Future<void> deleteTask(int? taskId) async {
    if (taskId == null) {
      print("❌ Task ID is null. Cannot delete task.");
      return;
    }
    await TaskService.deleteTask(taskId);
    taskList.removeWhere((t) => t.id == taskId);
    update(); // Cập nhật UI
  }

  // Refresh method
  Future<void> refreshTasks(int? categoryId) async {
    await getTasksByCategory(categoryId);
  }

  Future<List<Task>> getTasksByCategory(int? categoryId) async {
    return await TaskService.getTasksByCategoryId(categoryId);
  }

  Future<void> addTask({Task? task}) async {
    print("call add task on controller");
    if (task == null) {
      print("Task null");
      return;
    }
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

  Future<bool> updateTaskStatus(Task updatedTask, bool newStatus) async {
    // final task = taskList.firstWhere((t) => t.id == id);
    updatedTask.isCompleted = newStatus;

    // Gọi API hoặc DB để lưu trạng thái mới
    bool success = await TaskService.updateTaskStatus(updatedTask, newStatus);

    if (success) {
      taskList.refresh(); // cập nhật UI
      return true;
    } else {
      print("Failed to update task status");
      return false;
    }
  }
}
