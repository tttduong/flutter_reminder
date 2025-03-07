import 'dart:convert';

import 'package:flutter_to_do_app/model/task.dart';
import 'package:http/http.dart' as http;

class TaskService {
  static const String baseUrl = "http://localhost:8000";

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

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tasks/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer your_access_token", // Nếu API cần token
        },
        body: jsonEncode({
          "title": task.title,
          "description": task.description,
        }),
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
