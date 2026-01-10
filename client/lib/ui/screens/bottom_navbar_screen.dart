// import 'package:flutter/material.dart';
// import 'package:flutter_to_do_app/consts.dart';
// import 'package:flutter_to_do_app/controller/category_controller.dart';
// import 'package:flutter_to_do_app/data/models/category.dart';
// import 'package:flutter_to_do_app/ui/screens/add_task.dart';
// // import 'package:flutter_to_do_app/ui/screens/base_app.dart';
// // import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
// import 'package:flutter_to_do_app/ui/screens/eisenhower_matrix.dart';
// import 'package:flutter_to_do_app/ui/screens/screens.dart';
// import 'package:flutter_to_do_app/ui/widgets/appbar.dart';
// import 'package:flutter_to_do_app/ui/widgets/navbar.dart';
// import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_to_do_app/data/services/local_store_services.dart';

// import '../../controller/task_controller.dart';
// import '../../providers/user_provider.dart';
// import 'add_list.dart';
// import 'package:flutter_to_do_app/ui/screens/base_app.dart';
// import 'package:flutter_to_do_app/ui/screens/category_tasks.dart' as cat_tasks;

// class AppNavigation {
//   static final GlobalKey<BottomNavBarScreenState> bottomNavKey =
//       GlobalKey<BottomNavBarScreenState>();
//   static final ValueNotifier<bool> isDrawerOpen = ValueNotifier<bool>(false);

// //   // Method để navigate đến category từ bất kỳ đâu
// //   static void navigateToCategory(Category category) {
// //     print("navigate to category");
// //     bottomNavKey.currentState?.openCategory(category);
// //   }
//   static void navigateToCategory(Category category) {
//     print("navigate to category");
//     bottomNavKey.currentState!.openCategory(category);
//   }

//   static void openDrawer() {
//     isDrawerOpen.value = true;
//   }

//   static void closeDrawer() {
//     isDrawerOpen.value = false;
//   }
// }

// class BottomNavBarScreen extends StatefulWidget {
//   final Category? initialCategory;
//   // const BottomNavBarScreen({super.key});

//   const BottomNavBarScreen({super.key, this.initialCategory});
//   @override
//   State<BottomNavBarScreen> createState() => BottomNavBarScreenState();
// }

// class BottomNavBarScreenState extends State<BottomNavBarScreen> {
//   int selectedIndex = 0;
//   Category? selectedCategory;
//   bool isViewingCategory = false;
//   final _categoryController = Get.put(CategoryController());
//   Key _bodyKey = UniqueKey();
//   static BottomNavBarScreenState? _instance;
//   bool _isDrawerOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     print("🔥 initState - initialCategory: ${widget.initialCategory?.id}");
//     selectedCategory = widget.initialCategory;
//     _instance = this;
//     // 👇 Listen to global drawer state
//     AppNavigation.isDrawerOpen.addListener(_onDrawerStateChanged);
//   }

//   @override
//   void dispose() {
//     AppNavigation.isDrawerOpen.removeListener(_onDrawerStateChanged);
//     _instance = null;
//     super.dispose();
//   }

//   void _onDrawerStateChanged() {
//     if (mounted) {
//       setState(() {
//         print(
//             "🚪------------------- Drawer ${AppNavigation.isDrawerOpen.value ? 'OPENED' : 'CLOSED'}");
//       });
//     }
//   }

//   static void navigateToCategoryFromAnywhere(Category category) {
//     if (_instance != null) {
//       _instance!.openCategory(category);
//     }
//   }

//   void _handleNavbarTap(int index) {
//     setState(() {
//       selectedIndex = index;
//       isViewingCategory = false;
//     });
//   }

// // 📂 Category handlers
//   void _handleCategoryTap(Category category) {
//     openCategory(category);
//   }

//   void _handleAddCategoryTap() {
//     _showNewListBottomSheet();
//   }

//   // 🔍 Search handler
//   void _handleSearchChanged(String query) {
//     print("Search query: $query");
//     // Implement search logic here
//   }

//   // 🔔 AppBar action handlers
//   void _handleNotificationTap() {
//     print("Notification tapped");
//     // Navigate to notifications screen
//   }

//   void _handleMoreTap() {
//     print("More options tapped");
//     // Show more options menu
//   }

//   void openCategory(Category category) {
//     setState(() {
//       selectedCategory = category;
//       isViewingCategory = true;
//       _bodyKey = UniqueKey();
//     });

//     // chỉ fetch task thôi, KHÔNG push
//     TaskController taskController = Get.isRegistered<TaskController>()
//         ? Get.find<TaskController>()
//         : Get.put(TaskController());
//     taskController.getTasksByCategory(category.id!);

//     print("✅ openCategory set body to CategoryTasksPage (${category.title})");
//   }

//   void _showNewListBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const NewListBottomSheet(),
//     );
//   }

//   void clearCategory() {
//     setState(() {
//       selectedCategory = null;
//       isViewingCategory = false;
//       print("⬅️ clearCate triggered, isViewingCategory=$isViewingCategory");
//     });
//   }

//   void backToHome() {
//     setState(() {
//       isViewingCategory = false;
//       selectedCategory = null;
//       print("⬅️ backToHome triggered, isViewingCategory=$isViewingCategory");
//     });
//   }

//   Widget _getCurrentScreen() {
//     print("🔍 _getCurrentScreen debug:");
//     print("   - isViewingCategory: $isViewingCategory");
//     print("   - selectedCategory: ${selectedCategory?.title}");
//     print("   - selectedIndex: $selectedIndex");

//     // if (isViewingCategory && selectedCategory != null) {
//     //   print("✅ Going to CategoryTasksPage with ${selectedCategory!.title}");
//     //   return CategoryTasksPage(
//     //     category: selectedCategory!,
//     //     onBackPressed: backToHome,
//     //   );
//     // }
//     if (isViewingCategory && selectedCategory != null) {
//       print("✅ Going to CategoryTasksPage with ${selectedCategory!.title}");
//       return cat_tasks.CategoryTasksPage(
//         category: selectedCategory!,
//         onBackPressed: backToHome,
//       );
//     }

//     // Ngược lại hiện screen theo selectedIndex
//     print("   → Switching to selectedIndex: $selectedIndex");
//     switch (selectedIndex) {
//       case 0:
//         return HomePage();
//       case 1:
//         return CalendarTasks();
//       case 2:
//         return const SignInPage();
//       case 3:
//         return EisenhowerMatrix();
//       case 4:
//         return const UpdateProfileScreen();
//       default:
//         return const SignInPage();
//     }
//   }

//   void _logOut() async {
//     bool removeSuccess = await LocalStoreServices.removeFromLocal(context);
//     if (removeSuccess) {
//       if (!mounted) return;
//       Provider.of<UserProvider>(context, listen: false).setUserNull();
//     }
//   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // return Scaffold(
// //     //   extendBody: true,
// //     //   backgroundColor: Colors.transparent,
// //     return BaseAppScreen(
// //       showDrawer: true, // 👈 Luôn cho phép drawer
// //       onDrawerChanged: (isOpened) {
// //         setState(() => _isDrawerOpen = isOpened);
// //       },
// //       showSearchBar: false,
// //       searchHint: 'Search tasks...',
// //       body: KeyedSubtree(
// //         key: _bodyKey,
// //         child: _getCurrentScreen(),
// //       ),
// //       // _getCurrentScreen(),
// //       // bottomNavigationBar: Navbar(
// //       //   currentIndex: isViewingCategory ? 2 : selectedIndex,
// //       //   // currentIndex: selectedIndex,
// //       //   onTap: _handleNavbarTap,
// //       //   // onMiddleButtonTap: _handleMiddleButtonTap,
// //       //   onMiddleButtonTap: () async {
// //       //     Get.to(() => const AddTaskPage(), preventDuplicates: false);
// //       //   },
// //       // ),
// //       // bottomNavigationBar: AnimatedSlide(
// //       //   duration: const Duration(milliseconds: 300),
// //       //   offset: _isDrawerOpen ? const Offset(0, 1) : Offset.zero,
// //       //   child: AnimatedOpacity(
// //       //     duration: const Duration(milliseconds: 250),
// //       //     opacity: _isDrawerOpen ? 0.0 : 1.0,
// //       //     child: Navbar(
// //       //       currentIndex: isViewingCategory ? 2 : selectedIndex,
// //       //       // currentIndex: selectedIndex,
// //       //       onTap: _handleNavbarTap,
// //       //       // onMiddleButtonTap: _handleMiddleButtonTap,
// //       //       onMiddleButtonTap: () async {
// //       //         Get.to(() => const AddTaskPage(), preventDuplicates: false);
// //       //       },
// //       //     ),
// //       //   ),
// //       // ),
// //     );

// //   }

// // }
//   @override
//   Widget build(BuildContext context) {
//     // 👇 Scaffold BỌC NGOÀI BaseAppScreen
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBody: true,
//       // 👇 Body là BaseAppScreen
//       body: BaseAppScreen(
//         showDrawer: true,
//         onDrawerChanged: (isOpened) {
//           print("⚡ BottomNavBarScreen received drawer change: $isOpened");
//           // Update global state
//           AppNavigation.isDrawerOpen.value = isOpened;
//         },
//         body: KeyedSubtree(
//           key: _bodyKey,
//           child: _getCurrentScreen(),
//         ),
//       ),
//       // 👇 Navbar ở đây, NGOÀI BaseAppScreen
//       bottomNavigationBar: ValueListenableBuilder<bool>(
//         valueListenable: AppNavigation.isDrawerOpen,
//         builder: (context, isDrawerOpen, child) {
//           return AnimatedSlide(
//             duration: const Duration(milliseconds: 300),
//             offset: isDrawerOpen ? const Offset(0, 1) : Offset.zero,
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 250),
//               opacity: isDrawerOpen ? 0.0 : 1.0,
//               child: IgnorePointer(
//                 ignoring: isDrawerOpen,
//                 child: Navbar(
//                   currentIndex: isViewingCategory ? 2 : selectedIndex,
//                   onTap: _handleNavbarTap,
//                   onMiddleButtonTap: () async {
//                     Get.to(() => const AddTaskPage(), preventDuplicates: false);
//                   },
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/ui/screens/add_task.dart';
import 'package:flutter_to_do_app/ui/screens/eisenhower_matrix.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
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

  // static void navigateToCategory(Category category) {
  //   print("navigate to category");
  //   bottomNavKey.currentState!.openCategory(category);
  // }
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
        return EisenhowerMatrix();
      case 4:
        // return const UpdateProfileScreen();
        return const WelcomePage();
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewListBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
            onMiddleButtonTap: () async {
              Get.to(() => const AddTaskPage(), preventDuplicates: false);
            },
          ),
        ),

        // ✅ Drawer overlay mượt thực sự (nền fade, drawer trượt)
        IgnorePointer(
          ignoring: !_isDrawerVisible, // ngăn chạm khi ẩn
          child: Stack(
            children: [
              // 🔹 Nền đen mờ (fade)
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

              // 🔹 Drawer trắng (slide)
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
    );
  }
}
