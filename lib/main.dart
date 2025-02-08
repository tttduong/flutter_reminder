import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/home_page.dart';
import 'package:flutter_to_do_app/ui/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Reminder App',
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeMode.light,
        home: HomePage());
  }
}
