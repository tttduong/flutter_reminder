import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/ui/screens/add_task.dart';
import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:flutter_to_do_app/ui/widgets/appbar.dart';
import 'package:flutter_to_do_app/ui/widgets/navbar.dart';
import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';

import '../../controller/task_controller.dart';
import '../../providers/user_provider.dart';
import 'add_list.dart';

class AppNavigation {
  static final GlobalKey<BottomNavBarScreenState> bottomNavKey =
      GlobalKey<BottomNavBarScreenState>();

//   // Method để navigate đến category từ bất kỳ đâu
//   static void navigateToCategory(Category category) {
//     print("navigate to category");
//     bottomNavKey.currentState?.openCategory(category);
//   }
  static void navigateToCategory(Category category) {
    print("navigate to category");
    bottomNavKey.currentState!.openCategory(category);
  }
}

class BottomNavBarScreen extends StatefulWidget {
  final Category? initialCategory;
  // const BottomNavBarScreen({super.key});

  const BottomNavBarScreen({super.key, this.initialCategory});
  @override
  State<BottomNavBarScreen> createState() => BottomNavBarScreenState();
}

class BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int selectedIndex = 0;
  Category? selectedCategory;
  bool isViewingCategory = false;
  final _categoryController = Get.put(CategoryController());
  Key _bodyKey = UniqueKey();
  static BottomNavBarScreenState? _instance;
  @override
  void initState() {
    super.initState();
    print("🔥 initState - initialCategory: ${widget.initialCategory?.id}");
    selectedCategory = widget.initialCategory;
    _instance = this;
  }

  @override
  void dispose() {
    _instance = null;
    super.dispose();
  }

  static void navigateToCategoryFromAnywhere(Category category) {
    if (_instance != null) {
      _instance!.openCategory(category);
    }
  }

  void _handleNavbarTap(int index) {
    setState(() {
      selectedIndex = index;
      isViewingCategory = false;
    });
  }

// 📂 Category handlers
  void _handleCategoryTap(Category category) {
    openCategory(category);
  }

  void _handleAddCategoryTap() {
    _showNewListBottomSheet();
  }

  // 🔍 Search handler
  void _handleSearchChanged(String query) {
    print("Search query: $query");
    // Implement search logic here
  }

  // 🔔 AppBar action handlers
  void _handleNotificationTap() {
    print("Notification tapped");
    // Navigate to notifications screen
  }

  void _handleMoreTap() {
    print("More options tapped");
    // Show more options menu
  }

  void openCategory(Category category) {
    setState(() {
      selectedCategory = category;
      isViewingCategory = true;
      _bodyKey = UniqueKey();
    });

    // chỉ fetch task thôi, KHÔNG push
    TaskController taskController = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());
    taskController.getTasksByCategory(category.id!);

    print("✅ openCategory set body to CategoryTasksPage (${category.title})");
  }

  void _showNewListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewListBottomSheet(),
    );
  }

  void clearCategory() {
    setState(() {
      selectedCategory = null;
      isViewingCategory = false;
      print("⬅️ clearCate triggered, isViewingCategory=$isViewingCategory");
    });
  }

  void backToHome() {
    setState(() {
      isViewingCategory = false;
      selectedCategory = null;
      print("⬅️ backToHome triggered, isViewingCategory=$isViewingCategory");
    });
  }

  Widget _getCurrentScreen() {
    print("🔍 _getCurrentScreen debug:");
    print("   - isViewingCategory: $isViewingCategory");
    print("   - selectedCategory: ${selectedCategory?.title}");
    print("   - selectedIndex: $selectedIndex");

    if (isViewingCategory && selectedCategory != null) {
      print("✅ Going to CategoryTasksPage with ${selectedCategory!.title}");
      return CategoryTasksPage(
        category: selectedCategory!,
        onBackPressed: backToHome,
      );
    }

    // Ngược lại hiện screen theo selectedIndex
    print("   → Switching to selectedIndex: $selectedIndex");
    switch (selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return CalendarTasks();
      case 2:
        return const SignInPage();
      case 3:
        return const ChatPage();
      case 4:
        print("   → Returning ChatPage (case 4)");
        return const ChatPage();
      default:
        return const SignInPage();
    }
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
    return Scaffold(
      // key: AppNavigation.bottomNavKey,
      // 📱 Custom App Bar
      appBar: CustomAppBar(
        showSearchBar: false, // Set true nếu muốn hiện search bar
        searchHint: 'Search tasks...',
        onSearchChanged: _handleSearchChanged,
        onNotificationTap: _handleNotificationTap,
        onMoreTap: _handleMoreTap,
      ),

      // 🗂️ Custom Sidebar/Drawer
      drawer: CustomSidebar(
        categoryController: _categoryController,
        onCategoryTap: _handleCategoryTap,
        onAddCategoryTap: _handleAddCategoryTap,
      ),

      body: KeyedSubtree(
        key: _bodyKey,
        child: _getCurrentScreen(),
      ),
      // _getCurrentScreen(),
      bottomNavigationBar: Navbar(
        currentIndex: isViewingCategory ? 2 : selectedIndex,
        // currentIndex: selectedIndex,
        onTap: _handleNavbarTap,
        // onMiddleButtonTap: _handleMiddleButtonTap,
        onMiddleButtonTap: () async {
          Get.to(() => const AddTaskPage(), preventDuplicates: false);
        },
      ),
    );
  }
}
