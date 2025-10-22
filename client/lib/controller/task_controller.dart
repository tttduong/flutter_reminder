import 'dart:async';

import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/services/notification_service.dart';
import 'package:flutter_to_do_app/data/services/task_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
  RxList<Task> matrixTasks = <Task>[].obs;

  @override
  void onInit() {
    super.onInit();
    getTasks(); // Fetch task khi controller khởi tạo
    // getTasksByCategory(selectedCategoryId);
  }

  // 🔹 Lấy tất cả task
  Future<void> getTasks() async {
    try {
      isLoading.value = true;
      final tasks = await TaskService.fetchTasks(); // gọi API thật
      taskList
          .assignAll(tasks); // dùng assignAll thay vì .value để reactive hơn
      print("✅ Loaded all tasks: ${taskList.length}");

      // 🔔 Đặt thông báo
      // for (var task in tasks) {
      //   if (task.date != null && task.date!.isAfter(DateTime.now())) {
      //     await notificationService.scheduleNotification(
      //       id: task.id!,
      //       title: "Nhắc nhở công việc",
      //       body: task.title,
      //       dateTime: task.date!,
      //     );
      //   }
      // }
    } catch (e) {
      print("❌ Failed to load tasks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 Lấy task theo category (dành cho màn hình CategoryTask)
  Future<void> getTasksByCategory(int? categoryId) async {
    if (categoryId == null) return;
    try {
      isLoading.value = true;
      selectedCategoryId = categoryId;
      final tasks = await TaskService.getTasksByCategoryId(categoryId);
      taskList.assignAll(tasks);
      print("✅ Loaded category tasks: ${taskList.length}");
    } catch (e) {
      print("❌ Failed to load category tasks: $e");
    } finally {
      isLoading.value = false;
    }
  }
  // TaskController

  Future<void> getMatrixTasks() async {
    try {
      await getTasks(); // Get all tasks
      // Filter only tasks with priority
      matrixTasks.value =
          taskList.where((task) => task.priority != null).toList();
      print("Matrix tasks: ${matrixTasks.length}");
    } catch (e) {
      print("Error getting matrix tasks: $e");
    }
  }

// Trong task_controller.dart
// // Trong task_controller.dart
// void toggleTaskCompletion(Task task) async {
//   final taskId = task.id;
//   final newStatus = !task.isCompleted;

//   // Update immediately
//   task.isCompleted = newStatus;
//   task.completedAt = newStatus ? DateTime.now() : null;
//   pendingUpdates[taskId!] = newStatus;
//   taskList.refresh();

//   // Update category tương ứng
//   final categoryController = Get.find<CategoryController>();
//   categoryController.updateCategoryStatsByTask(task);

//   try {
//     await _taskService.updateTask(task);
//     pendingUpdates.remove(taskId);
//   } catch (e) {
//     // Revert on error
//     task.isCompleted = !newStatus;
//     task.completedAt = !newStatus ? DateTime.now() : null;
//     pendingUpdates.remove(taskId);
//     taskList.refresh();

//     // Revert category stats
//     categoryController.updateCategoryStatsByTask(task);

//     Get.snackbar('Error', 'Failed to update task');
//   }
// }
// Trong task_controller.dart
  void toggleTaskCompletion(Task task) async {
    final taskId = task.id;
    final newStatus = !task.isCompleted;

    // Update immediately
    task.isCompleted = newStatus;
    task.completedAt = newStatus ? DateTime.now() : null;
    pendingUpdates[taskId!] = newStatus;
    taskList.refresh();

    // Update category tương ứng
    final categoryController = Get.find<CategoryController>();
    categoryController.updateCategoryStatsByTask(task);

    try {
      // Dùng updateTaskStatus thay vì _taskService.updateTask
      await updateTaskStatus(task, newStatus);
      pendingUpdates.remove(taskId);
    } catch (e) {
      // Revert on error
      task.isCompleted = !newStatus;
      task.completedAt = !newStatus ? DateTime.now() : null;
      pendingUpdates.remove(taskId);
      taskList.refresh();

      // Revert category stats
      categoryController.updateCategoryStatsByTask(task);

      Get.snackbar('Error', 'Failed to update task');
    }
  }

  // Toggle method với String key fix
  Future<void> toggleTaskStatus(Task task, bool newStatus) async {
    final taskId = task.id;

    // Update immediately
    task.isCompleted = newStatus;
    pendingUpdates[taskId!] = newStatus;
    taskList.refresh();
    // Update category tương ứng
    final categoryController = Get.find<CategoryController>();
    categoryController.updateCategoryStatsByTask(task);
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

  Future<void> getTasksByDate(DateTime date) async {
    try {
      isLoading.value = true;
      List<Task> tasks = await TaskService.getTasksByDate(date);
      taskList.value = tasks;
    } catch (e) {
      print('Error in controller: $e');
      // Có thể show snackbar error ở đây
      Get.snackbar('Lỗi', 'Không thể tải tasks: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> refreshTasks(int? categoryId) async {
  //   if (categoryId != null) {
  //     selectedCategoryId = null; // Force refresh
  //     await getTasksByCategory(categoryId);
  //   }
  // }
  Future<void> refreshTasks([int? categoryId]) async {
    if (categoryId != null) {
      await getTasksByCategory(categoryId);
    } else {
      await getTasks();
    }
  }
  // Future<void> getTasksByCategory(int? categoryId) async {
  //   print("🔍 Getting tasks for category: $categoryId");
  //   print("🔍 Current selectedCategoryId: $selectedCategoryId");
  //   print("🔍 Current taskList count: ${taskList.length}");

  //   // 🔥 LUÔN LUÔN clear và fetch lại khi switch category
  //   if (selectedCategoryId != categoryId) {
  //     print(
  //         "📝 Category changed from $selectedCategoryId to $categoryId - clearing cache");
  //     taskList.clear();
  //     selectedCategoryId = categoryId;
  //   } else {
  //     print("📝 Same category but forcing refresh anyway");
  //     taskList.clear(); // 👈 FORCE clear để đảm bảo
  //   }

  //   isLoading.value = true;

  //   try {
  //     print("🌐 Calling API for category: $categoryId");
  //     final tasks = await TaskService.getTasksByCategoryId(categoryId);
  //     print("📊 API returned ${tasks.length} tasks for category $categoryId");

  //     // Debug: In ra từng task
  //     for (int i = 0; i < tasks.length; i++) {
  //       print(
  //           "  Task $i: ${tasks[i].title} (Category: ${tasks[i].categoryId})");
  //     }

  //     taskList.value = tasks;
  //     print("✅ TaskList updated with ${taskList.length} tasks");
  //   } catch (e) {
  //     print("❌ Error getting tasks for category $categoryId: $e");
  //     taskList.clear();
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Future<void> getTasksByCategory(int categoryId) async {
  //   print("🔍 Getting tasks for category: $categoryId");

  //   // 👈 Nếu category khác, clear cache
  //   if (selectedCategoryId != categoryId) {
  //     taskList.clear();
  //     selectedCategoryId = categoryId;
  //   }

  //   isLoading.value = true;

  //   try {
  //     final tasks = await TaskService.getTasksByCategoryId(categoryId);
  //     print("📊 API returned ${tasks.length} tasks");

  //     taskList.value = tasks;
  //   } catch (e) {
  //     print("❌ Error: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  Future<void> addTask({Task? task}) async {
    print("call add task on controller");
    if (task == null) {
      print("Task null");
      return;
    }
    bool success = await TaskService.createTask(task: task);
    if (success) {
      print("Task service create task successfully");
      getTasks(); // Refresh danh sách task sau khi thêm
    }
  }

  //get all the data from table
  // void getTasks() async {
  //   taskList.value = await TaskService.fetchTasks();
  // }

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
