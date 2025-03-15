import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/ui/add_task.dart';
import 'package:get/get.dart';

class ButtonAddTask extends StatelessWidget {
  const ButtonAddTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        await Get.to(() => AddTaskPage());
      },
      shape: const CircleBorder(),
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.add,
        color: AppColors.buttonWhiteText,
      ),
    );
  }
}
