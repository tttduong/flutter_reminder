import 'category.dart';

class LoginModel {
  String? status;
  String? token;
  User? user;
  final Category? defaultCategory;

  LoginModel({
    this.status,
    this.token,
    this.user,
    this.defaultCategory,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'],
      token: json['access_token'] ?? json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      defaultCategory: json['default_category'] != null
          ? Category.fromJson(json['default_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['token'] = token;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (defaultCategory != null) {
      data['default_category'] = defaultCategory!.toJson();
    }
    return data;
  }
}

class User {
  final int? id;
  final String? email;
  final String? username;
  // final String? mobile;
  // final String? photo;

  User({
    this.id,
    this.email,
    this.username,
    // this.mobile,
    // this.photo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      // mobile: json['mobile'],
      // photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        // 'mobile': mobile,
        // 'photo': photo,
      };
}
