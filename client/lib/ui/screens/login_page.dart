import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/services/auth_services.dart';
import 'package:flutter_to_do_app/providers/user_provider.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
import 'package:flutter_to_do_app/ui/screens/home.dart';
import 'package:flutter_to_do_app/ui/screens/register_page.dart';
import 'package:flutter_to_do_app/ui/utils/utils.dart';
import 'package:flutter_to_do_app/ui/widgets/auth_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              // const SizedBox(height: 8),
              const Text(
                'Login now to track all your expenses and income at a place!',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
              const SizedBox(height: 50),
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Ex: abc@example.com',
                    hintStyle: const TextStyle(color: Colors.black26),
                    prefixIcon: const Icon(Icons.alternate_email,
                        color: Color(0xFF6366F1)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF6366F1), width: 1.5),
                      borderRadius: BorderRadius.circular(28), // 🌸 bo tròn góc
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF6366F1), width: 1.5),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 2.0), // Đậm hơn khi focus
                      borderRadius: BorderRadius.circular(28),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Text(
                'Your Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                child: TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(color: Colors.black26),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF6366F1)),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF6366F1), width: 1.5),
                      borderRadius: BorderRadius.circular(28), // 🌸 bo tròn góc
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF6366F1), width: 1.5),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xFF4F46E5),
                          width: 2.0), // Đậm hơn khi focus
                      borderRadius: BorderRadius.circular(28),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF6366F1),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child:
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: const Text(
                    //     'Forgot Password?',
                    //     style: TextStyle(
                    //       // color: Color(0xFF6366F1),
                    //       color: Colors.black,
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: 13,
                    //     ),
                    //   ),
                    // ),
                    Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(Soon)',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // onPressed: () {},
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text;

                    if (email.isEmpty || password.isEmpty) {
                      Utils.showSnackBar(
                          context, "Please enter email and password");
                      return;
                    }

                    // Gọi service login
                    final loginResult = await AuthService.signInUser(
                      context: context,
                      email: email,
                      password: password,
                    );

                    if (loginResult != null && loginResult.user != null) {
                      // ✅ Cập nhật user provider
                      final userProvider =
                          Provider.of<UserProvider>(context, listen: false);
                      userProvider.setUserFromLoginModel(loginResult);

                      // Utils.showSnackBar(context, "Login successful!");

                      // ✅ Điều hướng về màn hình chính
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BottomNavBarScreen(
                            key: AppNavigation.bottomNavKey,
                          ),
                        ),
                      );
                    } else {
                      Utils.showSnackBar(
                          context, "Username or Password incorrect!");
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                color: Colors.grey, // Màu đường
                thickness: 0.5, // Độ dày
                indent: 0, // Khoảng cách từ trái
                endIndent: 0, // Khoảng cách từ phải
              ),
              const SizedBox(height: 20),

              // Container(
              //   width: double.infinity,
              //   height: 56,
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.black26),
              //     borderRadius: BorderRadius.circular(28),
              //   ),
              // child: TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(28),
              //     ),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: const [
              //       Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
              //       SizedBox(width: 8),
              //       Text(
              //         'Continue with Google',
              //         style: TextStyle(
              //           color: Colors.black87,
              //           fontSize: 16,
              //           fontWeight: FontWeight.w500,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // ),
              AuthButton(
                // context,
                iconWidget: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                  color: Colors.red,
                ),
                isFuture: true,
                text: 'Continue with Google',
                onPressed: () {},
              ),

              const SizedBox(height: 42),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
