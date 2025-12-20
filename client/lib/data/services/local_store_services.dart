import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../models/models.dart';
import '../../consts.dart';
import '../../ui/utils/utils.dart';

class LocalStoreServices {
  static late SharedPreferences pref;
  static const String _userKey = 'user_data';
  static Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('access_token', token);
  }

  static Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString('access_token');
  }

  /// Lưu token
  // static Future<bool> saveToken(String token) async {
  //   return await pref.setString('token', token);
  // }

  // /// Lấy token
  // static String? getToken() {
  //   return pref.getString('token');
  // }

  /// Xoá token
  static Future<bool> clearToken() async {
    return await pref.remove('token');
  }

  /// Save token data into local storage,
  /// Success : return True,
  /// Fail : return False
  static Future<bool> saveInLocal(
      BuildContext context, LoginModel userData) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (userData.token == null) {
        throw Exception("Token is null, cannot save.");
      }
      return await pref.setString(
        Constants.LOCAL_STORAGE_TOKEN_KEY,
        userData.token!,
      );
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
      return false;
    }
  }

  /// Remove token data from local storage,
  /// Success : return True,
  /// Fail : return False
  static Future<bool> removeFromLocal(BuildContext context) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      return await pref.remove(Constants.LOCAL_STORAGE_TOKEN_KEY);
    } catch (e) {
      Utils.showSnackBar(context, e.toString());
      return false;
    }
  }

  /// Get token data from local storage,
  /// Success : return Token (String),
  /// Fail : return null
  static Future<String?> getFromLocal(BuildContext context) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if (!pref.containsKey(Constants.LOCAL_STORAGE_TOKEN_KEY)) return null;
      return pref.getString(Constants.LOCAL_STORAGE_TOKEN_KEY);
    } catch (e) {
      // NOTE : should not trigger this part
      //        just for a possible failure
      Utils.showSnackBar(context, e.toString());
      return null;
    }
  }

  // ✅ Lưu user vào local storage
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userKey, userJson);
      print("✅ User saved to local storage: ${user.username}");
    } catch (e) {
      print("❌ Error saving user: $e");
    }
  }

  // ✅ Lấy user từ local storage
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        final user = User.fromJson(userMap);
        print("✅ User loaded from local: ${user.username}");
        return user;
      }

      print("⚠️ No user in local storage");
      return null;
    } catch (e) {
      print("❌ Error loading user: $e");
      return null;
    }
  }

  // ✅ Xóa user khỏi local storage
  static Future<void> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print("🗑️ User cleared from local storage");
    } catch (e) {
      print("❌ Error clearing user: $e");
    }
  }

  // ✅ Xóa toàn bộ local storage
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print("🗑️ All local storage cleared!");
    } catch (e) {
      print("❌ Error clearing all: $e");
    }
  }
}
