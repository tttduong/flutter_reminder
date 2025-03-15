import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/service/theme_services.dart';
import 'package:flutter_to_do_app/ui/add_task.dart';
import 'package:flutter_to_do_app/ui/button_add_task.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Scheme extends StatefulWidget {
  const Scheme({Key? key}) : super(key: key);

  @override
  State<Scheme> createState() => _SchemeState();
}

class _SchemeState extends State<Scheme> {
  late Future<List<Task>> futureTasks;
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.green,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          _showTasks(),
        ],
      ),
      floatingActionButton: const ButtonAddTask(),
    );
  }

  _showTasks() {
    return Obx(() {
      if (_taskController.taskList.isEmpty) {
        return Center(child: Text("Không có task nào!"));
      }
      return Column(
        children: [
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _taskController.taskList.length,
              itemBuilder: (context, index) {
                return TaskTile(
                  task: _taskController.taskList[index],
                  onTap: () => null,
                );
              },
            ),
          ),
        ],
      );
    });
  }

  _addDateBar() {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 20),
      child: DatePicker(DateTime.now(),
          height: 100,
          width: 60,
          initialSelectedDate: DateTime.now(),
          selectionColor: AppColors.primary,
          selectedTextColor: Colors.white,
          dateTextStyle: GoogleFonts.lato(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
          dayTextStyle: GoogleFonts.lato(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
          monthTextStyle: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey), onDateChange: (date) {
        setState(() {
          _selectedDate = date;
        });
      }),
    );
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 0, right: 0, top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today",
                  style: headingStyle,
                ),
                Text(DateFormat.yMMMMd().format(DateTime.now()),
                    style: subHeadingStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
        onPressed: () {
          Get.back();
        },
      ),
      // leading: GestureDetector(
      //   onTap: () {
      //     ThemeService().switchTheme();
      //   },
      //   child: Icon(
      //     Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
      //     size: 20,
      //     color: Get.isDarkMode ? Colors.white : Colors.black,
      //   ),
      // ),
      // actions: [
      //   CircleAvatar(
      //     backgroundImage: AssetImage("images/profile.jpg"),
      //   ),
      //   SizedBox(
      //     width: 20,
      //   )
      // ],
    );
  }
}
