import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts.dart';
import '../models/models.dart';
import '../../ui/utils/error_handling.dart';
import '../../ui/utils/utils.dart';

class AuthService {
  /// A function for Sign-Up user account,
  /// Success : return User model,
  /// Fail : return null
  // static Future<User?> signUpUser({
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
  static Future<User?> signInUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      UserAuth userAuth = UserAuth(email, password);

      http.Response res = await http.post(
        Uri.parse("${Constants.URI}/api/v1/login"),
        body: {
          'username': userAuth.email,
          'password': userAuth.password,
        },
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      bool hasError =
          ErrorHandling.httpErrorHandling(response: res, context: context);
      if (hasError) return null;

      /// Execute successfully
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['access_token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          print("✅ Token saved: $token");
          // return User.fromJson(res.body);
          // ✅ Gọi Provider tại đây để set user (nếu muốn)
          final user =
              await AuthService.getUser(context: context, token: token);

          if (user != null) {
            context.read<UserProvider>().setUserFromModel(user);
            return user;
          }
        }
      } else {
        print("Đăng nhập thất bại: ${res.body}");
      }
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
      return null;
    }
  }

  /// A function for getting User account's datas via token,
  /// Success : return User model,
  /// Fail : return null
  static Future<User?> getUser({
    required BuildContext context,
    required String token,
  }) async {
    try {
      http.Response res = await http.get(
        Uri.parse("${Constants.URI}/api/v1/me"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode != 200) return null;

      return User.fromJson(res.body);
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
      return null;
    }
  }
}
