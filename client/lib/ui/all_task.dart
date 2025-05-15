import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/model/category.dart';
import 'package:flutter_to_do_app/model/task.dart';
import 'package:flutter_to_do_app/service/category_service.dart';
import 'package:flutter_to_do_app/service/task_service.dart';
import 'package:flutter_to_do_app/ui/add_task.dart';
import 'package:flutter_to_do_app/ui/widgets/category_card.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/consts.dart';

class AllTasksPage extends StatefulWidget {
  const AllTasksPage({Key? key}) : super(key: key);

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  // Các danh mục công việc
  // final List<Category> categories = [
  //   // Category(
  //   //   title: 'Personal Project',
  //   //   color: Colors.pink,
  //   //   icon: Icons.person,
  //   //   tasks: [
  //   //     Task(title: 'build UI home', isCompleted: false),
  //   //     Task(title: 'build UI today', isCompleted: false),
  //   //     Task(title: 'build UI', isCompleted: false),
  //   //   ],
  //   // ),
  //   Category(
  //     id: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //     title: 'Healing',
  //     color: Colors.orange,
  //     icon: Icons.favorite,
  //     tasks: [
  //       Task(
  //           categoryId: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //           title: 'sleep',
  //           isCompleted: false),
  //       Task(
  //           categoryId: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //           title: 'spicy noodles',
  //           isCompleted: false),
  //       Task(
  //           categoryId: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //           title: 'lunch',
  //           isCompleted: false),
  //     ],
  //   ),
  // ];

  // // Công việc đã hoàn thành
  // final List<Task> completedTasks = [
  //   Task(
  //       categoryId: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //       title: 'sleep 1',
  //       isCompleted: true),
  //   Task(
  //       categoryId: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //       title: 'sleep 2',
  //       isCompleted: true),
  //   Task(
  //       categoryId: "fa217769-d424-451f-bf8c-abe72d9c5655",
  //       title: 'sleep 3',
  //       isCompleted: true),
  // ];

  bool showCompletedTasks = false;

  late Future<List<Task>> _futureTasks;
  late Future<List<Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = CategoryService.fetchCategories();
    _futureTasks = TaskService.getTasksByCategoryId(
        "45eb360a-3802-4a64-9008-824e46a88214");
  }

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
              child: FutureBuilder<List<Category>>(
                future: _futureCategories,
                builder: (context, categorySnapshot) {
                  if (categorySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (categorySnapshot.hasError) {
                    return Center(
                        child: Text('Lỗi: ${categorySnapshot.error}'));
                  } else if (!categorySnapshot.hasData ||
                      categorySnapshot.data!.isEmpty) {
                    return const Center(child: Text('Không có danh mục nào'));
                  }

                  final categories = categorySnapshot.data!;

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // if (category.taskCount != null)
                          ListCard(
                            title: category.title,
                            color: category.color,
                            icon: category.icon,
                          ),
                          FutureBuilder<List<Task>>(
                            future:
                                TaskService.getTasksByCategoryId(category.id),
                            builder: (context, taskSnapshot) {
                              if (taskSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (taskSnapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Text(
                                      "Lỗi khi tải task: ${taskSnapshot.error}"),
                                );
                              } else if (!taskSnapshot.hasData ||
                                  taskSnapshot.data!.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Text("Không có task nào"),
                                );
                              }

                              final tasks = taskSnapshot.data!;
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tasks.length,
                                itemBuilder: (context, taskIndex) {
                                  final task = tasks[taskIndex];
                                  return ListTile(
                                    title: Text(task.title),
                                    subtitle: Text(task.description ?? ""),
                                    leading: Icon(
                                      task.isCompleted
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: task.isCompleted
                                          ? Colors.green
                                          : null,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
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
