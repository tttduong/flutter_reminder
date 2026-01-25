import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/screens/login_page.dart';
import 'package:flutter_to_do_app/ui/screens/register_page.dart';
import 'package:flutter_to_do_app/ui/widgets/auth_button.dart';
import 'package:google_fonts/google_fonts.dart';

// Welcome Page
class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              const Text(
                'Lumiere',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
              // const SizedBox(height: 4),
              const Text(
                'Not just a task app. A friend that keeps\nyou going.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 100),
              const Text(
                "Let's Get Started...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              AuthButton(
                // context,
                // icon: 'assets/google_icon.png',
                iconWidget: const Icon(
                  Icons.g_mobiledata,
                  size: 30,
                  color: Colors.red,
                ),
                isFuture: true,
                text: 'Continue with Google',
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              AuthButton(
                // context,
                icon: null,
                text: 'Continue with Email',
                iconWidget: const Icon(Icons.email_outlined, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
              ),
              const Spacer(),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildButton(BuildContext context,
  //     {String? icon,
  //     required String text,
  //     Widget? iconWidget,
  //     required VoidCallback onPressed}) {
  //   return Container(
  //     width: double.infinity,
  //     height: 56,
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.black26),
  //       borderRadius: BorderRadius.circular(28),
  //     ),
  //     child: TextButton(
  //       onPressed: onPressed,
  //       style: TextButton.styleFrom(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(28),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           if (icon != null)
  //             Image.asset(icon, height: 20, width: 20)
  //           else if (iconWidget != null)
  //             iconWidget,
  //           const SizedBox(width: 12),
  //           Text(
  //             text,
  //             style: const TextStyle(
  //               color: Colors.black87,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget buildButton(
    BuildContext context, {
    String? icon,
    required String text,
    Widget? iconWidget,
    required VoidCallback? onPressed,
    bool isFuture = false,
  }) {
    Widget button = Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(28),
      ),
      child: TextButton(
        onPressed: isFuture ? null : onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Image.asset(icon, height: 20, width: 20)
            else if (iconWidget != null)
              iconWidget,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    if (!isFuture) return button;

    return Banner(
      message: 'SOON',
      location: BannerLocation.topEnd,
      color: Colors.orange,
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      child: button,
    );
  }
}
