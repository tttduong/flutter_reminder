// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import 'package:flutter_to_do_app/controller/category_controller.dart';
// import 'package:flutter_to_do_app/data/models/category.dart';
// import 'package:flutter_to_do_app/ui/screens/add_list.dart';
// import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
// import 'package:flutter_to_do_app/ui/screens/chat.dart';
// import 'package:flutter_to_do_app/ui/screens/report_screen.dart';
// import 'package:flutter_to_do_app/ui/widgets/appbar.dart';
// import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';

// class HomePage extends StatelessWidget {
//   final Category? initialCategory;
//   // final CategoryController _categoryController = Get.put(CategoryController());
//   final CategoryController categoryController = Get.find();

//   HomePage({super.key, this.initialCategory});

//   // 📂 Category handlers
//   void _handleCategoryTap(BuildContext context, Category category) {
//     // Gọi thẳng xuống BottomNavBarScreen
//     BottomNavBarScreenState.navigateToCategoryFromAnywhere(category);
//     Navigator.of(context).pop(); // đóng drawer
//   }

//   void _handleAddCategoryTap(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const NewListBottomSheet(),
//     );
//   }

//   // 🔍 Search handler
//   void _handleSearchChanged(String query) {
//     print("Search query: $query");
//   }

//   void _handleNotificationTap() {
//     print("Notification tapped");
//   }

//   void _handleMoreTap() {
//     print("More tapped");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       // appBar: CustomAppBar(
//       //   showSearchBar: false,
//       //   searchHint: 'Search tasks...',
//       //   onSearchChanged: _handleSearchChanged,
//       //   onNotificationTap: _handleNotificationTap,
//       //   onMoreTap: _handleMoreTap,
//       // ),
//       // drawer: CustomSidebar(
//       //   categoryController: _categoryController,
//       //   onCategoryTap: (cat) => _handleCategoryTap(context, cat),
//       //   onAddCategoryTap: () => _handleAddCategoryTap(context),
//       // ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Greeting
//               Text(
//                 "Good morning!",
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               const Text(
//                 "Believe in yourself; today is yours to conquer!",
//                 style: TextStyle(fontSize: 14, color: Colors.black87),
//               ),

//               const SizedBox(height: 24),

//               // Horizontal menu
//               SizedBox(
//                 height: 100,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _buildCard("Chatbot", Icons.chat_bubble, onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const ChatPage()),
//                       );
//                     }),
//                     _buildCard("Report", Icons.bar_chart_outlined, onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const ReportScreen()),
//                       );
//                     }),
//                     _buildCard("Habit", Icons.track_changes),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Today progress
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Today",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                   const Text(
//                     "4/8",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.secondary,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               LinearProgressIndicator(
//                 value: 4 / 8,
//                 minHeight: 6,
//                 borderRadius: BorderRadius.circular(10),
//                 color: AppColors.primary,
//                 backgroundColor: AppColors.secondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCard(String title, IconData icon, {VoidCallback? onTap}) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         width: 100,
//         margin: const EdgeInsets.only(right: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 36, color: Colors.cyan),
//             const SizedBox(height: 8),
//             Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/add_list.dart';
import 'package:flutter_to_do_app/ui/screens/add_task.dart';
import 'package:flutter_to_do_app/ui/screens/base_app.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
import 'package:flutter_to_do_app/ui/screens/chat.dart';
import 'package:flutter_to_do_app/ui/screens/report_screen.dart';
import 'package:flutter_to_do_app/ui/widgets/add_list_button.dart';
import 'package:flutter_to_do_app/ui/widgets/appbar.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_floating_button.dart';
import 'package:flutter_to_do_app/ui/widgets/gradient_bg.dart';
import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final Category? initialCategory;
  final bool showDrawer;

  const HomePage(
      {super.key,
      this.initialCategory,
      this.showDrawer = true,
      this.onMenuTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CategoryController _categoryController = Get.find();
  final TaskController _taskController = Get.find();
  @override
  void initState() {
    super.initState();
    // ✅ Force load tasks khi vào HomePage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taskController.getTasks();
      _categoryController.getCategories(); // nếu cần
    });
  }

  void openCategory(Category category) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CategoryTasksPage(category: category),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        opaque: true,
      ),
    );
    print("✅ openCategory navigated to CategoryTasksPage (${category.title})");
  }

  void _showNewListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewListBottomSheet(),
    );
  }

  void _handleCategoryTap(Category category) {
    openCategory(category);
  }

  void _handleAddCategoryTap() {
    _showNewListBottomSheet();
  }

  void _handleSearchChanged(String query) {
    print("Search query: $query");
  }

  void _handleNotificationTap() {
    print("Notification tapped");
  }

  void _handleMoreTap() {
    print("More tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        onSearchChanged: _handleSearchChanged,
        onNotificationTap: _handleNotificationTap,
        onMoreTap: _handleMoreTap,
        onMenuTap: widget.onMenuTap,
      ),
      drawer: widget.showDrawer
          ? CustomSidebar(
              categoryController: _categoryController,
              onCategoryTap: _handleCategoryTap,
              onAddCategoryTap: _handleAddCategoryTap,
            )
          : null,
      // floatingActionButton: _buildFloatingAddButton(),
      body: Column(
        children: [
          const GradientBackground(),
          Expanded(
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting Section
                      const SizedBox(height: 10),
                      Text(
                        "Good morning!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        "Believe in yourself; today is yours to conquer!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Feature Cards
                      // SizedBox(
                      //   height: 90,
                      //   child: ListView(
                      //     scrollDirection: Axis.horizontal,
                      //     children: [
                      //       _buildGradientCard(
                      //           "Chatbot", Icons.chat_bubble_outline,
                      //           onTap: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (_) => const ChatPage(
                      //                     conversationId: null,
                      //                   )),
                      //         );
                      //       }),
                      //       _buildGradientCard(
                      //           "Report", Icons.bar_chart_outlined, onTap: () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (_) => const ReportScreen()),
                      //         );
                      //       }),
                      //       _buildGradientCard(
                      //           "Habit", Icons.check_circle_outline),
                      //     ],
                      //   ),
                      // ),

                      // const SizedBox(height: 20),

                      // Today Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      // const SizedBox(height: 16),

                      // // Task Lists
                      // Task Lists
                      Obx(() {
                        final categories = _categoryController.categoryList;
                        final tasks = _taskController.taskList;
                        final now = DateTime.now();

                        // Lọc categories để hiển thị
                        final categoriesToShow = categories.where((category) {
                          final createdAtLocal = category.createdAt?.toLocal();
                          final createdToday = createdAtLocal != null &&
                              createdAtLocal.year == now.year &&
                              createdAtLocal.month == now.month &&
                              createdAtLocal.day == now.day;

                          // Nếu category được tạo hôm nay, luôn hiển thị
                          if (createdToday) return true;

                          // Nếu không, chỉ hiển thị khi có task chưa hoàn thành hôm nay
                          final hasIncompleteTaskToday = tasks.any((task) =>
                              task.categoryId == category.id &&
                              !task.isCompleted &&
                              task.date != null &&
                              task.date!.year == now.year &&
                              task.date!.month == now.month &&
                              task.date!.day == now.day);

                          return hasIncompleteTaskToday;
                        }).toList();

                        // Lấy tất cả tasks chưa hoàn thành của hôm nay
                        final tasksToday = tasks
                            .where((task) =>
                                !task.isCompleted &&
                                task.date != null &&
                                task.date!.year == now.year &&
                                task.date!.month == now.month &&
                                task.date!.day == now.day)
                            .toList();

                        final hasTaskToday = tasksToday.isNotEmpty;

                        return Column(
                          children: [
                            // Hiển thị tất cả categories
                            for (final category in categoriesToShow)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: _buildTaskSection(
                                  category.title,
                                  category.icon,
                                  category.color,
                                  tasks.where((task) {
                                    final isSameDay = task.date != null &&
                                        task.date!.year == now.year &&
                                        task.date!.month == now.month &&
                                        task.date!.day == now.day;

                                    return task.categoryId == category.id &&
                                        !task.isCompleted &&
                                        isSameDay;
                                  }).toList(),
                                  category,
                                ),
                              ),

                            // Chỉ hiển thị "No tasks for today" khi KHÔNG có task nào
                            if (!hasTaskToday)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        // Icon(
                                        //   Icons.check_circle_outline,
                                        //   size: 64,
                                        //   color: Colors.grey[400],
                                        // ),
                                        Opacity(
                                          opacity: 1,
                                          child: Image.asset(
                                            'images/tasklist.png',
                                            width: 150,
                                          ),
                                        ),

                                        const SizedBox(height: 16),
                                        Text(
                                          'No tasks for today',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        _buildNewListButton(),
                                        const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                            // Nếu có task, vẫn hiện nút tạo mới ở cuối
                            if (hasTaskToday) ...[
                              _buildNewListButton(),
                              const SizedBox(height: 40),
                            ],
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: const ChatFloatingButton(
        showBadge: true,
        unreadCount: 3,
      ),
    );
  }

  Widget _buildNewListButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: _showNewListBottomSheet,
        // icon: const Icon(Icons.add),
        label: const Text(
          'Tap to create a new list',
          style: TextStyle(color: AppColors.primary, fontSize: 16),
        ),
      ),
    );
  }

  // Widget _buildGradientCard(String title, IconData icon,
  //     {VoidCallback? onTap}) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: 140,
  //       margin: const EdgeInsets.only(right: 12),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [
  //             AppColors.primary.withOpacity(0.8),
  //             AppColors.primary.withOpacity(0.6),
  //           ],
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //             color: AppColors.primary.withOpacity(0.3),
  //             blurRadius: 8,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Icon(icon, color: Colors.white, size: 28),
  //             const SizedBox(height: 8),
  //             Text(
  //               title,
  //               style: const TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 14,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget _buildTaskSection(
    String title,
    IconData icon,
    Color color,
    List tasks,
    Category category,
  ) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, size: 22),
                  color: AppColors.black,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Get.to(
                      () => AddTaskPage(initialCategoryId: category.id),
                      preventDuplicates: false,
                    );
                  },
                ),
              ],
            ),
          ),
          // ListView.builder(
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   itemCount: tasks.length,
          //   itemBuilder: (context, index) {
          //     final task = tasks[index];
          //     return Padding(
          //       padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
          //       child: InkWell(
          //         onTap: () {
          //           // Toggle task completion
          //           _taskController.toggleTaskCompletion(task);
          //         },
          //         borderRadius: BorderRadius.circular(8),
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(vertical: 4),
          //           child: Row(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.only(top: 2),
          //                 child: Icon(
          //                   task.isCompleted
          //                       ? Icons.check_circle
          //                       : Icons.radio_button_unchecked,
          //                   color: task.isCompleted
          //                       ? Colors.green
          //                       : AppColors.primary,
          //                   size: 22,
          //                 ),
          //               ),
          //               const SizedBox(width: 12),
          //               Expanded(
          //                 child: Text(
          //                   task.title,
          //                   style: TextStyle(
          //                     fontSize: 16,
          //                     decoration: task.isCompleted
          //                         ? TextDecoration.lineThrough
          //                         : null,
          //                     color:
          //                         task.isCompleted ? Colors.grey : Colors.black,
          //                   ),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // )
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vòng tròn toggle
                      GestureDetector(
                        onTap: () {
                          final wasCompleted = task.isCompleted;

                          _taskController.toggleTaskCompletion(task);
                          if (!wasCompleted) {
                            // Hiển thị nút undo lơ lửng
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierColor: Colors.transparent,
                              builder: (BuildContext context) {
                                // Tự động đóng sau 3 giây
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                });

                                return Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, bottom: 80),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          _taskController
                                              .toggleTaskCompletion(task);
                                        },
                                        borderRadius: BorderRadius.circular(30),
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.circle,
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //     color: Colors.black
                                            //         .withOpacity(0.3),
                                            //     blurRadius: 8,
                                            //     offset: const Offset(0, 4),
                                            //   ),
                                            // ],
                                          ),
                                          child: const Icon(
                                            Icons.undo,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: task.isCompleted
                                ? Colors.green
                                : AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Tiêu đề task (không bấm được)
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color:
                                task.isCompleted ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildGradientCard(String title, IconData icon,
      {VoidCallback? onTap}) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
        child: Container(
          width: 80,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter, // Đổi từ topLeft
              end: Alignment.bottomCenter, // Đổi từ bottomRight
              colors: [
                Color.fromRGBO(63, 66, 68, 0.871), // rgba với opacity
                Color.fromRGBO(123, 75, 255, 0.870588), // rgba với opacity
                Color(0xFF575DFB), // Solid color
              ],
              stops: [0.0, 0.0, 1.0], // 0% và 0% giống nhau, 100%
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25), // Đúng theo CSS
                blurRadius: 4, // Blur 4px
                offset: const Offset(0, 4), // Y offset 2px
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 30,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
