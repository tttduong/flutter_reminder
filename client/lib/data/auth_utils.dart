import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static String? token;
  static String? username;
  static String? email;
  // static String? mobile;
  // static String? photo;

  static Future<void> saveUserData(
    String userToken,
    String username,
    String userEmail,
    // String userMobile,
    // String userPhoto,
  ) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString('token', userToken);
    await sharedPreferences.setString('firstName', username);
    await sharedPreferences.setString('email', userEmail);
    // await sharedPreferences.setString('mobile', userMobile);
    // await sharedPreferences.setString('photo', userPhoto);

    //
    token = userToken;
    username = username;
    // lastName = userLastName;
    email = userEmail;
    // mobile = userMobile;
    // photo = userPhoto;
  }

  //
  static Future<bool> checkLoginState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? token = sharedPreferences.getString('token');
    if (token == null) {
      return false;
    }
    return true;
  }

  //
  static Future<void> getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    username = sharedPreferences.getString('username');
    email = sharedPreferences.getString('email');
    // mobile = sharedPreferences.getString('mobile');
    // photo = sharedPreferences.getString('photo');
  }

  //
  static Future<void> clearData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.clear();
  }
}
