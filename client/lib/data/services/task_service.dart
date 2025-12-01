import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/data/services/auth_services.dart';
import 'package:flutter_to_do_app/data/services/notification_service.dart';
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

// //get all tasks
//   static Future<List<Task>> fetchTasks() async {
//     // final prefs = await SharedPreferences.getInstance();
//     // final token = prefs.getString('access_token');

//     // if (token == null) {
//     //   print("Chưa có token, bạn cần login trước");
//     //   // return false;
//     // }
//     final response = await http.get(Uri.parse('$baseUrl/tasks/'));

//     // final response = await http.get(
//     //   Uri.parse('$baseUrl/tasks/'),
//     //   headers: {
//     //     "Content-Type": "application/json",
//     //     "Authorization": "Bearer $token", // Nếu API cần token
//     //   },
//     // );
//     print("loading in loading tasks");
//     print("ApiService initialized with baseUrl: $baseUrl");

//     if (response.statusCode == 200) {
//       List<dynamic> jsonData = json.decode(response.body);
//       print("successing in loading tasks--- SERVICE----");

//       return jsonData.map((task) => Task.fromJson(task)).toList();
//     } else {
//       throw Exception('Failed to load tasks --- SERVICE----');
//     }
//   }
  static Future<List<Task>> fetchTasks() async {
    final response = await ApiService.dio.get('/api/v1/tasks/');
    List<dynamic> jsonData = response.data;
    return jsonData.map((task) => Task.fromJson(task)).toList();
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

// Lấy các task full day (chỉ có date, không có due_date)
  static Future<List<Task>> getSingleDayTasks(DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await ApiService.dio.get(
        '$baseUrl/tasks/single-day/',
        queryParameters: {'date': dateStr},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Task.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting single day tasks: $e');
      return [];
    }
  }

//get all tasks by category_id
  static Future<List<Task>> getTasksByCategoryId(int? categoryId) async {
    try {
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

  static Future<bool> createTask({Task? task}) async {
    if (task == null) return false;

    try {
      String? formatDateTimeToUTC(DateTime? dateTime) {
        if (dateTime == null) return null;
        return dateTime.toUtc().toIso8601String().replaceAll('Z', '+00:00');
      }

      // 1️⃣ Tạo task trên server trước
      final response = await ApiService.dio.post('$baseUrl/tasks/', data: {
        "title": task.title,
        "description": task.description,
        "category_id": task.categoryId,
        "date": formatDateTimeToUTC(task.date),
        "due_date": formatDateTimeToUTC(task.dueDate),
        "priority": task.priority,
        "reminder_time": formatDateTimeToUTC(task.reminderTime),
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final taskIdFromServer = response.data['id'];
        task.id = taskIdFromServer;

        print("✅ Task created successfully with ID: $taskIdFromServer");

        // 2️⃣ Schedule notification nếu có reminderTime
        if (task.reminderTime != null &&
            task.reminderTime!.isAfter(DateTime.now())) {
          try {
            final notificationResponse = await ApiService.dio.post(
              '$baseUrl/schedule-notification',
              data: {
                "title": "Reminder",
                "body": task.title,
                "send_at": formatDateTimeToUTC(task.reminderTime),
              },
            );

            if (notificationResponse.statusCode == 200) {
              print("✅ Notification scheduled successfully!");
              print("   Reminder will be sent at: ${task.reminderTime}");
            } else {
              print(
                  "⚠️ Failed to schedule notification: ${notificationResponse.data}");
            }
          } catch (e) {
            print("⚠️ Error scheduling notification: $e");
            // Không return false vì task đã tạo thành công
          }
        } else {
          print("ℹ️ No reminder set or reminder time is in the past");
        }

        return true;
      } else {
        print("❌ Failed to create task: ${response.data}");
        return false;
      }
    } catch (e) {
      print("❌ Error creating task: $e");
      return false;
    }
  }

  Future<void> scheduleNotificationOnServer({
    required String title,
    required String body,
    required DateTime sendAt,
  }) async {
    await ApiService.dio.post(
      "/api/v1/notifications/schedule",
      data: {
        "title": title,
        "body": body,
        "send_at": sendAt.toUtc().toIso8601String(),
      },
    );
  }

// //update complete
//   static Future<bool> updateTaskStatus(Task updatedTask, bool newStatus) async {
//     try {
//       final response = await ApiService.dio.patch(
//         '$baseUrl/tasks/${updatedTask.id}/',
//         data: {
//           "completed": newStatus, // chỉ gửi field cần update
//           "completed_at": .....
//         },
//       );

//       if (response.statusCode == 200) {
//         print("✅ Updated task status successfully");
//         return true;
//       } else {
//         print("❌ Failed to update task status: ${response.data}");
//         return false;
//       }
//     } catch (e) {
//       print("🔥 Error updating task: $e");
//       return false;
//     }
//   }
// }

// update complete
  static Future<bool> updateTaskStatus(Task updatedTask, bool newStatus) async {
    try {
      // Nếu vừa đánh dấu hoàn thành -> gửi thời gian hiện tại (UTC)
      // Nếu bỏ đánh dấu -> gửi null
      final completedAt =
          newStatus ? DateTime.now().toUtc().toIso8601String() : null;

      final response = await ApiService.dio.patch(
        '$baseUrl/tasks/${updatedTask.id}/',
        data: {
          "completed": newStatus,
          "completed_at": completedAt, // ✅ gửi completed_at cùng completed
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
