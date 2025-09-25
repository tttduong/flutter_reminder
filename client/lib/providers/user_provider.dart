import 'package:flutter/material.dart';

import '../data/models/login_model.dart';

class UserProvider extends ChangeNotifier {
  //* If [_user] is null, if not Signed-In
  User? _user;

  UserProvider();
  // {
  //   _user = User(
  //     username: '',
  //     email: '',
  //     token: '',
  //   );
  // }

  User? get user => _user;

  // void setUserFromJson(String user) {
  //   // NOTE : JSON format, in dart is actually String data type
  //   _user = User.fromJson(user);
  //   notifyListeners();
  // }

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
}
