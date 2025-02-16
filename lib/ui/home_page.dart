import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/service/theme_services.dart';
import 'package:flutter_to_do_app/ui/add_task_bar.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.green,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
        ],
      ),
    );
  }

  _addDateBar() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
            fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        dayTextStyle: GoogleFonts.lato(
            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        monthTextStyle: GoogleFonts.lato(
            fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        onDateChange: (date) {
          _selectedDate = date;
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMMd().format(DateTime.now()),
                    style: subHeadingStyle),
                Text(
                  "Today",
                  style: headingStyle,
                )
              ],
            ),
          ),
          MyButton(label: "+ Add Task", onTap: () => Get.to(AddTaskPage()))
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage("images/profile.jpg"),
        ),
        SizedBox(
          width: 20,
        )
      ],
    );
  }
}
