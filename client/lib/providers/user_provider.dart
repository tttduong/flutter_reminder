// UserProvider = Global state manager để:

// Lưu user hiện tại trong memory
// Chia sẻ user data cho toàn app
// Auto-rebuild UI khi user thay đổi
// Check authentication status

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import '../data/services/local_store_services.dart';
import '../data/models/login_model.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  UserProvider();

  User? get user => _user;

  void setUserFromModel(User user) {
    _user = user;
    notifyListeners();
  }

  void setUserNull() {
    _user = null;
    notifyListeners();
  }

  void setUserFromLoginModel(LoginModel loginModel) {
    if (loginModel.user != null) {
      final data = loginModel.user!;

      _user = User(
        id: data.id,
        email: data.email ?? '',
        username: (data.username ?? '').trim(),
        // mobile: data.mobile,
        // photo: data.photo,
      );

      notifyListeners();
    }
  }

  // Load user từ API
  Future<bool> loadCurrentUser() async {
    print("\n🔍 ===== loadCurrentUser START =====");

    try {
      print("📤 Calling API: ${ApiService.baseUrl}/api/v1/users/me/");

      final response = await ApiService.dio.get('/api/v1/users/me/');

      print("✅ Response received!");
      print("📊 Status: ${response.statusCode}");
      print("📊 Data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data;

        print("🔍 Parsing user data...");
        print("   - id: ${userData['id']}");
        print("   - username: ${userData['username']}");
        print("   - email: ${userData['email']}");

        _user = User(
          id: userData['id'],
          username: (userData['username'] ?? '').trim(),
          email: userData['email'] ?? '',
        );

        print("✅ User object created: ${_user?.username}");

        // Lưu vào local storage
        await LocalStoreServices.saveUser(_user!);
        print("✅ User saved to local storage");

        notifyListeners();
        print("✅ notifyListeners() called");

        print("🔍 ===== loadCurrentUser SUCCESS =====\n");
        return true;
      }

      print("⚠️ Unexpected response status: ${response.statusCode}");
      print("🔍 ===== loadCurrentUser FAILED =====\n");
      return false;
    } catch (e) {
      print("❌ ERROR in loadCurrentUser:");
      print("   Type: ${e.runtimeType}");
      print("   Message: $e");

      if (e is DioException) {
        print("   Status: ${e.response?.statusCode}");
        print("   Data: ${e.response?.data}");
        print("   Path: ${e.requestOptions.path}");
      }

      _user = null;
      notifyListeners();

      print("🔍 ===== loadCurrentUser ERROR =====\n");
      return false;
    }
  }

  // Load user từ local storage
  Future<void> loadUserFromLocal() async {
    print("\n🔍 ===== loadUserFromLocal START =====");

    try {
      final user = await LocalStoreServices.getUser();

      if (user != null) {
        _user = user;
        notifyListeners();
        print("✅ User loaded from local: ${_user?.username}");
      } else {
        print("⚠️ No user found in local storage");
      }

      print("🔍 ===== loadUserFromLocal END =====\n");
    } catch (e) {
      print("❌ Failed to load user from local: $e");
      print("🔍 ===== loadUserFromLocal ERROR =====\n");
    }
  }

  // Clear user + local storage
  Future<void> clearUser() async {
    print("🗑️ clearUser called");
    _user = null;
    await LocalStoreServices.clearUser();
    notifyListeners();
  }
}
