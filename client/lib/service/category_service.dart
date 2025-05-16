import 'dart:convert';
import 'package:flutter_to_do_app/model/category.dart';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = "http://localhost:8000";

  // Lấy danh sách tất cả categories
  static Future<List<Category>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/'));
    print("Loading categories...");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("Successfully loaded categories");

      return jsonData.map((category) => Category.fromJson(category)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Xóa category theo ID
  static Future<void> deleteCategory(String categoryId) async {
    final url = Uri.parse('$baseUrl/categories/$categoryId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("Category Deleted Successfully");
      } else {
        print("Failed to delete category: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Tạo category mới
  static Future<bool> createCategory({Category? category}) async {
    if (category == null) return false;

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/categories/"),
        // headers: {
        //   "Content-Type": "application/json",
        //   "Authorization": "Bearer your_access_token", // Nếu API cần token
        // },
        headers: {
          "Content-Type": "application/json", // Đảm bảo gửi đúng JSON
        },
        body: jsonEncode({
          "title": category.title,
          "color":
              "#${category.color.value.toRadixString(16).padLeft(8, '0').substring(2)}",

          "icon": category.icon.codePoint.toString(), // Lưu mã icon
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Category created successfully!");
        return true;
      } else {
        print("Failed to create category: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
