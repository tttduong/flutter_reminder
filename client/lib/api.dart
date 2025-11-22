// api.dart
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_to_do_app/data/models/task_intent_response.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  // static late Dio dio;
  // static late PersistCookieJar cookieJar;
  static final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.244.81.30:8000", // đổi theo BE
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static final cookieJar = CookieJar();
  static void init() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  // ⭐ Thêm method để clear cookies (khi logout)
  static Future<void> clearCookies() async {
    await cookieJar.deleteAll();
    print("🗑️ All cookies cleared");
  }

  // ⭐ Thêm method để check login status
  static Future<bool> hasValidSession() async {
    final cookies = await cookieJar
        .loadForRequest(Uri.parse("${dio.options.baseUrl}/api/v1/categories/"));
    // Django session thường có cookie name là 'sessionid'
    return cookies.any((c) => c.name == 'sessionid' || c.name == 'csrftoken');
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
    if (mode == "generate_plan") {
      endpoint = '/api/v1/chat/create_tasks_from_schedule';
    }
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
