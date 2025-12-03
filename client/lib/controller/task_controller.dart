import 'dart:async';

import 'package:flutter_to_do_app/api.dart';
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
  final RxList<Task> fullDayTaskList = <Task>[].obs;
  final RxBool isFullDayExpanded = true.obs;
  final RxList<Task> taskListByCategory = <Task>[].obs;

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
    } catch (e) {
      print("❌ Failed to load tasks: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🔹 Lấy task theo category (dành cho màn hình CategoryTask)
  // Future<void> getTasksByCategory(int? categoryId) async {
  //   if (categoryId == null) return;
  //   try {
  //     isLoading.value = true;
  //     selectedCategoryId = categoryId;
  //     final tasks = await TaskService.getTasksByCategoryId(categoryId);
  //     taskList.assignAll(tasks);
  //     print("✅ Loaded category tasks: ${taskList.length}");
  //   } catch (e) {
  //     print("❌ Failed to load category tasks: $e");
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  Future<void> getTasksByCategory(int? categoryId) async {
    if (categoryId == null) return;
    try {
      isLoading.value = true;
      selectedCategoryId = categoryId;

      final tasks = await TaskService.getTasksByCategoryId(categoryId);

      // Gán vào taskListByCategory để dùng cho màn hình category
      taskListByCategory.assignAll(tasks);

      print("✅ Loaded category tasks: ${taskListByCategory.length}");
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

  // Lấy full day tasks theo ngày
  Future<void> getFullDayTasks(DateTime date) async {
    try {
      isLoading.value = true;
      final tasks = await TaskService.getSingleDayTasks(date);
      fullDayTaskList.assignAll(tasks);
    } catch (e) {
      print('Error getting full day tasks: $e');
      fullDayTaskList.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Helper: Lấy full day tasks cho một ngày cụ thể từ list hiện tại
  List<Task> getFullDayTasksForDate(DateTime date) {
    return fullDayTaskList.where((task) {
      if (task.date == null) return false;
      return task.date!.year == date.year &&
          task.date!.month == date.month &&
          task.date!.day == date.day &&
          task.dueDate == null; // Chỉ lấy task không có due_date
    }).toList();
  }

// Trong task_controller.dart ----đang dùng trong homepage
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

  // Toggle method với String key fix  --- đnag dùng trong category task page
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

  // Future<void> deleteTask(int? taskId) async {
  //   if (taskId == null) {
  //     print("❌ Task ID is null. Cannot delete task.");
  //     return;
  //   }
  //   await TaskService.deleteTask(taskId);
  //   taskList.removeWhere((t) => t.id == taskId);
  //   update(); // Cập nhật UI
  // }

  Future<bool> deleteTask({required int taskId}) async {
    try {
      bool result = await TaskService.deleteTask(taskId);
      if (result) {
        taskList.removeWhere((task) => task.id == taskId);
        taskList.refresh();
      }
      return result;
    } catch (e) {
      print("Error deleting task: $e");
      return false;
    }
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

  Future<void> refreshTasks([int? categoryId]) async {
    if (categoryId != null) {
      await getTasksByCategory(categoryId);
    } else {
      await getTasks();
    }
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
      getTasks(); // Refresh danh sách task sau khi thêm
    }
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
  // Thêm method này vào TaskController

  // Future<Task?> getTaskById(int taskId) async {
  //   try {
  //     final response =
  //         await ApiService.dio.get('${ApiService.baseUrl}/tasks/$taskId');

  //     if (response.statusCode == 200) {
  //       print("✅ Task fetched successfully: ${response.data}");
  //       return Task.fromJson(response.data);
  //     } else {
  //       print("❌ Failed to fetch task: ${response.data}");
  //       return null;
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching task: $e");
  //     return null;
  //   }
  // }
  Future<Task?> getTaskById(int taskId) async {
    try {
      isLoading.value = true;
      final task = await TaskService.getTaskById(taskId);
      if (task != null) {
        print("Task loaded: ${task.title}");
        return task; // trả về task cho caller
      } else {
        print("Task not found for ID: $taskId");
        return null;
      }
    } catch (e) {
      print("Error loading task by ID: $e");
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateTask(Task task) async {
    isLoading.value = true;

    try {
      final success = await TaskService.updateTask(task);
      if (!success) return false;

      // 🔄 Update task trong danh sách chính
      int index = taskList.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        taskList[index] = task;
        taskList.refresh();
      }

      // 🔄 Update ở các list khác nếu bạn có dùng
      _updateTaskInList(matrixTasks, task);
      _updateTaskInList(fullDayTaskList, task);
      _updateTaskInList(taskListByCategory, task);

      // 🔔 Notification logic (nếu có reminderTime)
      if (task.reminderTime != null &&
          task.reminderTime!.isAfter(DateTime.now())) {
        print("🔔 TODO: Update scheduled notification...");
      }

      print("🎉 [Controller] Task updated");
      return true;
    } finally {
      isLoading.value = false;
    }
  }

  // helper update cho list phụ
  void _updateTaskInList(RxList<Task> list, Task updated) {
    int index = list.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      list[index] = updated;
      list.refresh();
    }
  }
  // Future<bool> deleteTask({required int taskId}) async {
  //   try {
  //     final response =
  //         await ApiService.dio.delete('${ApiService.baseUrl}/tasks/$taskId');

  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       print("✅ Task deleted successfully!");

  //       // Xóa task khỏi list local
  //       taskListByCategory.removeWhere((task) => task.id == taskId);
  //       taskList.removeWhere((task) => task.id == taskId);

  //       return true;
  //     } else {
  //       print("❌ Failed to delete task: ${response.data}");
  //       return false;
  //     }
  //   } catch (e) {
  //     print("❌ Error deleting task: $e");
  //     return false;
  //   }
  // }
}
