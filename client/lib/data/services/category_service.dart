import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CategoryService {
  static const String baseUrl = "${Constants.URI}/api/v1";
  static Future<List<Category>?> fetchCategories() async {
    try {
      final response = await ApiService.dio.get('/api/v1/categories/');
      print("Request URL: ${response.realUri}");
      print("📦 Status: ${response.statusCode}");
      print("📤 Data: ${response.data}");

      // ⭐ Kiểm tra nếu response trống hoặc user chưa đăng nhập
      if (response.data == null || response.data.isEmpty) {
        return null;
      }

      List<dynamic> jsonData = response.data;
      return jsonData.map((cat) => Category.fromJson(cat)).toList();
    } on DioException catch (e) {
      // ⭐ Handle lỗi 401/403 (chưa đăng nhập)
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        print("⚠️ User chưa đăng nhập");
        return null;
      }
      rethrow;
    }
  }

  static Future<List<Category>?> fetchCategoriesWithStats() async {
    try {
      final response =
          await ApiService.dio.get('/api/v1/categories-with-stats/');

      if (response.data == null || response.data.isEmpty) {
        return null;
      }

      List<dynamic> jsonData = response.data;
      return jsonData.map((cat) => Category.fromJson(cat)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return null;
      }
      rethrow;
    }
  }
  // Lấy danh sách tất cả categories
  // static Future<List<Category>> fetchCategories() async {
  //   final response = await ApiService.dio.get('/api/v1/categories/');
  //   print("Request URL: ${response.realUri}");
  //   print("📦 Status: ${response.statusCode}");
  //   print("📤 Data: ${response.data}");

  //   List<dynamic> jsonData = response.data;
  //   return jsonData.map((cat) => Category.fromJson(cat)).toList();
  // }

  // static Future<List<Category>> fetchCategoriesWithStats() async {
  //   final response = await ApiService.dio.get('/api/v1/categories-with-stats/');
  //   List<dynamic> jsonData = response.data;
  //   return jsonData.map((cat) => Category.fromJson(cat)).toList();
  // }

  // Xóa category theo ID
  static Future<void> deleteCategory(int categoryId) async {
    try {
      final response =
          await ApiService.dio.delete('/api/v1/categories/$categoryId/');

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
        '/api/v1/categories/',
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
