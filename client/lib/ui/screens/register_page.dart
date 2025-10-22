import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/data/services/auth_services.dart';
import 'package:flutter_to_do_app/ui/screens/login_page.dart';
import 'package:flutter_to_do_app/ui/screens/verification_page.dart';
import 'package:flutter_to_do_app/ui/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';

// Register Page
class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // final _usernameController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _passwordController = TextEditingController();
  // final _confirmPasswordController = TextEditingController();
  // bool _isPasswordVisible = false;
  // bool _isConfirmPasswordVisible = false;

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  void _register() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // ✅ Kiểm tra đầu vào
    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      Utils.showSnackBar(context, "Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      Utils.showSnackBar(context, "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    // ✅ Gọi API đăng ký
    final user = await AuthService.signUpUser(
      context: context,
      email: email,
      username: username,
      password: password,
      confirm_password: confirmPassword,
    );

    setState(() => _isLoading = false);

    if (user != null) {
      Utils.showSnackBar(context, "Register successfully!");

      // Chuyển sang trang tiếp theo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const VerificationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                  children: [
                    TextSpan(
                        text:
                            'Create an account to access all the features of ',
                        style: TextStyle(fontSize: 16)),
                    TextSpan(
                      text: 'Lumiere',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextSpan(text: '!'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                label: 'Your Username',
                controller: _usernameController,
                hintText: 'Ex: Saul Ramirez',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Email',
                controller: _emailController,
                hintText: 'Ex: abc@example.com',
                prefixIcon: Icons.alternate_email,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Your Password',
                controller: _passwordController,
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                hintText: '••••••••',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                isPasswordVisible: _isConfirmPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
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

  // Widget _buildTextField({
  //   required String label,
  //   required TextEditingController controller,
  //   required String hintText,
  //   required IconData prefixIcon,
  //   bool isPassword = false,
  //   bool isPasswordVisible = false,
  //   VoidCallback? onTogglePassword,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: const TextStyle(
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //           color: Colors.black87,
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Container(
  //         child: TextField(
  //           controller: controller,
  //           obscureText: isPassword && !isPasswordVisible,
  //           decoration: InputDecoration(
  //             hintText: hintText,
  //             hintStyle: const TextStyle(color: Colors.black26),
  //             prefixIcon: Icon(prefixIcon, color: Color(0xFF6366F1)),
  //             border: OutlineInputBorder(
  //               borderSide:
  //                   const BorderSide(color: Color(0xFF6366F1), width: 1.5),
  //               borderRadius: BorderRadius.circular(28), // 🌸 bo tròn góc
  //             ),
  //             enabledBorder: OutlineInputBorder(
  //               borderSide:
  //                   const BorderSide(color: Color(0xFF6366F1), width: 1.5),
  //               borderRadius: BorderRadius.circular(28),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               borderSide: const BorderSide(
  //                   color: Color(0xFF4F46E5), width: 2.0), // Đậm hơn khi focus
  //               borderRadius: BorderRadius.circular(28),
  //             ),
  //             suffixIcon: isPassword
  //                 ? IconButton(
  //                     icon: Icon(
  //                       isPasswordVisible
  //                           ? Icons.visibility_outlined
  //                           : Icons.visibility_off_outlined,
  //                       color: Color(0xFF6366F1),
  //                     ),
  //                     onPressed: onTogglePassword,
  //                   )
  //                 : null,
  //             contentPadding:
  //                 const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black26),
              prefixIcon: Icon(prefixIcon, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                borderRadius: BorderRadius.circular(28), // 🌸 bo tròn góc
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                borderRadius: BorderRadius.circular(28),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: Color(0xFF4F46E5), width: 2.0), // Đậm hơn khi focus
                borderRadius: BorderRadius.circular(28),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: onTogglePassword,
                    )
                  : null,
            )),
      ],
    );
  }
}
