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

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/app.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/controller/user_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'data/services/auth_services.dart';
import 'data/services/local_store_services.dart';
import 'providers/user_provider.dart';

// void main() {
//   runApp(const TaskManagerApp());
// }
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await LocalStoreServices.init(); // đảm bảo SharedPreferences sẵn sàng
//   Get.put(UserController());

//   // final userProvider = UserProvider();

//   // Gọi load user từ token
//   // final token = await LocalStoreServices.getToken();
//   // if (token != null) {
//   //   final user = await AuthService.getUser(token: token);
//   //   if (user != null) {
//   //     userProvider.setUserFromModel(user);
//   //     print("✅ User loaded from token: ${user.toJson()}");
//   //   } else {
//   //     print("⚠️ Token exists but failed to get user info");
//   //   }
//   // } else {
//   //   print("ℹ️ No token found");
//   // }

//   ApiService.init();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         // Các Provider khác nếu cần
//       ],
//       child: const TaskManagerApp(),
//     ),
//   );
// }
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ApiService.init("http://10.106.193.30:8000/api/v1");

  await ApiService.init();
  // Get.put(TaskController());
  // Get.put(CategoryController());
  final taskController = Get.put(TaskController());
  await taskController.getTasks(); // load task trước

  final categoryController = Get.put(CategoryController());
  await categoryController.getCategories(); // sau đó mới load category

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Các Provider khác nếu cần
      ],
      child: const TaskManagerApp(),
    ),
  );
}

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
