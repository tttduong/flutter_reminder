import 'dart:convert';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/model/test.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = "http://127.0.0.1:8000";
  static const String baseUrl = "http://localhost:8000";

  late Test testModule;
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

  // Future<Test> fetch() async {
  //   final response = await http.get(Uri.parse('$baseUrl/test'));

  //   if (response.statusCode == 200) {
  //     return Test.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load test');
  //   }
  // }

  // Future<Test> fetch() async {
  //   final response = await http.get(Uri.parse('$baseUrl/test'));
  //   print("loading in loading test");

  //   if (response.statusCode == 200) {
  //     final parsedData = json.decode(response.body);
  //     String title = parsedData['title'];
  //     print("successing in loading test");

  //     return testModule = Test(title: title);
  //   } else {
  //     print("Failing in loading tasks");
  //     throw Exception('Failed to load users');
  //   }
  // }
}
