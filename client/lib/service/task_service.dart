import 'dart:convert';

import 'package:flutter_to_do_app/model/task.dart';
import 'package:http/http.dart' as http;

class TaskService {
  static const String baseUrl = "http://localhost:8000";

  //update tasks
  static Future<void> updateTask(Task updatedTask) async {
    final url = Uri.parse('$baseUrl/tasks/${updatedTask.id}');
    try {
      final response = await http.put(
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

//get all tasks by date---------------------------------------------------------------
  static Future<List<Task>> getTasksByDate(String due_date) async {
    final response =
        await http.get(Uri.parse('$baseUrl/tasks/by_category/$due_date'));
    print("loading in loading tasks");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("successing in loading tasks");

      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  //get all tasks by category_id---------------------------------------------------------------
  static Future<List<Task>> getTasksByCategoryId(String categoryId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/tasks/by_category/$categoryId'));
    print("loading in loading tasks");

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      print("successing in loading tasks");

      return jsonData.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load tasks');
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
    final response = await http.get(Uri.parse('$baseUrl/tasks/'));
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

//delete tasks
  static Future<void> deleteTask(String taskId) async {
    final url = Uri.parse('$baseUrl/tasks/$taskId');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print("Task Deleted Successfully");
      } else {
        print("Failed to delete task: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

// Create task
  static Future<bool> createTask({Task? task}) async {
    if (task == null) return false;
    // print("cat id in createTask in taskService: " + task.categoryId); // OK
    try {
      // Tạo Map chứa nội dung body
      final Map<String, dynamic> jsonBody = {
        "title": task.title,
        "description": task.description,
        "category_id": task.categoryId.toString(), // Đảm bảo là UUID string
        "due_date": task.dueDate,
        "time": task.time,
      };

      // In JSON để kiểm tra
      // print(
      //     "JSON body gửi đi: ${jsonEncode(jsonBody)}");  //OK

      final response = await http.post(
        Uri.parse("$baseUrl/tasks/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer your_access_token", // Nếu API cần token
        },
        body: jsonEncode(jsonBody), // id category OK
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Task created successfully!");
        return true;
      } else {
        print("Failed to create task: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
