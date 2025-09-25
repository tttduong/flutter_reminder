import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/screens/signin_screen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../data/models/login_model.dart';
import '../../data/models/models.dart';
import '../../providers/providers.dart';
import '../../data/services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  /// Call this if Sign-Up via backend-API successfully
  Future<void> _signUpSuccess(LoginModel userData) async {
    bool isSaveSuccess =
        await LocalStoreServices.saveInLocal(context, userData);
    if (isSaveSuccess) {
      if (!mounted) return;
      // NOTE : Update UserProvider
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      // userProvider.setUserFromModel(userData);
      userProvider.setUserFromLoginModel(userData);

      // ✅ Hiện thông báo và điều hướng sang trang đăng nhập
      Utils.showSnackBar(context, "Tạo tài khoản thành công!");

      // ✅ Delay chút cho SnackBar hiển thị rồi mới chuyển trang
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  /// Trigger this when "Sign Up" button is clicked
  void _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      Utils.showSnackBar(
          context, 'Password and Confirm-Passord does not match!');
      return;
    }

    // NOTE : If signing-up failed, return null
    User? userAccount = await AuthService.signUpUser(
      context: context,
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );
    print("sign up - userAccount: $userAccount");
    // await _signUpSuccess(userAccount!);

    // if (userAccount != null) {
    //   // NOTE : Process, if Sign-Up via API successfully
    //   print("user not null");
    //   // ✅ Lưu local và cập nhật provider
    //   await _signUpSuccess(userAccount);
    // } else {
    //   print("user null");
    // }
  }

  /// Change to SignIn Page
  void _changeToSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
    // Get.to(() => const SignInPage());
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sign-up an account", style: TextStyle(fontSize: 28)),
            const SizedBox(height: 30),
            CustomTextField(
                controller: _usernameController, hintText: "Type Username"),
            const SizedBox(height: 15),
            CustomTextField(
                controller: _emailController, hintText: "Type Email"),
            const SizedBox(height: 15),
            CustomTextField(
                controller: _passwordController, hintText: "Type Password"),
            const SizedBox(height: 15),
            CustomTextField(
                controller: _confirmPasswordController,
                hintText: "Confirm Password"),
            const SizedBox(height: 30),
            CustomElevatedButton(onPressfunc: _signUp, buttonText: 'Sign Up'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _changeToSignIn,
              child: const Text(
                'go to Login user',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
