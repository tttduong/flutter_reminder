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
    baseUrl: "http://10.121.205.30:8000", // đổi theo BE của bạn
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static final cookieJar = CookieJar();
  static void init() {
    dio.interceptors.add(CookieManager(cookieJar));
  }
  // static Future<void> init() async {
  //   final dir = await getApplicationDocumentsDirectory();

  //   // ⭐ Sử dụng PersistCookieJar với config tốt hơn
  //   cookieJar = PersistCookieJar(
  //     storage: FileStorage("${dir.path}/.cookies/"),
  //     ignoreExpires: true, // Cho phép cookie không expire (dev only)
  //   );

  //   dio = Dio(BaseOptions(
  //     baseUrl: "http://10.121.205.30:8000",
  //     connectTimeout: const Duration(seconds: 10),
  //     receiveTimeout: const Duration(seconds: 10),
  //     followRedirects: true,
  //     validateStatus: (status) => status! < 500, // ⭐ Cho phép handle 4xx
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //     },
  //   ))
  //     ..interceptors.add(CookieManager(cookieJar))
  //     ..interceptors.add(LogInterceptor(
  //       requestHeader: true,
  //       requestBody: true,
  //       responseHeader: true,
  //       responseBody: true,
  //       error: true,
  //       logPrint: (obj) => print('🔍 DIO: $obj'),
  //     ))
  //     // ⭐ THÊM: Interceptor để debug cookies được gửi
  //     ..interceptors.add(InterceptorsWrapper(
  //       onRequest: (options, handler) async {
  //         final cookies = await cookieJar.loadForRequest(options.uri);
  //         print('📤 Sending request to: ${options.uri}');
  //         print(
  //             '🍪 Cookies being sent: ${cookies.map((c) => '${c.name}=${c.value}').join('; ')}');
  //         return handler.next(options);
  //       },
  //       onResponse: (response, handler) async {
  //         final cookies =
  //             await cookieJar.loadForRequest(response.requestOptions.uri);
  //         print('📥 Response from: ${response.requestOptions.uri}');
  //         print(
  //             '🍪 Cookies after response: ${cookies.map((c) => '${c.name}=${c.value}').join('; ')}');
  //         return handler.next(response);
  //       },
  //     ));

  //   print("✅ ApiService initialized with baseUrl: ${dio.options.baseUrl}");

  //   // Debug: Xem có cookies nào được lưu không
  //   final cookies =
  //       await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl));
  //   print(
  //       "📌 Initial saved cookies: ${cookies.map((c) => '${c.name}=${c.value}').join('; ')}");
  // }

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
  // Login
  // static Future<Map<String, dynamic>> login(
  //     String username, String password) async {
  //   final response = await dio.post('/api/v1/login', data: {
  //     "username": username,
  //     "password": password,
  //   });

  //   print("Login response: ${response.data}");

  //   final cookies =
  //       await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl!));
  //   print("Cookies after login: $cookies");

  //   return Map<String, dynamic>.from(response.data);
  // }

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
}
