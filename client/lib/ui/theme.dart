import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const Color bluishClr = Color(0xFF4e5ae8);
const Color yellowClr = Color(0xFFFFB746);
const Color pinkClr = Color(0xFFff4667);
const Color white = Colors.white;
const primaryClr = bluishClr;
const Color darkGreyClr = Color(0xFF121212);
Color darkHeaderClr = Color(0xFF424242);

class Themes {
  static final light = ThemeData(
    scaffoldBackgroundColor: white,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: bluishClr, // Dùng màu custom
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryClr, // Dùng màu của primarySwatch
      foregroundColor: white, // Màu chữ/icon trên AppBar
    ),
  );

  static final dark = ThemeData(
    scaffoldBackgroundColor: darkGreyClr,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.light(
      primary: darkHeaderClr, // Dùng màu custom
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkHeaderClr, // Dùng màu của primarySwatch
      foregroundColor: white, // Màu chữ/icon trên AppBar
    ),
  );
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Get.isDarkMode ? Colors.white : Colors.black),
  );
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: Get.isDarkMode ? Colors.white : Colors.black),
  );
}

TextStyle get titleStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode ? Colors.white : Colors.black),
  );
}

TextStyle get subTitleStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Get.isDarkMode ? Colors.grey[100] : Colors.grey[400]),
  );
}
