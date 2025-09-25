import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  var categoryList = <Category>[].obs;
  // Rxn<Category> selectedCategory = Rxn<Category>(); //toi day rui
  var selectedCategory = Rxn<Category>(); // Rxn cho phép null
  final TaskController taskController = Get.find<TaskController>();
  @override
  void onInit() {
    super.onInit();
    getCategories();
    updateAllCategoryStats();
    // ever(taskController.taskList, (_) {
    //   updateAllCategoryStats();
    // });
  }

// Lấy tất cả danh mục từ API
  // void getCategories() async {
  //   categoryList.value = await CategoryService.fetchCategories();
  // }
  Future<void> getCategories() async {
    try {
      // gọi API
      // final categories = await CategoryService.fetchCategories();
      final categories = await CategoryService.fetchCategoriesWithStats();
      // for (var category in categories) {
      //   category.updateStats(taskController.taskList);
      // }
      categoryList.value = categories;
      // updateAllCategoryStats();

      print("Successfully loaded categories");
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  void updateCategoryStatsByTask(Task task) {
    final category =
        categoryList.firstWhereOrNull((c) => c.id == task.categoryId);
    if (category != null) {
      final tasksInCategory = taskController.taskList
          .where((t) => t.categoryId == category.id)
          .toList();
      category.totalCount = tasksInCategory.length;
      category.completedCount =
          tasksInCategory.where((t) => t.isCompleted).length;

      categoryList.refresh();
    }
  }

  void updateCategoryStatsById(int? categoryId) {
    final category = categoryList.firstWhereOrNull((c) => c.id == categoryId);
    if (category != null) {
      // Tính lại số completed/total dựa trên taskController.taskList
      final tasksInCategory = taskController.taskList
          .where((t) => t.categoryId == categoryId)
          .toList();
      category.totalCount = tasksInCategory.length;
      category.completedCount =
          tasksInCategory.where((t) => t.isCompleted).length;

      categoryList.refresh(); // refresh để sidebar cập nhật
    }
  }

  void updateAllCategoryStats() {
    for (var category in categoryList) {
      final tasksInCategory = taskController.taskList
          .where((t) => t.categoryId == category.id)
          .toList();
      category.totalCount = tasksInCategory.length;
      category.completedCount =
          tasksInCategory.where((t) => t.isCompleted).length;
    }
    categoryList.refresh();
  }

  Future<void> addCategory({Category? category}) async {
    if (category == null) {
      print("Category is null");
      return;
    }

    bool success = await CategoryService.createCategory(category: category);
    if (success) {
      getCategories(); // Refresh danh sách category sau khi thêm
    }
  }

  // Xóa category theo ID
  Future<void> deleteCategory(int categoryId) async {
    await CategoryService.deleteCategory(categoryId);
    categoryList.removeWhere((category) => category.id == categoryId);
    update(); // Cập nhật UI
  }
}
