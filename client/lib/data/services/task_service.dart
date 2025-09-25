import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  static const String baseUrl = "${Constants.URI}/api/v1";
  // final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));
  // Future<bool> updateTaskStatusAPI(int taskId, bool isCompleted) async {
  //   try {
  //     final dto = UpdateTaskStatusDto(isCompleted: isCompleted);
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('access_token');

  //     final response = await _dio.patch(
  //       "/tasks/$taskId",
  //       data: dto.toJson(),
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token', // Adjust format as needed
  //           'Content-Type': 'application/json',
  //         },
  //       ),
  //     );

  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print('Error updating task: $e');
  //     return false;
  //   }
  // }

  //update tasks
  static Future<void> updateTask(Task updatedTask) async {
    final url = Uri.parse('$baseUrl/tasks/${updatedTask.id}/');
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': updatedTask.title,
          'description': updatedTask.description,
          'is_completed': updatedTask.isCompleted,
          // ... các trường khác
        }),
      );
      if (response.statusCode == 200) {
        print("Task updated successfully");
      } else {
        print("Failed to update task: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  //get all incompleted tasks by category_id
  static Future<List<Task>> fetchIncompletedTasksByCategoryId(
      String categoryId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/tasks/by_category?category_id=$categoryId&is_completed=false'));

    print("loading incompleted tasks for category $categoryId");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("successfully loaded incompleted tasks");

      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load incompleted tasks');
    }
  }

  //get all completed tasks by category_id
  static Future<List<Task>> fetchCompletedTasksByCategoryId(
      String categoryId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/tasks/by_category?category_id=$categoryId&is_completed=true'));

    print("loading completed tasks for category $categoryId");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("successfully loaded completed tasks");

      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load completed tasks');
    }
  }

//get all tasks
  static Future<List<Task>> fetchTasks() async {
    // final prefs = await SharedPreferences.getInstance();
    // final token = prefs.getString('access_token');

    // if (token == null) {
    //   print("Chưa có token, bạn cần login trước");
    //   // return false;
    // }
    final response = await http.get(Uri.parse('$baseUrl/tasks/'));

    // final response = await http.get(
    //   Uri.parse('$baseUrl/tasks/'),
    //   headers: {
    //     "Content-Type": "application/json",
    //     "Authorization": "Bearer $token", // Nếu API cần token
    //   },
    // );
    print("loading in loading tasks");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("successing in loading tasks");

      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

//get all completed tasks
  // static Future<List<Task>> fetchCompletedTasks() async {
  //   final response =
  //       await http.get(Uri.parse('$baseUrl/tasks/?is_completed=false'));
  //   print("loading in loading tasks");

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonData = json.decode(response.body);
  //     print("successing in loading tasks");

  //     return jsonData.map((task) => Task.fromJson(task)).toList();
  //   } else {
  //     throw Exception('Failed to load tasks');
  //   }
  // }

//------------service đã chuyển đổi dùng session---------------------------------------------------------------

//get all tasks by category_id
  static Future<List<Task>> getTasksByCategoryId(int? categoryId) async {
    try {
      // final response = await ApiService.dio.get(
      //   '/tasks/by-category/',
      //   queryParameters:
      //       categoryId != null ? {"category_id": categoryId} : null,
      // );
      final response = await ApiService.dio.get(
        '$baseUrl/tasks/by-category/',
        queryParameters:
            categoryId != null ? {"category_id": categoryId} : null,
      );

      print("service load task from cate ID: $categoryId");
      print("📦 Status: ${response.statusCode}");
      print("📤 Data: ${response.data}");

      List<dynamic> jsonData = response.data;
      return jsonData.map((task) => Task.fromJson(task)).toList();
    } catch (e) {
      print("🔥 Error loading tasks: $e");
      throw Exception('Failed to load tasks');
    }
  }

  static Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await ApiService.dio
          .get('$baseUrl/tasks/by-date/?date=$formattedDate');

      if (response.statusCode == 200) {
        // List<dynamic> jsonData = json.decode(response.data);
        List<dynamic> jsonData = response.data;
        return jsonData.map((item) => Task.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load tasks by date (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching tasks by date: $e');
    }
  }

//delete tasks
  static Future<void> deleteTask(int taskId) async {
    final url = Uri.parse('$baseUrl/tasks/${taskId}/');
    try {
      final response = await ApiService.dio.delete('$baseUrl/tasks/${taskId}/');
      if (response.statusCode == 200) {
        print("Task Deleted Successfully");
      } else {
        print("Failed to delete task: ${response.data}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

// Create task
  static Future<bool> createTask({Task? task}) async {
    if (task == null) return false;

    try {
      // Convert DateTime to UTC and format as ISO8601 string with timezone
      String? formatDateTimeToUTC(DateTime? dateTime) {
        if (dateTime == null) return null;
        // Convert to UTC if not already, then format with 'Z' suffix
        return dateTime.toUtc().toIso8601String();
      }

      final response = await ApiService.dio.post('$baseUrl/tasks/', data: {
        "title": task.title,
        "description": task.description,
        "category_id": task.categoryId,
        "date": formatDateTimeToUTC(task.date),
        "due_date": formatDateTimeToUTC(task.dueDate),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Task created successfully!");
        return true;
      } else {
        print("Failed to create task: ${response.data}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

//update complete
  static Future<bool> updateTaskStatus(Task updatedTask, bool newStatus) async {
    try {
      final response = await ApiService.dio.patch(
        '$baseUrl/tasks/${updatedTask.id}/',
        data: {
          "completed": newStatus, // chỉ gửi field cần update
        },
      );

      if (response.statusCode == 200) {
        print("✅ Updated task status successfully");
        return true;
      } else {
        print("❌ Failed to update task status: ${response.data}");
        return false;
      }
    } catch (e) {
      print("🔥 Error updating task: $e");
      return false;
    }
  }
}
