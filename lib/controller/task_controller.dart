import 'package:flutter_to_do_app/db/db_helper.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }
}
