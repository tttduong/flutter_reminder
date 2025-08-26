// widgets/custom_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';
import '../../providers/user_provider.dart';

class CustomSidebar extends StatelessWidget {
  final Function(Category) onCategoryTap;
  final VoidCallback onAddCategoryTap;
  final CategoryController categoryController;

  const CustomSidebar({
    Key? key,
    required this.onCategoryTap,
    required this.onAddCategoryTap,
    required this.categoryController,
  }) : super(key: key);

  void openCategory(Category category) {
    AppNavigation.navigateToCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          // User section
          _buildUserSection(context),

          // Categories section
          _buildCategoriesSection(context),

          // Add category button
          _buildAddCategoryButton(context),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
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
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Icon(
                  userName == null ? Icons.person : Icons.person,
                  size: 20,
                  color: AppColors.white,
                ),
              ),

              const SizedBox(width: 10),

              // User name or guest
              // Text(
              //   userName ?? "Login/ Register",
              //   style: const TextStyle(
              //     fontSize: 18,
              //     fontWeight: FontWeight.w600,
              //     color: AppColors.black,
              //   ),
              // ),

              // const SizedBox(height: 12),

              // Login/Logout button
              SizedBox(
                // width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close drawer first
                    if (userName == null) {
                      Get.to(() => const SignInPage());
                    } else {
                      _logOut(context, userProvider);
                    }
                  },
                  // icon: Icon(userName == null ? Icons.login : Icons.logout),
                  label: Text(
                    userName ?? "Login/ Register",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: 20),
                  ),
                  // style: ElevatedButton.styleFrom(
                  // backgroundColor: AppColors.primary,
                  // foregroundColor: AppColors.black,
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  // padding: const EdgeInsets.symmetric(vertical: 12),
                  // ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Categories list
            Expanded(
              child: Obx(() {
                // if (categoryController.categoryList.isEmpty) {
                //   return _buildEmptyState();
                // }

                return ListView.builder(
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_off_outlined,
            size: 64,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No categories yet",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create your first category",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    return Container(
      // margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: category.color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            category.icon,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          category.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        subtitle: Text(
          "5/10",
          style: TextStyle(
            fontSize: 12,
            color: AppColors.primary.withOpacity(0.6),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppColors.primary.withOpacity(0.6),
            size: 20,
          ),
          onSelected: (String value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context, category);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          onCategoryTap(category);
          // openCategory(category);
          Navigator.of(context).pop(); // Close drawer
          // openCategory(context, category);
          // AppNavigation.navigateToCategory(category);
        },
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          // width: double.infinity,
          child: TextButton.icon(
            onPressed: onAddCategoryTap,
            icon: const Icon(
              Icons.add,
              color: AppColors.black,
            ),
            label: const Text(
              "New List",
              style: TextStyle(color: AppColors.black, fontSize: 20),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ),
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
            TextButton(
              onPressed: () {
                categoryController.deleteCategory(category.id);
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _logOut(BuildContext context, UserProvider userProvider) async {
    try {
      bool removeSuccess = await LocalStoreServices.removeFromLocal(context);
      if (removeSuccess) {
        userProvider.setUserNull();
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Logged out successfully"),
            backgroundColor: Colors.green,
          ),
        );
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
