import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/ui/screens/add_list.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
import 'package:flutter_to_do_app/ui/screens/chat.dart';
import 'package:flutter_to_do_app/ui/widgets/appbar.dart';
import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

// class HomePage extends StatelessWidget {
//   final Category? initialCategory;
//   const HomePage({super.key, this.initialCategory});

// // 🔍 Search handler
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: CustomAppBar(
//         showSearchBar: false, // Set true nếu muốn hiện search bar
//         searchHint: 'Search tasks...',
//         onSearchChanged: _handleSearchChanged,
//         onNotificationTap: _handleNotificationTap,
//         onMoreTap: _handleMoreTap,
//       ),
//       // 🗂️ Custom Sidebar/Drawer
//       drawer: CustomSidebar(
//         categoryController: _categoryController,
//         onCategoryTap: _handleCategoryTap,
//         onAddCategoryTap: _handleAddCategoryTap,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header greeting
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
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.black87,
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Horizontal menu
//               SizedBox(
//                 height: 100,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _buildCard("Chatbot", Icons.chat_bubble, onTap: () {
//                       print("Chatbot tapped!");
//                       Navigator.push(context,
//                           MaterialPageRoute(builder: (_) => ChatPage()));
//                     }),
//                     _buildCard("Report", Icons.bar_chart_outlined),
//                     _buildCard("Habit", Icons.track_changes),
//                     _buildCard("Chatbot", Icons.chat_bubble_outline),
//                     _buildCard("Chatbot", Icons.chat_bubble_outline),
//                     _buildCard("Chatbot", Icons.chat_bubble_outline),
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
//           // boxShadow: [
//           //   BoxShadow(
//           //     color: Colors.black12,
//           //     blurRadius: 6,
//           //     offset: Offset(0, 3),
//           //   ),
//           // ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 36, color: Colors.cyan),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class HomePage extends StatelessWidget {
  final Category? initialCategory;
  final CategoryController _categoryController = Get.put(CategoryController());

  HomePage({super.key, this.initialCategory});

  // 📂 Category handlers
  void _handleCategoryTap(BuildContext context, Category category) {
    // Gọi thẳng xuống BottomNavBarScreen
    BottomNavBarScreenState.navigateToCategoryFromAnywhere(category);
    Navigator.of(context).pop(); // đóng drawer
  }

  void _handleAddCategoryTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewListBottomSheet(),
    );
  }

  // 🔍 Search handler
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
      backgroundColor: Colors.grey[100],
      // appBar: CustomAppBar(
      //   showSearchBar: false,
      //   searchHint: 'Search tasks...',
      //   onSearchChanged: _handleSearchChanged,
      //   onNotificationTap: _handleNotificationTap,
      //   onMoreTap: _handleMoreTap,
      // ),
      // drawer: CustomSidebar(
      //   categoryController: _categoryController,
      //   onCategoryTap: (cat) => _handleCategoryTap(context, cat),
      //   onAddCategoryTap: () => _handleAddCategoryTap(context),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text(
                "Good morning!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Believe in yourself; today is yours to conquer!",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 24),

              // Horizontal menu
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCard("Chatbot", Icons.chat_bubble, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      );
                    }),
                    _buildCard("Report", Icons.bar_chart_outlined),
                    _buildCard("Habit", Icons.track_changes),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Today progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Text(
                    "4/8",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 4 / 8,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
                color: AppColors.primary,
                backgroundColor: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.cyan),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
