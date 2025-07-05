import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import '../../data/models/auth_utility.dart';
import '../widgets/screen_background.dart';
import 'bottom_navbar_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // navigateToLogin();
    navigateToHomePage();
    super.initState();
  }

  Future<void> navigateToHomePage() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavBarScreen()),
      (route) => false,
    );
    // another way to impliment splash screen;
    // Future.delayed(const Duration(seconds: 3)).then((_) async {
    //   final bool loggedIn = await AuthUtility.isUserLoggedIn();
    //   if (mounted) {
    //     Navigator.pushAndRemoveUntil(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) =>
    //               loggedIn ? const BottomNavBarScreen() : const SignInPage()),
    //       (route) => false,
    //     );
    //   }
    // });
  }

  // void navigateToLogin() {
  //   //another way to impliment splash screen;
  //   // await Future.delayed(Duration(seconds: 4));
  //   // Navigator.pushAndRemoveUntil(
  //   //   context,
  //   //   MaterialPageRoute(builder: (context) => const LoginScreen()),
  //   //       (route) => false,
  //   // );
  //   Future.delayed(const Duration(seconds: 3)).then((_) async {
  //     final bool loggedIn = await AuthUtility.isUserLoggedIn();
  //     if (mounted) {
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) =>
  //                 loggedIn ? const BottomNavBarScreen() : const SignInPage()),
  //         (route) => false,
  //       );
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: Center(
            child:
                // SvgPicture.asset(
                //   AssetsUtils.logoSVG,
                //   width: 90,
                //   fit: BoxFit.scaleDown,
                // ),
                Text("Hello")),
      ),
    );
  }
}
