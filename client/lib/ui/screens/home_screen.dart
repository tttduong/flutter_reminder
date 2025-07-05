import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/controller/user_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';
import 'package:flutter_to_do_app/ui/screens/add_list.dart';
import 'package:flutter_to_do_app/ui/screens/signin_screen.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';

import '../../controller/category_controller.dart';
import '../../providers/providers.dart';
import '../widgets/button_add_task.dart';

class HomePage extends StatefulWidget {
  final Category? category;
  const HomePage({super.key, this.category});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TaskController taskController;
  // final Map<String, Future<List<Task>>> _completedTaskFutures = {};
  final _categoryController = Get.put(CategoryController());
  @override
  void initState() {
    super.initState();
    // Khởi tạo controller
    taskController = Get.put(TaskController());
    // Gọi hàm fetch task nếu cần
    taskController.getTasks();
    _categoryController.getCategories();
  }

  void _showNewListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewListBottomSheet(),
    );
  }

  void _logOut() async {
    bool removeSuccess = await LocalStoreServices.removeFromLocal(context);
    if (removeSuccess) {
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUserNull();
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: true).user;

    if (user != null) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 168, 182, 151),

        // 👉 Sidebar ở đây
        drawer: Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 🔒 Nút đăng nhập / tên người dùng
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Obx(() {
                  final userController = Get.find<UserController>();
                  final userName = userController.userName.value;

                  return ElevatedButton.icon(
                    onPressed: () {
                      if (userName == null) {
                        Get.to(() => const SignInPage());
                      } else {
                        // Mở profile hoặc popup đăng xuất nếu muốn
                      }
                    },
                    icon: Icon(userName == null ? Icons.login : Icons.person),
                    label: Text(userName ?? "Log In"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 168, 182, 151),
                      foregroundColor: Colors.white,
                    ),
                  );
                }),
              ),

              // 🔹 Header (tuỳ chọn)
              // DrawerHeader(
              //   decoration: const BoxDecoration(
              //     color: Color.fromARGB(255, 168, 182, 151),
              //   ),
              //   child: Container(
              //     alignment: Alignment.centerLeft,
              //     child: const Text(
              //       'Menu',
              //       style: TextStyle(color: Colors.white, fontSize: 24),
              //     ),
              //   ),
              // ),

              // 🔸 Danh sách category
              Expanded(
                child: Obx(() {
                  if (_categoryController.categoryList.isEmpty) {
                    return const ListTile(
                      title: Text("Không có danh mục nào!"),
                    );
                  }
                  return ListView(
                    children: _categoryController.categoryList.map((category) {
                      return ListTile(
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _categoryController.deleteCategory(category.id);
                          },
                        ),
                        leading: const Icon(Icons.work),
                        title: Text(category.title),
                        onTap: () {
                          Get.to(() => HomePage(category: category),
                              preventDuplicates: false);
                        },
                      );
                    }).toList(),
                  );
                }),
              ),

              // ➕ Nút thêm category ở dưới cùng bên trái
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IconButton(
                    onPressed: _showNewListBottomSheet,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black),
              onPressed: () {
                Scaffold.of(context).openDrawer(); // open sidebar
              },
            ),
          ),
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.category?.title ?? 'Inbox',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // IconButton(
                  //   onPressed:
                  //   _showNewListBottomSheet,
                  //   style: IconButton.styleFrom(
                  //     backgroundColor: AppColors.primary,
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8), // Nút vuông
                  //     ),
                  //   ),
                  //   icon: const Icon(
                  //     Icons.add,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 16),
              // _showCategories()
              Obx(() => _showTasksByCategory())
            ],
          ),
        ),
        floatingActionButton: const ButtonAddTask(),
      );

      // return const Center(child: CircularProgressIndicator());
      // return Scaffold(
      //   body: Center(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         const Text("Home Page",
      //             style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      //         const SizedBox(height: 35),
      //         Text("Username : ${user.username}",
      //             style: const TextStyle(fontSize: 18)),
      //         const SizedBox(height: 15),
      //         Text("Email : ${user.email}",
      //             style: const TextStyle(fontSize: 18)),
      //         const SizedBox(height: 15),
      //         Text("JWT token : ${user.token}",
      //             style: const TextStyle(fontSize: 18)),
      //         const SizedBox(height: 30),
      //         CustomElevatedButton(
      //           onPressfunc: _logOut,
      //           buttonText: "Log out",
      //         ),
      //       ],
      //     ),
      //   ),
      // );
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Home Page",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 35),
              Text(
                  "Please log in or sign up to sync data across multiple devices",
                  style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }
  }

  _showTasksByCategory() {
    final allTasks = taskController.getTasksByCategory(widget.category?.id);
    final incompleteTasks =
        allTasks.where((t) => t.isCompleted != true).toList();
    final completedTasks =
        allTasks.where((t) => t.isCompleted == true).toList();

    if (allTasks.isEmpty) {
      return const Text("No tasks");
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: incompleteTasks.length,
            itemBuilder: (context, index) {
              final task = incompleteTasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.isCompleted == true,
                  onChanged: (bool? newValue) {
                    final newStatus = newValue ?? false;
                    taskController.updateTaskStatus(task, newStatus);
                    setState(() {});
                  },
                ),
                title: Text(task.title),
                subtitle: Text(task.description ?? ''),
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            "Completed Tasks",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedTasks.length,
            itemBuilder: (context, index) {
              final task = completedTasks[index];
              return ListTile(
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    taskController.deleteTask(task);
                    setState(() {});
                  },
                ),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? newValue) {
                    final newStatus = newValue ?? false;
                    taskController.updateTaskStatus(task, newStatus);
                    setState(() {});
                  },
                ),
                title: Text(
                  task.title,
                  style:
                      const TextStyle(decoration: TextDecoration.lineThrough),
                ),
                subtitle: Text(task.description ?? ''),
              );
            },
          ),
        ],
      ),
    );
  }

  // final _categoryController = Get.put(CategoryController());

  // void _showNewListBottomSheet() {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => const NewListBottomSheet(),
  //   );
  // }
}
