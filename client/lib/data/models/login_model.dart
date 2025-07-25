class LoginModel {
  String? status;
  String? token;
  User? user;

  LoginModel({this.status, this.token, this.user});

  LoginModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    user = json['data'] != null ? User.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['token'] = token;
    if (this.user != null) {
      data['data'] = this.user!.toJson();
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
