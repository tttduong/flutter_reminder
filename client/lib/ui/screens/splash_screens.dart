import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/data/models/login_model.dart';
import 'package:flutter_to_do_app/providers/user_provider.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:flutter_to_do_app/ui/screens/welcome_page.dart';
import 'package:provider/provider.dart';
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
    // navigateToHomePage();
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 1));

    print("🔍 ===== SPLASH SCREEN DEBUG =====");

    bool hasSession = await ApiService.hasValidSession();
    print("🔐 Has valid session: $hasSession");

    if (hasSession && mounted) {
      print("📞 Attempting to load user...");

      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // ✅ Check user trước khi load
      print("👤 User BEFORE load: ${userProvider.user?.username ?? 'NULL'}");

      bool userLoaded = await userProvider.loadCurrentUser();
      print("📥 User loaded from API: $userLoaded");

      // ✅ Check user sau khi load
      print("👤 User AFTER load: ${userProvider.user?.username ?? 'NULL'}");

      if (!userLoaded) {
        print("⚠️ API load failed, trying local storage...");
        await userProvider.loadUserFromLocal();
        print(
            "👤 User after local load: ${userProvider.user?.username ?? 'NULL'}");
      }
    }

    print("🔍 ===== END SPLASH DEBUG =====\n");

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
              hasSession ? BottomNavBarScreen() : const WelcomePage(),
        ),
        (route) => false,
      );
    }
  }

// ✅ Method mới: Load user info
  Future<void> _loadUserInfo() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Gọi API để lấy user info
      final response =
          await ApiService.dio.get('/api/v1/me/'); // Thay endpoint phù hợp

      if (response.statusCode == 200) {
        final userData = response.data;

        // ✅ Update UserProvider
        userProvider.setUserFromModel(User(
          id: userData['id'], // ✅ Từ API
          username: userData['username'], // ✅ Từ API
          email: userData['email'], // ✅ Từ API
        ));

        print("✅ User info loaded: ${userData['username']}");
      }
    } catch (e) {
      print("❌ Failed to load user info: $e");
      // Nếu fail → clear session và về login
      await ApiService.clearCookies();
    }
  }
  // Future<void> _checkAuthAndNavigate() async {
  //   // ✅ Đợi 1-2 giây cho splash screen hiển thị
  //   await Future.delayed(const Duration(seconds: 1));

  //   // ✅ Check xem có session hợp lệ không
  //   bool hasSession = await ApiService.hasValidSession();

  //   print("🔐 Has valid session: $hasSession");

  //   if (mounted) {
  //     Navigator.pushAndRemoveUntil(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => hasSession
  //             ? BottomNavBarScreen() // ✅ Có session → vào app
  //             : const WelcomePage(), // ✅ Không có session → về welcome
  //       ),
  //       (route) => false,
  //     );
  //   }
  // }

  Future<void> navigateToHomePage() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) =>
              // BottomNavBarScreen(key: AppNavigation.bottomNavKey)),
              WelcomePage()),
      (route) => false,
    );
  }

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
