import 'dart:convert';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String baseUrl = "${Constants.URI}/api/v1";

  // Lấy danh sách tất cả categories
  static Future<List<Category>> fetchCategories() async {
    final response = await ApiService.dio.get('/categories/');

    print("📦 Status: ${response.statusCode}");
    print("📤 Data: ${response.data}");

    List<dynamic> jsonData = response.data;
    return jsonData.map((cat) => Category.fromJson(cat)).toList();
  }

  // Xóa category theo ID
  static Future<void> deleteCategory(int categoryId) async {
    try {
      final response = await ApiService.dio.delete('/categories/$categoryId/');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Category deleted successfully!");
      } else {
        print("Failed to create category: ${response.data}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Tạo category mới
  static Future<bool> createCategory({Category? category}) async {
    if (category == null) return false;
    try {
      final response = await ApiService.dio.post(
        '/categories/',
        data: {
          "title": category.title,
          "color":
              "#${category.color.value.toRadixString(16).padLeft(8, '0').substring(2)}",
          "icon": category.icon.codePoint.toString(), // Lưu mã icon\
          "is_default": false
          // "is_default": category.isDefault ?? false,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Category created successfully!");
        return true;
      } else {
        print("Failed to create category: ${response.data}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
