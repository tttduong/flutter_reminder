// api.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_to_do_app/data/models/task_intent_response.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  // static var baseUrl = "http://10.244.81.30:8000";
  static var baseUrl = "http://192.168.1.11:8000";

  // static late Dio dio;
  // static late PersistCookieJar cookieJar;
  static final Dio dio = Dio(BaseOptions(
    baseUrl: baseUrl, // đổi theo BE
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // static final cookieJar = CookieJar();

  // static void init() {
  //   dio.interceptors.add(CookieManager(cookieJar));
  // }
  // ✅ Sử dụng PersistCookieJar thay vì CookieJar
  static late PersistCookieJar cookieJar;

  // ✅ Cần khởi tạo async vì PersistCookieJar cần path
  static Future<void> init() async {
    // Lấy thư mục lưu cookies
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    // Khởi tạo PersistCookieJar với path
    cookieJar = PersistCookieJar(
      ignoreExpires: false, // Tùy chọn: giữ cookie dù hết hạn
      storage: FileStorage(appDocPath + "/.cookies/"),
    );

    // ✅ Clear interceptors cũ trước (nếu có)
    dio.interceptors.clear();

    // Thêm cookie manager vào dio
    dio.interceptors.add(CookieManager(cookieJar));

    // ✅ Thêm logging interceptor để debug
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Debug: In cookies sẽ được gửi
          final cookies = await cookieJar.loadForRequest(options.uri);
          print("📤 Sending request to: ${options.uri}");
          print(
              "📤 Cookies to send: ${cookies.map((c) => '${c.name}=${c.value.substring(0, 10)}...').join(', ')}");
          return handler.next(options);
        },
        onError: (error, handler) {
          print("❌ Request error: ${error.message}");
          return handler.next(error);
        },
      ),
    );

    print(
        "✅ ApiService initialized with PersistCookieJar at: $appDocPath/.cookies/");
    // // Thêm cookie manager vào dio
    // dio.interceptors.add(CookieManager(cookieJar));

    // print("✅ ApiService initialized with PersistCookieJar");
  }

  // ⭐ Thêm method để clear cookies (khi logout)
  static Future<void> clearCookies() async {
    await cookieJar.deleteAll();
    print("🗑️ All cookies cleared");
  }

  // ⭐ Thêm method để check login status
  // static Future<bool> hasValidSession() async {
  //   final cookies = await cookieJar
  //       .loadForRequest(Uri.parse("${dio.options.baseUrl}/api/v1/categories/"));
  //   // Django session thường có cookie name là 'sessionid'
  //   return cookies.any((c) => c.name == 'sessionid' || c.name == 'csrftoken');
  // }
  static Future<bool> hasValidSession() async {
    try {
      final uri =
          Uri.parse("$baseUrl/api/v1/categories/"); // hoặc endpoint nào đó
      final cookies = await cookieJar.loadForRequest(uri);

      print("🍪 Cookies loaded for ${uri.toString()}:");
      if (cookies.isEmpty) {
        print("  ❌ No cookies found!");
        return false;
      }

      for (var cookie in cookies) {
        print(
            "  - ${cookie.name}: ${cookie.value.substring(0, 20)}... (expires: ${cookie.expires})");
      }

      // ✅ Check sessionid tồn tại và còn hạn
      bool hasSessionId =
          cookies.any((c) => c.name == 'sessionid' && c.value.isNotEmpty);
      return hasSessionId;
    } catch (e) {
      print("❌ Error checking session: $e");
      return false;
    }
  }

  // Gửi chat

  static Future<Map<String, dynamic>> sendChat({
    required String message,
    required List<Map<String, String>> conversationHistory,
    String? systemPrompt,
    // String model = "llama-3.1-8b-instant",
    String model = "gpt-4o-mini",
    String? conversationId,
    String? mode,
  }) async {
    final cookies =
        await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl));
    // print("📌 Cookies before sendChat: $cookies");

    // print("➡️ Sending chat request to ${dio.options.baseUrl}/chat/");
    // print("Payload: {message: $message, model: $model}");
    print("⬅️ MODE: ${mode}");

    // Chọn endpoint dựa vào mode
    String endpoint = '/api/v1/chat/';
    // if (mode == "generate_plan") {
    // endpoint = '/api/v1/chat/create_tasks_from_schedule';
    // }
    final response = await dio.post(endpoint, data: {
      "conversation_id": conversationId,
      "message": message,
      "model": model,
      "conversation_history": conversationHistory,
      "system_prompt": systemPrompt ?? "",
      "mode": mode, // gửi luôn mode nếu backend cần
    });

    // print("⬅️ Response status: ${response.statusCode}");
    // print("⬅️ Response data: ${response.data}");

    return response.data;
  }

  static Future<Map<String, dynamic>> sendScheduleMessage({
    required String conversation_id,
    required String message,
  }) async {
    final response = await dio.post('/api/v1/chat/schedule', data: {
      'conversation_id': conversation_id,
      "message": message,
      "model": "gpt-4o-mini",
    });
    return response.data;
  }

  // static Future<Map<String, dynamic>> createTasksFromSchedule({
  //   required Map<String, dynamic> scheduleDraft,
  // }) async {
  //   final response = await dio.post(
  //     "/api/v1/chat/create_tasks_from_schedule",
  //     data: {
  //       "schedule_json": scheduleDraft,
  //     },
  //   );
  //   return response.data;
  // }

  static Future<Map<String, dynamic>> createTasksFromSchedule({
    required Map<String, dynamic> scheduleDraft,
    int? categoryId, // ✅ Thêm parameter này
  }) async {
    // Transform the schedule draft to include proper date/due_date
    final transformedDraft = _transformScheduleForTaskCreation(scheduleDraft);

    final response = await dio.post(
      "/api/v1/chat/create_tasks_from_schedule",
      data: {
        "schedule_json": transformedDraft,
        "category_id": categoryId, // ✅ Gửi categoryId lên backend
      },
    );
    return response.data;
  }

  /// Transform schedule draft to include date and due_date for each task
  static Map<String, dynamic> _transformScheduleForTaskCreation(
    Map<String, dynamic> draft,
  ) {
    final transformed = Map<String, dynamic>.from(draft);

    if (transformed["days"] is List) {
      transformed["days"] = (transformed["days"] as List).map((day) {
        final dayMap = Map<String, dynamic>.from(day as Map);
        final dateStr = dayMap["date"] as String?; // "2025-01-15"

        if (dayMap["tasks"] is List && dateStr != null) {
          dayMap["tasks"] = (dayMap["tasks"] as List).map((task) {
            final taskMap = Map<String, dynamic>.from(task as Map);
            final timeStr = taskMap["time"] as String? ?? "09:00"; // "14:30"
            final durationMinutes =
                _parseDuration(taskMap["length"]); // "1.5h" or "90m"

            // ✅ Combine date + time to create start datetime
            final dateTime = DateTime.parse("$dateStr $timeStr");
            taskMap["date"] = dateTime.toUtc().toIso8601String();

            // ✅ Calculate due_date based on duration
            if (durationMinutes > 0) {
              final dueDateTime =
                  dateTime.add(Duration(minutes: durationMinutes));
              taskMap["due_date"] = dueDateTime.toUtc().toIso8601String();
            } else {
              // Default: due_date = same day end of day (17:00)
              final endOfDay = DateTime.parse("$dateStr 17:00");
              taskMap["due_date"] = endOfDay.toUtc().toIso8601String();
            }

            return taskMap;
          }).toList();
        }

        return dayMap;
      }).toList();
    }

    return transformed;
  }

  /// Parse duration string to minutes
  /// Examples: "1.5h" -> 90, "30m" -> 30, "1h30m" -> 90
  // static int _parseDuration(dynamic lengthValue) {
  //   if (lengthValue == null) return 0;

  //   final length = lengthValue.toString().toLowerCase().trim();

  //   // ✅ Handle "1 hour", "2 hours", "1.5 hours"
  //   if (length.contains("hour")) {
  //     // Extract number before "hour"
  //     final regex = RegExp(r'(\d+\.?\d*)\s*hour');
  //     final match = regex.firstMatch(length);
  //     if (match != null) {
  //       final hours = double.tryParse(match.group(1)!) ?? 0;
  //       return (hours * 60).toInt();
  //     }
  //   }

  //   // Handle "1.5h" or "1h"
  //   if (length.contains("h") && !length.contains("hour")) {
  //     if (length.contains("m")) {
  //       // "1h30m"
  //       final parts = length.split("h");
  //       final hours = int.tryParse(parts[0]) ?? 0;
  //       final minutes = int.tryParse(parts[1].replaceAll("m", "")) ?? 0;
  //       return (hours * 60) + minutes;
  //     } else {
  //       // "1.5h"
  //       final hours = double.tryParse(length.replaceAll("h", "")) ?? 0;
  //       return (hours * 60).toInt();
  //     }
  //   }

  //   // Handle "30m", "30 minutes", "1 minute"
  //   if (length.contains("m")) {
  //     final regex = RegExp(r'(\d+\.?\d*)\s*m');
  //     final match = regex.firstMatch(length);
  //     if (match != null) {
  //       return int.tryParse(match.group(1)!) ?? 0;
  //     }
  //   }

  //   return 0;
  // }
  /// Parse duration string to minutes - handles all common formats
  /// Examples:
  /// - "1 hour" → 60
  /// - "2 hours" → 120
  /// - "1.5 hours" → 90
  /// - "1h" → 60
  /// - "1.5h" → 90
  /// - "1h30m" → 90
  /// - "90 minutes" → 90
  /// - "1 minute" → 1
  /// - "30m" → 30
  /// - "30 mins" → 30
  /// - "1h 30m" → 90
  /// - "1 hour 30 minutes" → 90
  static int _parseDuration(dynamic lengthValue) {
    if (lengthValue == null) return 0;

    final length = lengthValue.toString().toLowerCase().trim();
    if (length.isEmpty) return 0;

    int totalMinutes = 0;

    // ✅ Handle hours (both "hour" and "h")
    // Patterns: "1 hour", "2 hours", "1.5h", "1h", "1 h"
    final hourRegex = RegExp(r'(\d+\.?\d*)\s*hours?');
    final hourMatch = hourRegex.firstMatch(length);
    if (hourMatch != null) {
      final hours = double.tryParse(hourMatch.group(1)!) ?? 0;
      totalMinutes += (hours * 60).toInt();

      // Remove matched part to process remaining
      final remaining = length.replaceFirst(hourRegex, '').trim();

      // Process remaining for additional minutes
      if (remaining.isNotEmpty) {
        totalMinutes += _parseDuration(remaining);
      }

      return totalMinutes;
    }

    // ✅ Handle "1h30m" format (compact, no spaces)
    if (length.contains("h") && !length.contains("hour")) {
      final compactRegex = RegExp(r'(\d+\.?\d*)h(\d+\.?\d*)?m?');
      final compactMatch = compactRegex.firstMatch(length);
      if (compactMatch != null) {
        final hours = double.tryParse(compactMatch.group(1)!) ?? 0;
        totalMinutes += (hours * 60).toInt();

        if (compactMatch.group(2) != null) {
          final mins = double.tryParse(compactMatch.group(2)!) ?? 0;
          totalMinutes += mins.toInt();
        }

        return totalMinutes;
      }
    }

    // ✅ Handle minutes (both "minute(s)" and "m(ins)")
    // Patterns: "90 minutes", "30 minute", "45m", "60 mins"
    final minuteRegex = RegExp(r'(\d+\.?\d*)\s*(?:minutes?|mins?)');
    final minuteMatch = minuteRegex.firstMatch(length);
    if (minuteMatch != null) {
      final mins = double.tryParse(minuteMatch.group(1)!) ?? 0;
      totalMinutes += mins.toInt();

      return totalMinutes;
    }

    // ✅ Handle "Xh Ym" format with spaces
    // Pattern: "1 h 30 m" or "1 hour 30 minutes"
    if (length.contains("h") || length.contains("hour")) {
      final hourRegex2 = RegExp(r'(\d+\.?\d*)\s*(?:hours?|h)');
      final hourMatch2 = hourRegex2.firstMatch(length);
      if (hourMatch2 != null) {
        final hours = double.tryParse(hourMatch2.group(1)!) ?? 0;
        totalMinutes += (hours * 60).toInt();
      }

      final minRegex2 = RegExp(r'(\d+\.?\d*)\s*(?:minutes?|m)');
      final minMatch2 = minRegex2.firstMatch(length);
      if (minMatch2 != null) {
        final mins = double.tryParse(minMatch2.group(1)!) ?? 0;
        totalMinutes += mins.toInt();
      }

      return totalMinutes;
    }

    // ✅ Fallback: just extract first number if it's pure minutes
    // Pattern: "90" or "120"
    if (totalMinutes == 0) {
      final numberRegex = RegExp(r'(\d+\.?\d*)');
      final numberMatch = numberRegex.firstMatch(length);
      if (numberMatch != null) {
        return int.tryParse(numberMatch.group(1)!) ?? 0;
      }
    }

    return totalMinutes;
  }

  static Future<Map<String, dynamic>> getScheduleDraft() async {
    final response = await dio.get("/api/v1/chat/schedule/get");
    return response.data;
  }

  static Future<List<TaskIntentResponse>> parseTask({
    required String message,
  }) async {
    try {
      final response = await dio.post('/api/v1/chat/parse_task', data: {
        'message': message,
      });

      print("🌐 Parse Task API Response: ${response.statusCode}");
      print("📦 Response body: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is List) {
          return data.map((e) => TaskIntentResponse.fromJson(e)).toList();
        } else {
          throw Exception('Invalid response format: expected a List');
        }
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print("❌ Parse Task Error: $e");

      return [
        TaskIntentResponse(
          intent: "small_talk",
          title: "",
          description: "",
          categoryId: 0,
          date: DateTime.now(),
          dueDate: null,
        )
      ];
    }
  }

  static Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required int categoryId,
    required DateTime date,
    DateTime? dueDate,
  }) async {
    final data = {
      "title": title,
      "description": description,
      "category_id": categoryId,
      "date": date.toUtc().toIso8601String(), // đảm bảo UTC ISO 8601
      if (dueDate != null) "due_date": dueDate.toUtc().toIso8601String(),
    };

    final response = await dio.post("/api/v1/tasks/", data: data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception("Failed to create task: ${response.data}");
    }
  }
}
