// // widgets/custom_sidebar.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/api.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import 'package:flutter_to_do_app/controller/category_controller.dart';
// import 'package:flutter_to_do_app/controller/task_controller.dart';
// import 'package:flutter_to_do_app/data/models/category.dart';
// import 'package:flutter_to_do_app/data/services/auth_services.dart';
// import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
// import 'package:flutter_to_do_app/ui/screens/login_page.dart';
// import 'package:flutter_to_do_app/ui/screens/screens.dart';
// import 'package:flutter_to_do_app/ui/widgets/add_list_button.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_to_do_app/data/services/local_store_services.dart';
// import '../../providers/user_provider.dart';

// class CustomSidebar extends StatelessWidget {
//   final Function(Category) onCategoryTap;
//   final VoidCallback onAddCategoryTap;
//   final CategoryController categoryController;
//   final Function(bool)? onDrawerChanged;
//   const CustomSidebar({
//     Key? key,
//     required this.onCategoryTap,
//     required this.onAddCategoryTap,
//     required this.categoryController,
//     this.onDrawerChanged,
//   }) : super(key: key);

//   void openCategory(BuildContext context, Category category) {
//     AppNavigation.navigateToCategory(context, category);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       backgroundColor: AppColors.white,
//       child: Column(
//         children: [
//           // User section
//           _buildUserSection(context),

//           // Categories section
//           _buildCategoriesSection(context),

//           // Add category button
//           _buildAddCategoryButton(context),
//         ],
//       ),
//     );
//   }

//   // Widget _buildUserSection(BuildContext context) {
//   //   return Container(
//   //     padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
//   //     decoration: BoxDecoration(
//   //       color: AppColors.white,
//   //       borderRadius: const BorderRadius.only(
//   //         bottomLeft: Radius.circular(20),
//   //         bottomRight: Radius.circular(20),
//   //       ),
//   //     ),
//   //     child: Consumer<UserProvider>(
//   //       builder: (context, userProvider, child) {
//   //         final user = userProvider.user;
//   //         final userName = user?.username;

//   //         return Row(
//   //           children: [
//   //             // Avatar
//   //             CircleAvatar(
//   //               radius: 20,
//   //               backgroundColor: AppColors.primary,
//   //               child: Icon(
//   //                 userName == null ? Icons.person : Icons.person,
//   //                 size: 20,
//   //                 color: AppColors.white,
//   //               ),
//   //             ),

//   //             // const SizedBox(width: 10),

//   //             // User name or guest
//   //             // Text(
//   //             //   userName ?? "Login/ Register",
//   //             //   style: const TextStyle(
//   //             //     fontSize: 18,
//   //             //     fontWeight: FontWeight.w600,
//   //             //     color: AppColors.black,
//   //             //   ),
//   //             // ),

//   //             // const SizedBox(height: 12),

//   //             // Login/Logout button
//   //             SizedBox(
//   //               // width: double.infinity,
//   //               child: TextButton.icon(
//   //                 onPressed: () {
//   //                   Navigator.of(context).pop(); // Close drawer first
//   //                   if (userName == null) {
//   //                     // Get.to(() => const SignInPage());
//   //                     Get.to(() => const LoginPage());
//   //                   } else {
//   //                     _logOut(context, userProvider);
//   //                   }
//   //                 },
//   //                 // icon: Icon(userName == null ? Icons.login : Icons.logout),
//   //                 label: Text(
//   //                   userName ?? "Login/ Register",
//   //                   textAlign: TextAlign.start,
//   //                   style: TextStyle(fontSize: 20, color: AppColors.primary),
//   //                 ),
//   //                 // style: ElevatedButton.styleFrom(
//   //                 // backgroundColor: AppColors.primary,
//   //                 // foregroundColor: AppColors.black,
//   //                 // shape: RoundedRectangleBorder(
//   //                 //   borderRadius: BorderRadius.circular(12),
//   //                 // ),
//   //                 // padding: const EdgeInsets.symmetric(vertical: 12),
//   //                 // ),
//   //               ),
//   //             ),
//   //           ],
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }
//   Widget _buildUserSection(BuildContext context) {
//     return Container(
//         padding:
//             const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
//         decoration: const BoxDecoration(
//           color: AppColors.white,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(20),
//             bottomRight: Radius.circular(20),
//           ),
//         ),
//         child: Consumer<UserProvider>(
//           builder: (context, userProvider, child) {
//             final user = userProvider.user;
//             final userName = user?.username;

//             return Row(
//               children: [
//                 CircleAvatar(
//                   radius: 20,
//                   backgroundColor: AppColors.primary,
//                   child: Icon(Icons.person, size: 20, color: AppColors.white),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextButton(
//                     onPressed: () async {
//                       Navigator.of(context).pop();
//                       if (userName == null) {
//                         Get.to(() => const LoginPage());
//                       } else {
//                         // await ApiService.dio.post('/api/v1/logout');
//                         await AuthService.logout();
//                         _logOut(context, userProvider);
//                         // userProvider.clearUser();
//                       }
//                     },
//                     child: Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         userName ?? "Login / Register",
//                         style:
//                             TextStyle(fontSize: 18, color: AppColors.primary),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ));
//   }

//   Widget _buildCategoriesSection(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 6),

//             // Categories list
//             Expanded(
//               child: Obx(() {
//                 // ⭐ Hiển thị loading
//                 if (categoryController.isLoading.value) {
//                   return Center(
//                     child: CircularProgressIndicator(),
//                   );
//                 }

//                 // ⭐ Hiển thị empty state
//                 if (categoryController.categoryList.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.category_outlined,
//                             size: 64, color: Colors.grey),
//                         SizedBox(height: 16),
//                         Text(
//                           "No categories",
//                           style: TextStyle(color: Colors.grey, fontSize: 16),
//                         ),
//                         SizedBox(height: 8),
//                         TextButton(
//                           onPressed: () => categoryController.getCategories(),
//                           child: Text("Refresh"),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // ⭐ Hiển thị danh sách categories
//                 return ListView.builder(
//                   padding: EdgeInsets.zero,
//                   itemCount: categoryController.categoryList.length,
//                   itemBuilder: (context, index) {
//                     final category = categoryController.categoryList[index];
//                     return _buildCategoryTile(context, category);
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.folder_off_outlined,
//             size: 64,
//             color: AppColors.primary.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "No categories yet",
//             style: TextStyle(
//               fontSize: 16,
//               color: AppColors.primary.withOpacity(0.6),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Create your first category",
//             style: TextStyle(
//               fontSize: 14,
//               color: AppColors.primary.withOpacity(0.4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryTile(BuildContext context, Category category) {
//     return ListTile(
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       leading: Container(
//         width: 32,
//         height: 32,
//         decoration: BoxDecoration(
//           color: category.color.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           category.icon,
//           color: category.color,
//           size: 18,
//         ),
//       ),
//       title: Text(
//         category.title,
//         style: const TextStyle(
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       // trailing: Text(
//       //   '${category.taskCount ?? 0}',
//       //   style: TextStyle(
//       //     fontSize: 12,
//       //     color: Colors.grey[600],
//       //   ),
//       // ),
//       onTap: () {
//         // Navigate NGAY LẬP TỨC - không đợi drawer đóng
//         onCategoryTap(category);

//         // Đóng drawer âm thầm phía sau (sau khi navigate xong)
//         Future.delayed(const Duration(milliseconds: 50), () {
//           if (Navigator.of(context).canPop()) {
//             Navigator.of(context).pop();
//           }
//         });
//       },
//     );
//   }

//   Widget _buildAddCategoryButton(BuildContext context) {
//     return AddListButton(onAddCategoryTap: onAddCategoryTap);
//   }

//   void _showDeleteConfirmation(BuildContext context, Category category) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text(
//             "Delete Category?",
//             textAlign: TextAlign.center,
//           ),
//           content: Text(
//             "Deleting '${category.title}' will also remove all its tasks permanently. This action cannot be undone.",
//             textAlign: TextAlign.justify,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text(
//                 "Cancel",
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 categoryController.deleteCategory(category.id);
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Delete", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _logOut(BuildContext context, UserProvider userProvider) async {
//     try {
//       bool removeSuccess = await LocalStoreServices.removeFromLocal(context);
//       if (removeSuccess) {
//         userProvider.setUserNull();
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Logged out successfully"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error logging out: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/services/auth_services.dart';
import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
import 'package:flutter_to_do_app/ui/screens/login_page.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:flutter_to_do_app/ui/screens/welcome_page.dart';
import 'package:flutter_to_do_app/ui/widgets/add_list_button.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';
import '../../providers/user_provider.dart';

class CustomSidebar extends StatefulWidget {
  final Function(Category) onCategoryTap;
  final VoidCallback onAddCategoryTap;
  final CategoryController categoryController;
  final Function(bool)? onDrawerChanged;

  const CustomSidebar({
    Key? key,
    required this.onCategoryTap,
    required this.onAddCategoryTap,
    required this.categoryController,
    this.onDrawerChanged,
  }) : super(key: key);

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  late final CategoryController categoryController;

  @override
  void initState() {
    super.initState();
    categoryController = widget.categoryController;

    // ✅ Gọi load categories 1 lần khi Sidebar được khởi tạo
    if (categoryController.categoryList.isEmpty) {
      categoryController.getCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          _buildUserSection(context),
          _buildCategoriesSection(context),
          _buildAddCategoryButton(context),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          final userName = user?.username;

          return Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child:
                    const Icon(Icons.person, size: 20, color: AppColors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (userName == null) {
                      Get.to(() => const LoginPage());
                    } else {
                      await AuthService.logout();
                      _logOut(context, userProvider);
                    }
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      userName ?? "Login / Register",
                      style: const TextStyle(
                          fontSize: 18, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Expanded(
              child: Obx(() {
                // ⭐ Hiển thị loading
                if (categoryController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                // ⭐ Hiển thị empty state
                if (categoryController.categoryList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "No categories",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => categoryController.getCategories(),
                          child: const Text("Refresh"),
                        ),
                      ],
                    ),
                  );
                }

                // ⭐ Hiển thị danh sách categories
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: categoryController.categoryList.length,
                  itemBuilder: (context, index) {
                    final category = categoryController.categoryList[index];
                    return _buildCategoryTile(context, category);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(category.icon, color: category.color, size: 18),
      ),
      title: Text(
        category.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // 👇 Nhấn bình thường → mở trang CategoryTasksPage
      onTap: () {
        Navigator.of(context).pop(); // Đóng Drawer
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryTasksPage(category: category),
          ),
        );
      },

      // 👇 Nhấn giữ → mở tuỳ chọn
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (_) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      // 👉 Thực hiện hành động edit (tùy bạn định nghĩa)
                      // _showEditCategoryDialog(context, category);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete'),
                    onTap: () async {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, category);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Delete Category?",
            textAlign: TextAlign.center,
          ),
          content: Text(
            "Deleting '${category.title}' will also remove all its tasks permanently. This action cannot be undone.",
            textAlign: TextAlign.justify,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     categoryController.deleteCategory(category.id);
            //     Navigator.of(context).pop();
            //   },
            //   child: const Text("Delete", style: TextStyle(color: Colors.red)),
            // ),
            TextButton(
              onPressed: () async {
                final success =
                    await categoryController.deleteCategory(category);

                Navigator.of(context).pop();

                if (!success) {
                  Get.snackbar(
                    "Can not delete!",
                    "The default category can not be deleted.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red,
                  );
                } else {
                  Get.snackbar(
                    "Success",
                    "Category deleted successfully.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade100,
                    colorText: Colors.green,
                  );
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return AddListButton(onAddCategoryTap: widget.onAddCategoryTap);
  }

  void _logOut(BuildContext context, UserProvider userProvider) async {
    try {
      bool removeSuccess = await LocalStoreServices.removeFromLocal(context);
      if (removeSuccess) {
        userProvider.setUserNull();
        Get.offAll(() => const WelcomePage());

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text("Logged out successfully"),
        //     backgroundColor: Colors.green,
        //   ),
        // );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error logging out: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
