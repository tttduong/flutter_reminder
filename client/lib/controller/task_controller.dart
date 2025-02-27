import 'package:flutter_to_do_app/db/db_helper.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;

  Future<int> addTask({Task? task}) async {
    print("call add task om controller");
    // return await DBHelper.insert(task!);
    return 0;
  }

  //get all the data from table
//   void getTasks() async {
//     List<Map<String, dynamic>> tasks = await DBHelper.query();
//     taskList.assignAll(tasks.map((data) => new Task.fromJson(data)).toList());
//   }
}
