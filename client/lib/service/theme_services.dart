// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';

// class ThemeService {
//   final _box = GetStorage();
//   final _key = 'isDarkMode';
//   _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);
//   bool _loadThemeFromBox() => _box.read(_key) ?? false;
//   ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;
//   void switchTheme() {
//     Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
//     _saveThemeToBox(!_loadThemeFromBox());
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  /// Lưu trạng thái theme
  void _saveTheme(bool isDarkMode) => _box.write(_key, isDarkMode);

  /// Lấy trạng thái theme đã lưu
  bool _loadTheme() => _box.read(_key) ?? false;

  /// Hàm chuyển đổi theme
  void switchTheme() {
    bool isDark = !_loadTheme();
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    _saveTheme(isDark);
  }

  /// Trả về theme hiện tại
  ThemeMode get theme => _loadTheme() ? ThemeMode.dark : ThemeMode.light;
}
