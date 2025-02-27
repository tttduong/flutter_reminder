import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/model/test.dart';
import 'package:flutter_to_do_app/service/api_service.dart';
import 'package:flutter_to_do_app/service/theme_services.dart';
import 'package:flutter_to_do_app/ui/add_task_bar.dart';
import 'package:flutter_to_do_app/ui/theme.dart';
import 'package:flutter_to_do_app/ui/widgets/button.dart';
import 'package:flutter_to_do_app/ui/widgets/task_tile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Task>> futureTasks;
  late Future<Test> futureTest;
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());

  @override
  void initState() {
    super.initState();
    futureTasks = ApiService().fetchTasks();
    futureTest = ApiService().fetch();
  }

  @override
  Widget build(BuildContext context) {
    // _taskController.getTasks(); // Gọi hàm để lấy danh sách task

    return Scaffold(
      // backgroundColor: Colors.green,
      appBar: _appBar(),
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          // _showTasks(),
          FutureBuilder<List<Task>>(
            // FutureBuilder<Test>(
            future: futureTasks,
            // future: futureTest,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        "ko co Tasks: ${!snapshot.hasData || snapshot.data!.isEmpty} Lỗi: ${snapshot.error}\n ${snapshot.hasData}\n ${snapshot.hasError}"));
              } else {
                List<Task> tasks = snapshot.data!;
                // Test test = snapshot.data!;
                return Column(
                  children: [
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          return TaskTile(
                              task: tasks[index], onTap: () => null);
                        },
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          // FutureBuilder<Test>(
          //   future: futureTest,
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return Center(child: CircularProgressIndicator());
          //     } else if (snapshot.hasError) {
          //       return Center(child: Text("Lỗi: ${snapshot.error}"));
          //     } else if (!snapshot.hasData || snapshot.data!.title == null) {
          //       return Center(child: Text("Không có dữ liệu"));
          //     } else {
          //       return Center(
          //         child: Text(
          //           "Test Title: ${snapshot.data!.title}",
          //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //         ),
          //       );
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  // _showTasks() {
  //   List<Task> fakeTasks = [
  //     Task(
  //       title: "Meeting with team",
  //       note: "Discuss project progress",
  //       date: "2025-02-17",
  //       startTime: "10:00 AM",
  //       endTime: "11:00 AM",
  //       remind: 10,
  //       repeat: "None",
  //       color: 1,
  //       isCompleted: 0,
  //     ),
  //     Task(
  //       title: "Doctor Appointment",
  //       note: "Routine check-up",
  //       date: "2025-02-18",
  //       startTime: "03:00 PM",
  //       endTime: "04:00 PM",
  //       remind: 30,
  //       repeat: "None",
  //       color: 2,
  //       isCompleted: 0,
  //     ),
  //     Task(
  //       title: "Gym Session",
  //       note: "Leg day workout",
  //       date: "2025-02-19",
  //       startTime: "07:00 AM",
  //       endTime: "08:00 AM",
  //       remind: 15,
  //       repeat: "Daily",
  //       color: 3,
  //       isCompleted: 1,
  //     ),
  //   ];

  //   return Row(
  //     children: [
  //       Expanded(
  //         child: ListView.builder(
  //           shrinkWrap: true, // ✅ Giúp ListView có kích thước vừa đủ
  //           physics: NeverScrollableScrollPhysics(), // ✅ Ngăn ListView tự cuộn
  //           itemCount: fakeTasks.length,
  //           itemBuilder: (context, index) {
  //             Task task = fakeTasks[index]; // Lấy task từ danh sách giả lập
  //             return Card(
  //               margin: EdgeInsets.all(8.0),
  //               child: TaskTile(
  //                 task: task,
  //                 onTap: () => {},
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  _addDateBar() {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 20),
      child: DatePicker(DateTime.now(),
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
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey), onDateChange: (date) {
        setState(() {
          _selectedDate = date;
        });
        // _taskController
        //     .getTasks(); // Lấy lại danh sách task sau khi chọn ngày mới
      }),
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
          MyButton(
              label: "+ Add Task",
              onTap: () async {
                await Get.to(() => AddTaskPage());
                // _taskController.getTasks();
              })
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
