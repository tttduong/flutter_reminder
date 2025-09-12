// api.dart
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_to_do_app/data/models/task_intent_response.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  // static final Dio dio = Dio()..interceptors.add(CookieManager(CookieJar()));
  // Optionally, bạn có thể đặt base URL mặc định
  // static void init(String baseUrl) {
  //   dio.options.baseUrl = baseUrl;
  //   dio.options.followRedirects = true;
  //   dio.options.validateStatus = (status) => status! < 400;
  // }

  // static final CookieJar cookieJar = CookieJar();
  // static final Dio dio = Dio(BaseOptions(
  //   baseUrl: "http://10.106.193.30:8000/api/v1", // base URL của backend
  // ))
  //   ..interceptors.add(CookieManager(cookieJar));

  static late Dio dio;
  static late PersistCookieJar cookieJar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage("${dir.path}/.cookies/"),
    );
    dio = Dio(BaseOptions(
      baseUrl: "http://10.106.193.30:8000",
    ))
      ..interceptors.add(CookieManager(cookieJar));
    print("✅ ApiService initialized with baseUrl: ${dio.options.baseUrl}");
    print("📌 Cookies sent for request: $cookieJar");
  }

  // Login
  // static Future<void> login(String username, String password) async {
  //   final response = await dio.post('/api/v1/login', data: {
  //     "username": username,
  //     "password": password,
  //   });
  //   print("-------------------------------Login response: ${response.data}");
  //   final cookies =
  //       await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl!));
  //   print(
  //       "===========================================Cookies after login: $cookies");
  // }
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    final response = await dio.post('/api/v1/login', data: {
      "username": username,
      "password": password,
    });

    print("Login response: ${response.data}");

    final cookies =
        await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl!));
    print("Cookies after login: $cookies");

    return Map<String, dynamic>.from(response.data);
  }

  // Gửi chat

  static Future<Map<String, dynamic>> sendChat({
    required String message,
    required List<Map<String, String>> conversationHistory,
    String? systemPrompt,
    String model = "llama-3.1-8b-instant",
  }) async {
    final cookies =
        await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl));
    print("📌 Cookies before sendChat: $cookies");

    print("➡️ Sending chat request to ${dio.options.baseUrl}/chat/");
    print("Payload: {message: $message, model: $model}");

    final response = await dio.post('/api/v1/chat/', data: {
      "message": message,
      "model": model,
      "conversation_history": conversationHistory,
      "system_prompt": systemPrompt ?? "",
    });

    print("⬅️ Response status: ${response.statusCode}");
    print("⬅️ Response data: ${response.data}");

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

  // Method gọi endpoint /chat/parse_task
  // static Future<Map<String, dynamic>> parseTask({
  //   required String message,
  // }) async {
  //   try {
  //     final response = await dio.post('/chat/parse_task', data: {
  //       'message': message,
  //     });

  //     print("🌐 Parse Task API Response: ${response.statusCode}");
  //     print("📦 Response body: ${response.data}");

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = response.data;

  //       // Validate response structure
  //       if (data.containsKey('intent')) {
  //         return data;
  //       } else {
  //         throw Exception('Invalid response format: missing intent field');
  //       }
  //     } else {
  //       throw Exception('API Error: ${response.statusCode} - ${response.data}');
  //     }
  //   } catch (e) {
  //     print("❌ Parse Task Error: $e");

  //     // Fallback response
  //     return {
  //       // "intent": "small_talk",
  //       // "title": "",
  //       // "date": "",
  //       // "time": "",
  //       "intent": "small_talk",
  //       "title": "",
  //       "description": "",
  //       "category_id": "",
  //       "date": "",
  //       "due_date": "",
  //     };
  //   }
  // }

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
