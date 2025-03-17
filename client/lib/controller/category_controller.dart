import 'package:flutter_to_do_app/model/category.dart';
import 'package:flutter_to_do_app/service/category_service.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var categoryList = <Category>[].obs;

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
  void getCategories() async {
    categoryList.value = await CategoryService.fetchCategories();
  }

  // Xóa category theo ID
  // Future<void> deleteCategory(String categoryId) async {
  //   await CategoryService.deleteCategory(categoryId);
  //   categoryList.removeWhere((category) => category.id == categoryId);
  //   update(); // Cập nhật UI
  // }
}
