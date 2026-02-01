// import 'package:flutter/material.dart';

// import 'package:flutter_to_do_app/model/models.dart';
// import 'package:flutter_to_do_app/screens/screens.dart';
// import 'package:flutter_to_do_app/providers/providers.dart';
// // import 'package:client_app/models/models.dart';
// import 'package:flutter_to_do_app/service/services.dart';
// import 'package:provider/provider.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => UserProvider(),
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   /// In the widget Initialising process, if [token] is found in-divice
//   /// get User data from backend, then notify UserProvider
//   void _getUserData() async {
//     String? existedToken = await LocalStoreServices.getFromLocal(context);
//     if (existedToken != null) {
//       User? user =
//           await AuthService.getUser(context: context, token: existedToken);
//       if (user != null) {
//         if (!mounted) return null;
//         Provider.of<UserProvider>(context, listen: false)
//             .setUserFromModel(user);
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _getUserData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Basic AUTH with Flutter + FastAPI',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Consumer<UserProvider>(
//         builder: (context, userProvider, child) {
//           if (userProvider.user != null) {
//             return const HomePage();
//           }

//           return const SignUpPage();
//         },
//       ),
//     );
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/app.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/controller/user_controller.dart';
import 'package:flutter_to_do_app/data/services/permission_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'data/services/auth_services.dart';
import 'data/services/local_store_services.dart';
import 'providers/user_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// import 'data/services/notification_service.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// intergrate notification
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ✅ Sử dụng ApiService.dio thay vì tạo Dio mới
Future<void> registerFCMToken(String token) async {
  print('🚀 Attempting to register FCM token...');
  try {
    print('📡 Sending to: ${ApiService.baseUrl}/api/v1/register-fcm-token');

    // ✅ Dùng ApiService.dio (đã có cookie support)
    final response = await ApiService.dio.post(
      '/api/v1/register-fcm-token', // ← Path tương đối
      data: {"fcm_token": token},
    );

    print('✅ Response: ${response.statusCode} - ${response.data}');
  } catch (e) {
    print('❌ Error registering FCM token: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Init ApiService TRƯỚC (để setup cookie jar)`
  await ApiService.init();
  print('✅ ApiService initialized with cookie support');

  // Init Firebase
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ✅ Request notification permission
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted notification permission');

    // ✅ Lấy FCM token và đăng ký lên server
    String? token = await messaging.getToken();
    if (token != null) {
      print("📱 FCM Token: ${token.substring(0, 20)}...");

      // ✅ Check xem đã login chưa
      bool hasSession = await ApiService.hasValidSession();
      print('🔐 Has valid session: $hasSession');

      if (hasSession) {
        // Đã login → đăng ký token ngay
        await registerFCMToken(token);
      } else {
        // Chưa login → lưu token để đăng ký sau
        print('⏳ Saving token for later registration after login');
        // TODO: Lưu vào SharedPreferences hoặc để user login trước
      }
    }

    // ✅ Lắng nghe khi token refresh
    messaging.onTokenRefresh.listen((newToken) async {
      print('🔄 FCM Token refreshed');
      bool hasSession = await ApiService.hasValidSession();
      if (hasSession) {
        await registerFCMToken(newToken);
      }
    });
  } else {
    print('⚠️ User declined notification permission');
  }

  // Xử lý notification khi app đang foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📬 Received message: ${message.notification?.title}');
    print('📝 Body: ${message.notification?.body}');

    // TODO: Show local notification nếu cần
  });

  // Xử lý khi user click vào notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📱 User opened app from notification');
    print('📝 Data: ${message.data}');

    // TODO: Navigate đến màn hình cụ thể
  });

  // Init timezone
  tz.initializeTimeZones();

  Get.put(TaskController(), permanent: true);
  Get.put(CategoryController(), permanent: true);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const TaskManagerApp(),
    ),
  );
}
// // ✅ THÊM: Helper function để đăng ký FCM token
// Future<void> registerFCMToken(String token) async {
//   print('🚀 Attempting to register FCM token...');
//   try {
//     final dio = Dio();
//     const String baseUrl = "${Constants.URI}/api/v1";

//     print('📡 Sending to: $baseUrl/register-fcm-token');

//     final response = await dio.post(
//       '$baseUrl/register-fcm-token',
//       data: {"fcm_token": token},
//       options: Options(
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       ),
//     );

//     print('✅ Response: ${response.statusCode} - ${response.data}');
//   } catch (e) {
//     print('❌ Error registering FCM token: $e');
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Init Firebase
//   await Firebase.initializeApp();
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // ✅ Request notification permission
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//     provisional: false,
//   );

//   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//     print('✅ User granted notification permission');

//     // ✅ Lấy FCM token và đăng ký lên server
//     String? token = await messaging.getToken();
//     if (token != null) {
//       print("📱 FCM Token: ${token.substring(0, 20)}...");
//       await registerFCMToken(token); // ← GỬI TOKEN LÊN SERVER
//     }

//     // ✅ Lắng nghe khi token refresh (token cũ expire)
//     messaging.onTokenRefresh.listen((newToken) {
//       print('🔄 FCM Token refreshed');
//       registerFCMToken(newToken); // ← CẬP NHẬT TOKEN MỚI
//     });
//   } else {
//     print('⚠️ User declined notification permission');
//   }

//   // Xử lý notification khi app đang foreground
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('📬 Received message: ${message.notification?.title}');
//     print('📝 Body: ${message.notification?.body}');

//     // TODO: Show local notification nếu cần
//     // Ví dụ: dùng flutter_local_notifications để hiện popup
//   });

//   // Xử lý khi user click vào notification (app background/terminated)
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('📱 User opened app from notification');
//     print('📝 Data: ${message.data}');

//     // TODO: Navigate đến màn hình cụ thể dựa vào message.data
//     // Ví dụ: if (message.data['type'] == 'task') { navigate to task detail }
//   });

//   // Init timezone
//   tz.initializeTimeZones();

//   Get.put(TaskController(), permanent: true);
//   Get.put(CategoryController(), permanent: true);

//   ApiService.init();

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child: const TaskManagerApp(),
//     ),
//   );
// }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // intergrate notification--------------------
//   await Firebase.initializeApp();
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Lấy token gửi về backend
//   String? token = await messaging.getToken();
//   print("FCM Token: $token");

// // Khi app đang foreground:
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     print('Received message: ${message.notification?.title}');
//   });
// // Khi app background hoặc bị kill:
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print('User opened app from notification');
//   });

// // ------------------intergrate notification----------------------

//   // Init timezone
//   tz.initializeTimeZones();

//   Get.put(TaskController(), permanent: true);
//   Get.put(CategoryController(), permanent: true);

//   ApiService.init();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child: const TaskManagerApp(),
//     ),
//   );
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/db/db_helper.dart';
// import 'package:flutter_to_do_app/service/theme_services.dart';
// import 'package:flutter_to_do_app/ui/home.dart';
// import 'package:flutter_to_do_app/ui/schedule.dart';
// import 'package:flutter_to_do_app/ui/theme.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:get_storage/get_storage.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await DBHelper.initDb();
//   await GetStorage.init();
//   runApp(const MainApp());
// }

// class MainApp extends StatelessWidget {
//   const MainApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//         title: 'Flutter Reminder App',
//         debugShowCheckedModeBanner: false,
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//           scaffoldBackgroundColor: const Color(0xFFE0F7FA),
//         ),
//         // theme: Themes.light,
//         // darkTheme: Themes.dark,
//         // themeMode: ThemeService().theme,
//         home: Home());
//   }
// }
