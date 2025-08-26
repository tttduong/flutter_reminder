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
    //   print("navigate to category");
    //   print("bottomNavKey.currentState: ${bottomNavKey.currentState}");
    //   print("bottomNavKey.currentContext: ${bottomNavKey.currentContext}");

    //   if (bottomNavKey.currentState == null) {
    //     print("❌ currentState is null!");

    //     // Thử delay một chút
    //     Future.delayed(Duration(milliseconds: 100), () {
    //       print("Retry after delay...");
    //       print("bottomNavKey.currentState: ${bottomNavKey.currentState}");
    //       bottomNavKey.currentState?.openCategory(category);
    //     });
    //   } else {
    //     print("✅ currentState found, calling openCategory");
    //     bottomNavKey.currentState!.openCategory(category);
    //   }
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

  // void _handleNavbarTap(int index) {
  //   setState(() {
  //     selectedIndex = index;
  //     // selectedCategory = null; // reset khi chuyển tab khác
  //     // Chỉ reset category khi chuyển sang tab khác (không phải tab 0)
  //     if (index != 0) {
  //       selectedCategory = null;
  //     }
  //   });
  // }
  void _handleNavbarTap(int index) {
    setState(() {
      selectedIndex = index;
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

  // void openCategory(Category category) {
  //   // setState(() {
  //   //   selectedCategory = category;
  //   //   selectedIndex = 4;
  //   //   isViewingCategory = true; // 👈 Set flag = true
  //   //   print("openCate - selectedIndex: $selectedIndex");
  //   // });
  //   print("openCate - selectedIndex: $selectedIndex");
  //   // Clear any existing GetX routes that might interfere
  //   if (Get.isOverlaysOpen) {
  //     Get.back();
  //   }
  //   if (category.id != null) {
  //     // print("🚀 Fetching tasks for new category: ${category.id}");

  //     // Lấy TaskController (nếu chưa có thì tạo mới)
  //     TaskController taskController;
  //     if (Get.isRegistered<TaskController>()) {
  //       taskController = Get.find<TaskController>();
  //     } else {
  //       taskController = Get.put(TaskController());
  //     }

  //     // Fetch tasks cho category mới
  //     taskController.getTasksByCategory(category.id!);

  //     // setState(() {
  //     //   selectedCategory = category;

  //     //   isViewingCategory = true;
  //     //   _bodyKey = UniqueKey();
  //     //   print("🔄 setState completed - selectedIndex: $selectedIndex");
  //     // });
  //     setState(() {
  //       selectedCategory = category;
  //       isViewingCategory = true;

  //       _bodyKey = UniqueKey();
  //     });
  //     Navigator.of(context)
  //         .push(
  //       MaterialPageRoute(
  //         builder: (_) => CategoryTasksPage(category: category),
  //       ),
  //     )
  //         .then((_) {
  //       // khi pop thì reset
  //       // clearCategory();
  //     });

  //     // Navigate đến CategoryTasksPage
  //     // Get.to(() => CategoryTasksPage(category: category));
  //     // AppNavigation.navigateToCategory(category);
  //     // Không đổi selectedIndex để navbar không highlight

  //     // print("🔄 setState completed - navigating to ChatPage");
  //     // print("   - selectedCategory: ${selectedCategory?.title}");
  //     // print("   - isViewingCategory: $isViewingCategory");
  //     // _getCurrentScreen();
  //     // WidgetsBinding.instance.addPostFrameCallback((_) {
  //     //   print("🔄 PostFrameCallback - selectedIndex: $selectedIndex");
  //     // });
  //   } else {
  //     print("⚠️ Category ID is null, cannot fetch tasks");
  //   }
  // }

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

    // if (isViewingCategory && selectedCategory != null) {
    //   return CategoryTasksPage(
    //     category: selectedCategory!,
    //     onBackPressed: backToHome,
    //   );
    // }
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
  // Widget _getCurrentScreen() {
  //   // print("Current selected Category: "{$selectedCategor});
  //   switch (selectedIndex) {

  //     case 0:
  //       return const HomePage();
  //     case 1:
  //       return CalendarTasks();
  //     case 2:
  //       return const SignInPage();
  //     case 3:
  //       return const ChatPage();
  //     case 4:
  //       print("   → Returning ChatPage (case 4)");
  //       return const ChatPage();

  //     // return CategoryTasksPage(category: selectedCategory);
  //     // if (isViewingCategory && selectedCategory != null) {
  //     //   print(
  //     //       "   → Returning CategoryTasksPage with category: ${selectedCategory!.title}");
  //     //   return CategoryTasksPage(
  //     //     category: selectedCategory!,
  //     //     onBackPressed: backToHome,
  //     //   );
  //     // } else {
  //     //   print("   → Returning CategoryTasksPage with null category");
  //     //   return const CategoryTasksPage(category: null);
  //     // }
  //     default:
  //       return const HomePage();
  //   }
  // }

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
      // appBar: AppBar(
      //   backgroundColor: AppColors.background,
      //   elevation: 0,
      //   leading: Builder(
      //     builder: (context) => IconButton(
      //       icon: const Icon(Icons.menu, color: AppColors.primary),
      //       onPressed: () {
      //         Scaffold.of(context).openDrawer(); // open sidebar
      //       },
      //     ),
      //   ),
      //   // Search bar-------------------------
      //   // title: Container(
      //   //   height: 40,
      //   //   decoration: BoxDecoration(
      //   //     color: Colors.red,
      //   //     borderRadius: BorderRadius.circular(20),
      //   //   ),
      //   //   child: TextField(
      //   //     decoration: InputDecoration(
      //   //       hintText: 'Search',
      //   //       border: InputBorder.none,
      //   //       prefixIcon: const Icon(Icons.search),
      //   //       contentPadding: const EdgeInsets.symmetric(vertical: 10),
      //   //     ),
      //   //   ),
      //   // ),
      //   // -------------------------------------
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.notifications, color: AppColors.primary),
      //       onPressed: () {},
      //     ),
      //     SizedBox(width: 16),
      //     IconButton(
      //       icon: const Icon(Icons.more_vert, color: AppColors.primary),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      // drawer: Drawer(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     children: [
      //       // 🔒 Nút đăng nhập / tên người dùng
      //       Padding(
      //           padding: const EdgeInsets.only(top: 20, left: 10),
      //           child: Consumer<UserProvider>(
      //               builder: (context, userProvider, child) {
      //             final user = userProvider.user;
      //             final userName = user?.username;
      //             print("Full user: ${user?.toJson()}");

      //             return ElevatedButton.icon(
      //               onPressed: () {
      //                 if (userName == null) {
      //                   Get.to(() => const SignInPage());
      //                 } else {
      //                   // Mở profile hoặc popup đăng xuất nếu muốn
      //                   _logOut();
      //                 }
      //               },
      //               icon: Icon(userName == null ? Icons.login : Icons.person),
      //               label: Text(userName == null ? "Log In" : "Log Out"),
      //               style: ElevatedButton.styleFrom(
      //                 backgroundColor: const Color.fromARGB(255, 168, 182, 151),
      //                 foregroundColor: Colors.white,
      //               ),
      //             );
      //           })),

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
      //       Expanded(
      //         child: Obx(() {
      //           if (_categoryController.categoryList.isEmpty) {
      //             return const ListTile(
      //               title: Text("Không có danh mục nào!"),
      //             );
      //           }
      //           return ListView(
      //             children: _categoryController.categoryList.map((category) {
      //               return ListTile(
      //                 trailing: IconButton(
      //                   icon: const Icon(Icons.delete, color: Colors.red),
      //                   onPressed: () {
      //                     _categoryController.deleteCategory(category.id);
      //                   },
      //                 ),
      //                 leading: Container(
      //                   width: 32,
      //                   height: 32,
      //                   decoration: BoxDecoration(
      //                     // color: category.color.withOpacity(0.1),
      //                     color: category.color,
      //                     borderRadius: BorderRadius.circular(50),
      //                     // border: Border.all(
      //                     //   color: category.color.withOpacity(0.3),
      //                     //   width: 1,
      //                     // ),
      //                   ),
      //                   child: Icon(
      //                     category.icon,
      //                     color: Colors.white,
      //                     size: 20,
      //                   ),
      //                 ),
      //                 title: Text(
      //                   category.title,
      //                   style: const TextStyle(
      //                     fontWeight: FontWeight.w500,
      //                     fontSize: 16,
      //                   ),
      //                 ),
      //                 // tileColor: category.color.withOpacity(0.1),
      //                 onTap: () {
      //                   openCategory(category);
      //                   Navigator.of(context).pop(); // đóng drawer
      //                 },
      //               );
      //             }).toList(),
      //           );
      //         }),
      //       ),

      //       // ➕ Nút thêm category ở dưới cùng bên trái
      //       Align(
      //         alignment: Alignment.bottomLeft,
      //         child: Padding(
      //           padding: const EdgeInsets.all(16.0),
      //           child: IconButton(
      //             onPressed: _showNewListBottomSheet,
      //             style: IconButton.styleFrom(
      //               backgroundColor: Colors.amber,
      //               shape: RoundedRectangleBorder(
      //                 borderRadius: BorderRadius.circular(8),
      //               ),
      //             ),
      //             icon: const Icon(
      //               Icons.add,
      //               color: Colors.white,
      //             ),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
      // bottomNavigationBar:
      // Stack(
      //   clipBehavior: Clip.none,
      //   alignment: Alignment.bottomCenter,
      //   children: [
      //     BottomNavigationBar(
      //       backgroundColor: AppColors.secondary,
      //       currentIndex: selectedIndex,
      //       unselectedItemColor: AppColors.white,
      //       selectedItemColor: AppColors.primary,
      //       showSelectedLabels: true,
      //       type: BottomNavigationBarType.fixed,
      //       onTap: (int index) {
      //         if (index == 2) return; // Giữ vị trí giữa không bấm
      //         setState(() {
      //           selectedIndex = index;
      //           selectedCategory = null; // reset khi chuyển tab khác
      //         });
      //       },
      //       items: const [
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.home),
      //           label: "Home",
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.calendar_today),
      //           label: "Calendar",
      //         ),
      //         BottomNavigationBarItem(
      //           icon: SizedBox.shrink(), // giữ chỗ cho nút giữa
      //           label: "",
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.grid_view),
      //           label: "Grid",
      //         ),
      //         BottomNavigationBarItem(
      //           icon: Icon(Icons.settings),
      //           label: "Setting",
      //         ),
      //       ],
      //     ),
      //     Positioned(
      //       bottom: 20, // chỉnh lên xuống của nút
      //       child: GestureDetector(
      //         onTap: () {
      //           // hành động khi bấm nút
      //           print("Middle button tapped");
      //         },
      //         child: Container(
      //           height: 60,
      //           width: 60,
      //           decoration: BoxDecoration(
      //             color: AppColors.primary,
      //             shape: BoxShape.circle,
      //             border: Border.all(color: Colors.white, width: 4), // viền
      //             boxShadow: [
      //               BoxShadow(
      //                 color: Colors.black26,
      //                 blurRadius: 8,
      //                 offset: Offset(0, 4),
      //               ),
      //             ],
      //           ),
      //           child: Icon(
      //             Icons.add,
      //             color: Colors.white,
      //             size: 30,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}
