// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/controller/task_controller.dart';
// import 'package:flutter_to_do_app/data/models/category.dart';
// import 'package:flutter_to_do_app/data/services/local_store_services.dart';
// import 'package:flutter_to_do_app/ui/screens/add_list.dart';
// import 'package:flutter_to_do_app/ui/screens/signin_screen.dart';
// import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
// import 'package:get/get.dart';

// import 'package:provider/provider.dart';

// import '../../controller/category_controller.dart';
// import '../../data/models/task.dart';
// import '../../providers/providers.dart';
// import '../widgets/button_add_task.dart';

// class HomePage extends StatefulWidget {
//   final Category? category;
//   const HomePage({super.key, this.category});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TaskController taskController;
//   // final Map<String, Future<List<Task>>> _completedTaskFutures = {};
//   final _categoryController = Get.put(CategoryController());
//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo controller
//     taskController = Get.put(TaskController());
//     // Gọi hàm fetch task nếu cần
//     // taskController.getTasks();
//     _categoryController.getCategories();
//   }

//   // void _showNewListBottomSheet() {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     backgroundColor: Colors.transparent,
//   //     builder: (context) => const NewListBottomSheet(),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     // final user = Provider.of<UserProvider>(context).user;

//     // if (user != null) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   widget.category?.title ?? 'Inbox',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 // IconButton(
//                 //   onPressed:
//                 //   _showNewListBottomSheet,
//                 //   style: IconButton.styleFrom(
//                 //     backgroundColor: AppColors.primary,
//                 //     shape: RoundedRectangleBorder(
//                 //       borderRadius: BorderRadius.circular(8), // Nút vuông
//                 //     ),
//                 //   ),
//                 //   icon: const Icon(
//                 //     Icons.add,
//                 //     color: Colors.white,
//                 //   ),
//                 // ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // _showCategories()
//             // Expanded(
//             //   child: _showTasksByCategory(),
//             // )
//           ],
//         ),
//       ),
//       floatingActionButton: const ButtonAddTask(),
//     );
//   }

//   // Widget _showTasksByCategory() {
//   //   return FutureBuilder<List<Task>>(
//   //     future: taskController.getTasksByCategory(widget.category?.id),
//   //     builder: (context, snapshot) {
//   //       if (snapshot.connectionState == ConnectionState.waiting) {
//   //         return const Center(child: CircularProgressIndicator());
//   //       } else if (snapshot.hasError) {
//   //         return Center(child: Text('Error: ${snapshot.error}'));
//   //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//   //         return const Center(child: Text("No tasks"));
//   //       }

//   //       final allTasks = snapshot.data!;
//   //       final incompleteTasks =
//   //           allTasks.where((t) => t.isCompleted != true).toList();
//   //       final completedTasks =
//   //           allTasks.where((t) => t.isCompleted == true).toList();

//   //       return SingleChildScrollView(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             ListView.builder(
//   //               shrinkWrap: true,
//   //               physics: const NeverScrollableScrollPhysics(),
//   //               itemCount: incompleteTasks.length,
//   //               itemBuilder: (context, index) {
//   //                 final task = incompleteTasks[index];
//   //                 return ListTile(
//   //                   leading: Checkbox(
//   //                     value: task.isCompleted == true,
//   //                     onChanged: (bool? newValue) {
//   //                       final newStatus = newValue ?? false;
//   //                       taskController.updateTaskStatus(task, newStatus);
//   //                       setState(() {}); // cần refactor nếu dùng GetX
//   //                     },
//   //                   ),
//   //                   title: Text(task.title),
//   //                   subtitle: Text(task.description ?? ''),
//   //                 );
//   //               },
//   //             ),
//   //             const SizedBox(height: 16),
//   //             const Text(
//   //               "Completed Tasks",
//   //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   //             ),
//   //             ListView.builder(
//   //               shrinkWrap: true,
//   //               physics: const NeverScrollableScrollPhysics(),
//   //               itemCount: completedTasks.length,
//   //               itemBuilder: (context, index) {
//   //                 final task = completedTasks[index];
//   //                 return ListTile(
//   //                   trailing: IconButton(
//   //                     icon: const Icon(Icons.delete, color: Colors.red),
//   //                     onPressed: () {
//   //                       taskController.deleteTask(task.id);
//   //                       setState(() {});
//   //                     },
//   //                   ),
//   //                   leading: Checkbox(
//   //                     value: task.isCompleted,
//   //                     onChanged: (bool? newValue) {
//   //                       final newStatus = newValue ?? false;
//   //                       taskController.updateTaskStatus(task, newStatus);
//   //                       setState(() {});
//   //                     },
//   //                   ),
//   //                   title: Text(
//   //                     task.title,
//   //                     style: const TextStyle(
//   //                       decoration: TextDecoration.lineThrough,
//   //                     ),
//   //                   ),
//   //                   subtitle: Text(task.description ?? ''),
//   //                 );
//   //               },
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
// }
