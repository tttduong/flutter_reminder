import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/ui/screens/add_task.dart';
import 'package:flutter_to_do_app/ui/screens/eisenhower_matrix.dart';
import 'package:flutter_to_do_app/ui/screens/report_screen.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:flutter_to_do_app/ui/screens/settings.dart';
import 'package:flutter_to_do_app/ui/screens/welcome_page.dart';
import 'package:flutter_to_do_app/ui/widgets/navbar.dart';
import 'package:flutter_to_do_app/ui/widgets/gradient_bg.dart';
import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';
import '../../controller/task_controller.dart';
import '../../providers/user_provider.dart';
import 'add_list.dart';
import 'package:flutter_to_do_app/ui/screens/category_tasks.dart' as cat_tasks;

class AppNavigation {
  static final GlobalKey<BottomNavBarScreenState> bottomNavKey =
      GlobalKey<BottomNavBarScreenState>();

  static void navigateToCategory(BuildContext context, Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => cat_tasks.CategoryTasksPage(category: category),
      ),
    );
  }
}

class BottomNavBarScreen extends StatefulWidget {
  final Category? initialCategory;
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

  // Scaffold key để control drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerVisible = false;

  void _openDrawer() {
    setState(() => _isDrawerVisible = true);
  }

  void _closeDrawer() {
    setState(() => _isDrawerVisible = false);
  }

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

  void openCategory(Category category) {
    setState(() {
      selectedCategory = category;
      isViewingCategory = true;
      _bodyKey = UniqueKey();
    });

    TaskController taskController = Get.isRegistered<TaskController>()
        ? Get.find<TaskController>()
        : Get.put(TaskController());
    taskController.getTasksByCategory(category.id!);

    print("✅ openCategory set body to CategoryTasksPage (${category.title})");
  }

  void backToHome() {
    setState(() {
      isViewingCategory = false;
      selectedCategory = null;
      print("⬅️ backToHome triggered");
    });
  }

  Widget _getCurrentScreen() {
    if (isViewingCategory && selectedCategory != null) {
      return cat_tasks.CategoryTasksPage(
        category: selectedCategory!,
        onBackPressed: backToHome,
      );
    }

    switch (selectedIndex) {
      case 0:
        return HomePage(onMenuTap: _openDrawer);
      case 1:
        return CalendarTasks();
      case 2:
        // return const SignInPage();
        return const WelcomePage();

      case 3:
        // return EisenhowerMatrix();
        return ReportScreen();
      case 4:
        // return const UpdateProfileScreen();
        // return const WelcomePage();
        return SettingsScreen();
      default:
        // return const SignInPage();
        return const WelcomePage();
    }
  }

  // Category handlers
  void _handleCategoryTap(Category category) {
    openCategory(category);
  }

  void _handleAddCategoryTap() {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => const NewListBottomSheet(),
    // );
    Get.bottomSheet(
      const NewListBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // ✅ Lớp nền chính (Scaffold chính)
//         Scaffold(
//           key: _scaffoldKey,
//           backgroundColor: Colors.transparent,
//           extendBody: true,
//           extendBodyBehindAppBar: true,
//           body: Stack(
//             children: [
//               const GradientBackground(),
//               SafeArea(
//                 child: KeyedSubtree(
//                   key: _bodyKey,
//                   child: _getCurrentScreen(),
//                 ),
//               ),
//             ],
//           ),
//           bottomNavigationBar: Navbar(
//             currentIndex: isViewingCategory ? 2 : selectedIndex,
//             onTap: _handleNavbarTap,
//             onMiddleButtonTap: () async {
//               Get.to(() => const AddTaskPage(), preventDuplicates: false);
//             },
//           ),
//         ),

//         // ✅ Drawer overlay mượt thực sự (nền fade, drawer trượt)
//         IgnorePointer(
//           ignoring: !_isDrawerVisible, // ngăn chạm khi ẩn
//           child: Stack(
//             children: [
//               // 🔹 Nền đen mờ (fade)
//               AnimatedOpacity(
//                 duration: const Duration(milliseconds: 300),
//                 opacity: _isDrawerVisible ? 1 : 0,
//                 curve: Curves.easeInOut,
//                 child: GestureDetector(
//                   onTap: _closeDrawer,
//                   child: Container(
//                     color: Colors.black.withOpacity(0.4),
//                   ),
//                 ),
//               ),

//               // 🔹 Drawer trắng (slide)
//               AnimatedPositioned(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeOutCubic,
//                 left: _isDrawerVisible
//                     ? 0
//                     : -MediaQuery.of(context).size.width * 0.85,
//                 top: 0,
//                 bottom: 0,
//                 width: MediaQuery.of(context).size.width * 0.85,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.15),
//                         blurRadius: 12,
//                         offset: const Offset(4, 0),
//                       ),
//                     ],
//                   ),
//                   child: CustomSidebar(
//                     categoryController: _categoryController,
//                     onCategoryTap: (cat) {
//                       _closeDrawer();
//                       _handleCategoryTap(cat);
//                     },
//                     onAddCategoryTap: _handleAddCategoryTap,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 1️⃣ Nếu drawer đang mở → đóng drawer
        if (_isDrawerVisible) {
          _closeDrawer();
          return false;
        }

        // 2️⃣ Nếu đang xem category → quay về home
        if (isViewingCategory) {
          backToHome();
          return false;
        }

        // 3️⃣ Không còn gì chặn → cho phép back thật
        return true;
      },
      child: Stack(
        children: [
          // ✅ Lớp nền chính (Scaffold chính)
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                const GradientBackground(),
                SafeArea(
                  child: KeyedSubtree(
                    key: _bodyKey,
                    child: _getCurrentScreen(),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Navbar(
              currentIndex: isViewingCategory ? 2 : selectedIndex,
              onTap: _handleNavbarTap,
              onMiddleButtonTap: () {
                Get.to(() => const AddTaskPage(), preventDuplicates: false);
              },
            ),
          ),

          // ✅ Drawer overlay mượt
          IgnorePointer(
            ignoring: !_isDrawerVisible,
            child: Stack(
              children: [
                // 🔹 Nền mờ
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isDrawerVisible ? 1 : 0,
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                    onTap: _closeDrawer,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),

                // 🔹 Drawer trượt
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left: _isDrawerVisible
                      ? 0
                      : -MediaQuery.of(context).size.width * 0.85,
                  top: 0,
                  bottom: 0,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(4, 0),
                        ),
                      ],
                    ),
                    child: CustomSidebar(
                      categoryController: _categoryController,
                      onCategoryTap: (cat) {
                        _closeDrawer();
                        _handleCategoryTap(cat);
                      },
                      onAddCategoryTap: _handleAddCategoryTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
