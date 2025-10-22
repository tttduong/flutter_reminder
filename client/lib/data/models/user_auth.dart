import 'dart:convert';

/// [UserAuth] for using with SignIn and SignUp
class UserAuth {
  final String email;
  final String password;
  final String username;
  final String confirmPassword;

  UserAuth(this.email, this.password, this.confirmPassword,
      {this.username = ""});

  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'username': username,
        'confirm_password': confirmPassword,
      };

  // factory UserAuth.fromMap(Map<String, dynamic> map) {
  //   return UserAuth(
  //     map['email'] ?? '',
  //     map['password'] ?? '',
  //     username: map['username'] ?? '',

  //   );
  // }

  String toJson() => json.encode(toMap());

  // factory UserAuth.fromJson(String source) =>
  //     UserAuth.fromMap(json.decode(source));
}
