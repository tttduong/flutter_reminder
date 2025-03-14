import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/db/db_helper.dart';
import 'package:flutter_to_do_app/service/theme_services.dart';
import 'package:flutter_to_do_app/ui/home.dart';
import 'package:flutter_to_do_app/ui/home_page.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Reminder App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFE0F7FA),
        ),
        // theme: Themes.light,
        // darkTheme: Themes.dark,
        // themeMode: ThemeService().theme,
        home: Home());
  }
}
