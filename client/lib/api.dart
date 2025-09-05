// api.dart
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
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
      baseUrl: "http://10.106.193.30:8000/api/v1",
    ))
      ..interceptors.add(CookieManager(cookieJar));
    print("✅ ApiService initialized with baseUrl: ${dio.options.baseUrl}");
  }

  // Login
  static Future<void> login(String username, String password) async {
    final response = await dio.post('/login', data: {
      "username": username,
      "password": password,
    });
    print("-------------------------------Login response: ${response.data}");
    final cookies =
        await cookieJar.loadForRequest(Uri.parse(dio.options.baseUrl!));
    print(
        "===========================================Cookies after login: $cookies");
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

    final response = await dio.post('/chat/', data: {
      "message": message,
      "model": model,
      "conversation_history": conversationHistory,
      "system_prompt": systemPrompt ?? "",
    });

    print("⬅️ Response status: ${response.statusCode}");
    print("⬅️ Response data: ${response.data}");

    return response.data;
  }
}
