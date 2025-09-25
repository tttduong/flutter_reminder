import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/models/login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// import '../models/models.dart';
import '../../consts.dart';
import '../../ui/utils/utils.dart';

class LocalStoreServices {
  static late SharedPreferences pref;
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
}
