import 'dart:convert';

import 'package:flutter_to_do_app/model/task.dart';
import 'package:http/http.dart' as http;

class TaskService {
  static const String baseUrl = "http://localhost:8000";

  Future<List<Task>> fetchTasks() async {
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
}
