import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/model/category.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/ui/add_task.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/consts.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({Key? key}) : super(key: key);

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  // Các danh mục công việc
  final List<Category> categories = [
    Category(
      title: 'Personal Project',
      color: Colors.pink,
      icon: Icons.person,
      tasks: [
        Task(title: 'build UI home', isCompleted: false),
        Task(title: 'build UI today', isCompleted: false),
        Task(title: 'build UI', isCompleted: false),
      ],
    ),
    Category(
      title: 'Healing',
      color: Colors.orange,
      icon: Icons.favorite,
      tasks: [
        Task(title: 'sleep', isCompleted: false),
        Task(title: 'spicy noodles', isCompleted: false),
        Task(title: 'lunch', isCompleted: false),
      ],
    ),
  ];

  // Công việc đã hoàn thành
  final List<Task> completedTasks = [
    Task(title: 'sleep 1', isCompleted: true),
    Task(title: 'sleep 2', isCompleted: true),
    Task(title: 'sleep 3', isCompleted: true),
  ];

  bool showCompletedTasks = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'All Tasks',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  // Hiển thị danh sách công việc theo danh mục
                  // for (var category in categories) ...[
                  //   _buildCategoryHeader(category),
                  //   ...category.tasks.map((task) => _buildTaskItem(task)),
                  //   const SizedBox(height: 16),
                  // ],

                  // Nút ẩn/hiện công việc đã hoàn thành
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        showCompletedTasks = !showCompletedTasks;
                      });
                    },
                    icon: Icon(
                      showCompletedTasks
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.buttonWhiteText,
                    ),
                    label: Text(
                      'Hide completed tasks',
                      style: TextStyle(
                        color: AppColors.buttonWhiteText,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  // Hiển thị công việc đã hoàn thành
                  if (showCompletedTasks) ...[
                    const SizedBox(height: 16),
                    ...completedTasks
                        .map((task) => _buildCompletedTaskItem(task)),
                  ],

                  const SizedBox(height: 80), // Để tránh FAB che nội dung
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => AddTaskPage());
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  // Widget hiển thị tiêu đề danh mục
  Widget _buildCategoryHeader(Category category) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            category.title,
            style: TextStyle(
              color: category.color,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị công việc chưa hoàn thành
  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị công việc đã hoàn thành
  Widget _buildCompletedTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.delete_outline,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
