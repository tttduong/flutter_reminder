import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/ui/screens/category_tasks.dart';
import 'package:flutter_to_do_app/ui/screens/screens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_to_do_app/data/services/local_store_services.dart';

import '../../providers/user_provider.dart';
import 'add_list.dart';

class BottomNavBarScreen extends StatefulWidget {
  final Category? initialCategory;
  // const BottomNavBarScreen({super.key});

  const BottomNavBarScreen({super.key, this.initialCategory});
  @override
  State<BottomNavBarScreen> createState() => BottomNavBarScreenState();
}

class BottomNavBarScreenState extends State<BottomNavBarScreen> {
  int selectedIndex = 0;
  Category? selectedCategory; // 👈 Thêm biến để giữ category đang chọn
  final _categoryController = Get.put(CategoryController());
  @override
  void initState() {
    super.initState();
    print("🔥 initState - initialCategory: ${widget.initialCategory?.id}");
    selectedCategory = widget.initialCategory;
  }

  void openCategory(Category category) {
    setState(() {
      selectedCategory = category;
      selectedIndex = 0; // chuyển về HomePage
    });
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
    });
  }

  Widget _getCurrentScreen() {
    // print("Current selected Category: "{$selectedCategor});
    switch (selectedIndex) {
      case 0:
        if (selectedCategory != null) {
          return CategoryTasksPage(category: selectedCategory!);
        } else {
          return ChatPage();
        }

      // return const HomePage();
      case 1:
        return CalendarTasks();
      case 2:
        return const SignInPage();
      case 3:
        return const ChatPage();
      default:
        return const HomePage();
    }
  }
  // Widget _getCurrentScreen() {
  //   return Obx(() {
  //     final category = _categoryController.selectedCategory.value;

  //     switch (selectedIndex) {
  //       case 0:
  //         if (category != null) {
  //           return CategoryTasksPage(category: category);
  //         } else {
  //           return ChatPage();
  //         }
  //       case 1:
  //         return CalendarTasks();
  //       case 2:
  //         return const SignInPage();
  //       case 3:
  //         return const ChatPage();
  //       default:
  //         return const HomePage();
  //     }
  //   });
  // }

  void _logOut() async {
    bool removeSuccess = await LocalStoreServices.removeFromLocal(context);
    if (removeSuccess) {
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUserNull();
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: _getCurrentScreen(),
  //     bottomNavigationBar: BottomNavigationBar(
  //       currentIndex: selectedIndex,
  //       unselectedItemColor: Colors.grey,
  //       selectedItemColor: Colors.green,
  //       showSelectedLabels: true,
  //       type: BottomNavigationBarType.fixed,
  //       onTap: (int index) {
  //         setState(() {
  //           selectedIndex = index;
  //           selectedCategory = null; // reset khi chuyển tab khác
  //         });
  //       },
  //       items: const [
  //         BottomNavigationBarItem(
  //             icon: Icon(FontAwesomeIcons.shekelSign), label: "Inbox"),
  //         BottomNavigationBarItem(
  //             icon: Icon(FontAwesomeIcons.checkToSlot), label: "Tasks"),
  //         BottomNavigationBarItem(
  //             icon: Icon(FontAwesomeIcons.circleXmark), label: "Cancelled"),
  //         BottomNavigationBarItem(
  //             icon: Icon(FontAwesomeIcons.barsProgress), label: "Chatbox"),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 🔒 Nút đăng nhập / tên người dùng
            Padding(
                padding: const EdgeInsets.only(top: 20, left: 10),
                child: Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                  final user = userProvider.user;
                  final userName = user?.username;
                  print("Full user: ${user?.toJson()}");

                  return ElevatedButton.icon(
                    onPressed: () {
                      if (userName == null) {
                        Get.to(() => const SignInPage());
                      } else {
                        // Mở profile hoặc popup đăng xuất nếu muốn
                        _logOut();
                      }
                    },
                    icon: Icon(userName == null ? Icons.login : Icons.person),
                    label: Text(userName == null ? "Log In" : "Log Out"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 168, 182, 151),
                      foregroundColor: Colors.white,
                    ),
                  );
                })),

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
                        openCategory(category);
                        Navigator.of(context).pop(); // đóng drawer
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
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.green,
        showSelectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
            selectedCategory = null; // reset khi chuyển tab khác
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.shekelSign), label: "Inbox"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.checkToSlot), label: "Tasks"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.circleXmark), label: "Cancelled"),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.barsProgress), label: "Chatbox"),
        ],
      ),
    );
  }
}
// }
