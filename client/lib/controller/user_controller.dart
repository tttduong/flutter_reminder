import 'package:get/get.dart';

class UserController extends GetxController {
  RxnString userName = RxnString();

  void setUserName(String name) {
    userName.value = name;
  }

  void clearUser() {
    userName.value = null;
  }
}
