import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  var categoryList = <Category>[].obs;
  // Rxn<Category> selectedCategory = Rxn<Category>(); //toi day rui
  var selectedCategory = Rxn<Category>(); // Rxn cho phép null

  @override
  void onInit() {
    super.onInit();
    getCategories();
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

  // Lấy tất cả danh mục từ API
  // void getCategories() async {
  //   categoryList.value = await CategoryService.fetchCategories();
  // }
  Future<void> getCategories() async {
    try {
      // gọi API
      final categories = await CategoryService.fetchCategories();
      categoryList.value = categories;
      print("Successfully loaded categories");
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  // Xóa category theo ID
  Future<void> deleteCategory(int categoryId) async {
    await CategoryService.deleteCategory(categoryId);
    categoryList.removeWhere((category) => category.id == categoryId);
    update(); // Cập nhật UI
  }
}
