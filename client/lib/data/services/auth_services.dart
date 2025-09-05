import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts.dart';
import '../models/category.dart';
import '../models/login_model.dart';
import '../models/models.dart';
import '../../ui/utils/error_handling.dart';
import '../../ui/utils/utils.dart';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class AuthService {
  /// A function for Sign-Up user account,
  /// Success : return User model,
  /// Fail : return null
  static Future<User?> signUpUser({
    required BuildContext context,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      UserAuth userAuth = UserAuth(email, password, username: username);

      http.Response res = await http.post(
        Uri.parse("${Constants.URI}/api/v1/register"),
        // body: userAuth.toJson(),
        body: jsonEncode(userAuth.toJson()),
        // body: jsonEncode({
        //   "email": email,
        //   "password": password,
        //   "username": username,
        // }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      print(jsonEncode(userAuth.toJson()));

      bool hasError =
          ErrorHandling.httpErrorHandling(response: res, context: context);

      /// Has HTTP Error
      if (hasError) return null;

      /// Execute successfully
      return User.fromJson(jsonDecode(res.body));

      // return null;
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
      return null;
    }
  }

  /// A function for Sign-Up user account,
  /// Success : return User model,
  /// Fail : return null
  // static Future<LoginModel?> signInUser({
  //   required BuildContext context,
  //   required String email,
  //   required String password,
  // }) async {
  //   try {
  //     UserAuth userAuth = UserAuth(email, password);

  //     http.Response res = await http.post(
  //       Uri.parse("${Constants.URI}/api/v1/login"),
  //       body: {
  //         'username': userAuth.email,
  //         'password': userAuth.password,
  //       },
  //       headers: <String, String>{
  //         'Content-Type': 'application/x-www-form-urlencoded',
  //       },
  //     );

  //     bool hasError =
  //         ErrorHandling.httpErrorHandling(response: res, context: context);
  //     if (hasError) return null;

  //     // if (res.statusCode == 200) {
  //     //   final data = jsonDecode(res.body);
  //     //   print("📦 Full login response: $data");
  //     //   print("🔥 Default category: ${data['default_category']}");

  //     //   final token = data['access_token'];

  //     //   if (token != null) {
  //     //     final prefs = await SharedPreferences.getInstance();
  //     //     await prefs.setString('access_token', token);

  //     //     // ✅ Tạo LoginModel từ toàn bộ response data
  //     //     return LoginModel(
  //     //       token: token,
  //     //       user: data['user'] != null ? User.fromJson(data['user']) : null,
  //     //       defaultCategory: data['default_category'] != null
  //     //           ? Category.fromJson(data['default_category'])
  //     //           : null,
  //     //     );
  //     //   }
  //     // } else {
  //     //   print("Đăng nhập thất bại: ${res.body}");
  //     // }
  //   } catch (e) {
  //     Utils.showSnackBar(context, e.toString());
  //   }

  //   return null; // ✅ Thêm return null để tránh lỗi "might complete without returning"
  // }
  static Future<LoginModel?> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Tạo Dio client + cookie jar
      final dio = Dio();
      final cookieJar = CookieJar();
      dio.interceptors.add(CookieManager(cookieJar));

      // 2️⃣ Gửi request login (x-www-form-urlencoded hoặc JSON)
      final res = await dio.post(
        "${Constants.URI}/api/v1/login",
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      // 3️⃣ Check response
      if (res.statusCode == 200) {
        final data = res.data;
        print("📦 Full login response: $data");
        print("🔥 Default category: ${data['default_category']}");

        // 4️⃣ Tạo LoginModel từ response JSON (không cần token)
        return LoginModel(
          user: data['user'] != null ? User.fromJson(data['user']) : null,
          defaultCategory: data['default_category'] != null
              ? Category.fromJson(data['default_category'])
              : null,
          // token: không còn cần nữa
        );
      } else {
        print("Đăng nhập thất bại: ${res.data}");
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
    }

    return null;
  }

  /// A function for getting User account's datas via token,
  /// Success : return User model,
  /// Fail : return null
  // static Future<User?> getUser({
  //   required BuildContext context,
  //   required String token,
  // }) async {
  //   try {
  //     http.Response res = await http.get(
  //       Uri.parse("${Constants.URI}/api/v1/me"),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (res.statusCode != 200) return null;

  //     // return User.fromJson(res.body);
  //     final userJson = jsonDecode(res.body);
  //     print("📦 userJson from BE: $userJson");
  //     return User.fromJson(userJson);
  //   } catch (e) {
  //     Utils.showSnackBar(context, e.toString());
  //     return null;
  //   }
  // }
  static Future<User?> getUser({
    // required BuildContext context,
    required String token,
  }) async {
    try {
      print("📤 Gửi request GET /me với token: $token");

      final res = await http.get(
        Uri.parse("${Constants.URI}/api/v1/me"),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Status code: ${res.statusCode}");
      print("📥 Response body: ${res.body}");

      if (res.statusCode != 200) {
        print("⚠️ Không phải 200, trả về null");
        return null;
      }

      final userJson = jsonDecode(res.body); // ✅ FIXED!
      print("📦 userJson from BE: $userJson");

      return User.fromJson(userJson); // ✅ FIXED!
    } catch (e, stack) {
      print("❌ Exception trong getUser: $e");
      print("🪵 Stacktrace: $stack");
      // Utils.showSnackBar(context, e.toString());
      return null;
    }
  }
}
