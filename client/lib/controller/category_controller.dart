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
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    getCategories();
    updateAllCategoryStats();
    // ever(taskController.taskList, (_) {
    //   updateAllCategoryStats();
    // });
  }

  // ⭐ Thêm method để refresh sau login
  Future<void> refreshCategories() async {
    print("🔄 Refreshing categories...");
    await getCategories();
    await updateAllCategoryStats();
  }

  Future<void> getCategories() async {
    try {
      isLoading.value = true; // ⭐ Bật loading

      var response = await CategoryService.fetchCategories();

      if (response != null && response.isNotEmpty) {
        categoryList.assignAll(response);

        // Sort để default category lên đầu
        categoryList.sort((a, b) {
          if ((a.isDefault ?? false) && !(b.isDefault ?? false)) return -1;
          if ((b.isDefault ?? false) && !(a.isDefault ?? false)) return 1;
          return 0;
        });

        print("✅ Loaded ${categoryList.length} categories");
      } else {
        categoryList.clear();
        print("⚠️ Không có categories hoặc chưa đăng nhập");
      }
    } catch (e) {
      print("❌ Error getting categories: $e");
      categoryList.clear();
    } finally {
      isLoading.value = false; // ⭐ Tắt loading
    }
  }

// Lấy tất cả danh mục từ API
  // void getCategories() async {
  //   categoryList.value = await CategoryService.fetchCategories();
  // }
  // Future<void> getCategories() async {
  //   try {
  //     // gọi API
  //     // final categories = await CategoryService.fetchCategories();
  //     final categories = await CategoryService.fetchCategoriesWithStats();
  //     // for (var category in categories) {
  //     //   category.updateStats(taskController.taskList);
  //     // }
  //     categoryList.value = categories;
  //     // updateAllCategoryStats();

  //     print("Successfully loaded categories");
  //   } catch (e) {
  //     print("Failed to load categories: $e");
  //   }
  // }
  // Future<void> getCategories() async {
  //   try {
  //     var response = await CategoryService.fetchCategories();

  //     // ⭐ Kiểm tra null
  //     if (response != null && response.isNotEmpty) {
  //       categoryList.assignAll(response);

  //       categoryList.sort((a, b) {
  //         if ((a.isDefault ?? false) && !(b.isDefault ?? false)) return -1;
  //         if ((b.isDefault ?? false) && !(a.isDefault ?? false)) return 1;
  //         return 0;
  //       });
  //     } else {
  //       // ⭐ Clear list nếu chưa đăng nhập
  //       categoryList.clear();
  //       print("⚠️ Không có categories hoặc chưa đăng nhập");
  //     }
  //   } catch (e) {
  //     print("Error getting categories: $e");
  //     categoryList.clear(); // Clear khi có lỗi
  //   }
  // }
  // Future<void> getCategories() async {
  //   try {
  //     var response = await CategoryService.fetchCategories();

  //     if (response != null) {
  //       categoryList.assignAll(response);

  //       // Sắp xếp: is_default = true lên đầu, sau đó theo thứ tự khác
  //       categoryList.sort((a, b) {
  //         // Nếu a là default và b không phải -> a lên trước
  //         if ((a.isDefault ?? false) && !(b.isDefault ?? false)) return -1;
  //         // Nếu b là default và a không phải -> b lên trước
  //         if ((b.isDefault ?? false) && !(a.isDefault ?? false)) return 1;
  //         // Nếu cả hai cùng là default hoặc cùng không phải -> giữ thứ tự hiện tại
  //         return 0;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error getting categories: $e");
  //   }
  // }

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

  Future<void> updateAllCategoryStats() async {
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
  // Future<void> deleteCategory(int categoryId) async {
  //   await CategoryService.deleteCategory(categoryId);
  //   categoryList.removeWhere((category) => category.id == categoryId);
  //   update(); // Cập nhật UI
  // }
  Future<bool> deleteCategory(Category category) async {
    // ❌ Không cho xóa default category
    if (category.isDefault) {
      return false;
    }

    await CategoryService.deleteCategory(category.id);

    categoryList.removeWhere((c) => c.id == category.id);
    update();

    return true;
  }
}
