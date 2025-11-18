import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
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
  // 🟢 Đăng xuất user
  static Future<bool> logout() async {
    try {
      final response = await ApiService.dio.post('/api/v1/logout');
      print("📤 Logout response: ${response.data}");

      if (response.statusCode == 200) {
        print("✅ Logged out successfully");
        return true;
      } else {
        print("⚠️ Logout failed: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error during logout: $e");
      return false;
    }
  }

  /// A function for Sign-Up user account,
  /// Success : return User model,
  /// Fail : return null
  static Future<User?> signUpUser({
    required BuildContext context,
    required String email,
    required String username,
    required String password,
    required String confirm_password,
  }) async {
    try {
      UserAuth userAuth =
          UserAuth(email, password, confirm_password, username: username);

      http.Response res = await http.post(
        Uri.parse("${Constants.URI}/api/v1/register"),
        body: jsonEncode(userAuth.toMap()),
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

  static Future<LoginModel?> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // ✅ Gửi JSON body
      final res = await ApiService.dio.post(
        "${Constants.URI}/api/v1/login",
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.jsonContentType, // JSON
        ),
      );

      if (res.statusCode == 200) {
        final data = res.data;
        print("📦 Full login response: $data");

        return LoginModel(
          user: data['user'] != null ? User.fromJson(data['user']) : null,
          defaultCategory: data['default_category'] != null
              ? Category.fromJson(data['default_category'])
              : null,
        );
      } else {
        print("Đăng nhập thất bại: ${res.data}");
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
    }

    return null;
  }

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
