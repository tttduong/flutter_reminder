import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/controller/user_controller.dart';
import 'package:flutter_to_do_app/data/models/login_model.dart';
import 'package:flutter_to_do_app/data/models/user.dart';
import 'package:flutter_to_do_app/providers/user_provider.dart';
import 'package:flutter_to_do_app/data/services/auth_services.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:flutter_to_do_app/ui/widgets/widgets.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../controller/category_controller.dart';
import '../../data/models/category.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  // Rxn<Category> selectedCategory = Rxn<Category>();

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  Future<void> _signInSuccess(LoginModel userData) async {
    bool isSaveSuccess =
        await LocalStoreServices.saveInLocal(context, userData);
    if (isSaveSuccess) {
      print("ahihi login thanh cong");
      if (!mounted) return;
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      // userProvider.setUserFromModel(userData.data);
      userProvider.setUserFromLoginModel(userData);
    }
  }

  void _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      // ✅ 1. Login qua ApiService (Dio + cookie)
      final response = await ApiService.login(email, password);
      print("📦 Login response: $response");

      // ✅ 2. Debug cookies sau login
      final cookies = await ApiService.cookieJar.loadForRequest(Uri.parse(
              "http://10.106.193.30:8000/") // nếu server set path /api/v1, đổi thành /api/v1
          );
      print("🍪 Cookies after login: $cookies");

      // ✅ 3. Set user vào Provider
      if (response['user'] != null) {
        Provider.of<UserProvider>(context, listen: false)
            .setUserFromModel(User.fromJson(response['user']));
      }

      // ✅ 4. Fetch categories
      final categoryController = Get.find<CategoryController>();
      await categoryController.getCategories();

      // ✅ 5. Set default category (Inbox)
      if (response['default_category'] != null) {
        categoryController.selectedCategory.value =
            Category.fromJson(response['default_category']);
      }

      print("📦 Default Category: ${response['default_category']?['id']}");

      // ✅ 6. Điều hướng sang màn chính
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BottomNavBarScreen(
            initialCategory: response['default_category'] != null
                ? Category.fromJson(response['default_category'])
                : null,
          ),
        ),
      );
    } catch (e) {
      print("❌ Login failed: $e");
      // có thể show dialog alert lỗi
    }
  }

  // void _signIn() async {
  //   final loginModel = await AuthService.signInUser(
  //     context: context,
  //     email: _emailController.text,
  //     password: _passwordController.text,
  //   );

  //   if (loginModel != null) {
  //     // ✅ 1. Lưu token
  //     // await LocalStoreServices.saveToken(loginModel.token!);

  //     // ✅ 2. Set user vào Provider
  //     Provider.of<UserProvider>(context, listen: false)
  //         .setUserFromModel(loginModel.user!);

  //     // ✅ 3. Get categories
  //     final categoryController = Get.find<CategoryController>();
  //     await categoryController.getCategories();

  //     // ✅ 4. Gán default category (Inbox)
  //     if (loginModel.defaultCategory != null) {
  //       categoryController.selectedCategory.value = loginModel.defaultCategory!;
  //     }

  //     // ✅ 5. Điều hướng sang màn chính
  //     // Navigator.of(context).pushReplacement(
  //     //   MaterialPageRoute(builder: (context) => const BottomNavBarScreen()),
  //     // );
  //     print("📦 Default Category: ${loginModel.defaultCategory?.id}");

  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (context) => BottomNavBarScreen(
  //           initialCategory: loginModel.defaultCategory,
  //         ),
  //       ),
  //     );
  //   }
  // }

  /// Change to SignUp Page
  void _changeToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
    // Get.to(() => const SignUpPage());
    // Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sign-In into user account",
                style: TextStyle(fontSize: 28)),
            const SizedBox(height: 40),
            CustomTextField(
                controller: _emailController, hintText: "User email"),
            const SizedBox(height: 15),
            CustomTextField(
                controller: _passwordController, hintText: "User password"),
            const SizedBox(height: 35),
            CustomElevatedButton(onPressfunc: _signIn, buttonText: 'Sign In'),
            const SizedBox(height: 10),
            TextButton(
              onPressed:
                  // _changeToSignUp,
                  //     () async {
                  //   print("Login pressed");
                  //   try {
                  //     final res = await ApiService.dio.post('/login', data: {
                  //       "username": _emailController.text,
                  //       "password": _passwordController.text,
                  //     });
                  //     print("Login response: ${res.data}");
                  //   } catch (e) {
                  //     print("Login error: $e");
                  //   }
                  // },
                  () async {
                try {
                  await ApiService.login(
                      _emailController.text, _passwordController.text);
                  final cookies = await ApiService.cookieJar
                      .loadForRequest(Uri.parse("http://10.106.193.30:8000/"));
                  print("🍪 Cookies after login: $cookies");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage()),
                  );
                } catch (e) {
                  print("Login failed: $e");
                }
              },
              child: const Text(
                'go to Create user accout',
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.login(
                      _emailController.text, _passwordController.text);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatPage()),
                  );
                } catch (e) {
                  print("Login failed: $e");
                }
              },
              child: Text("Login"),
            )
          ],
        ),
      ),
    );
  }
}
