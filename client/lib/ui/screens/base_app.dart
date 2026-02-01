// 1. Base App Screen Widget
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/controller/category_controller.dart';
import 'package:flutter_to_do_app/controller/task_controller.dart';
import 'package:flutter_to_do_app/data/models/category.dart';
import 'package:flutter_to_do_app/data/models/task.dart';
import 'package:flutter_to_do_app/ui/screens/add_list.dart';
import 'package:flutter_to_do_app/ui/screens/bottom_navbar_screen.dart';
import 'package:flutter_to_do_app/ui/widgets/appbar.dart';
import 'package:flutter_to_do_app/ui/widgets/gradient_bg.dart';
import 'package:flutter_to_do_app/ui/widgets/sidebar.dart';
import 'package:get/get.dart';

class BaseAppScreen extends StatefulWidget {
  final Widget body;
  final String? title;
  final bool showAppBar;
  final bool showDrawer;
  final bool showSearchBar;
  final String searchHint;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final ValueChanged<bool>? onDrawerChanged;
  final PreferredSizeWidget? appBar;
  const BaseAppScreen({
    Key? key,
    required this.body,
    this.title,
    this.showAppBar = true,
    this.showDrawer = true,
    this.showSearchBar = false,
    this.searchHint = 'Search...',
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.onDrawerChanged,
    this.appBar,
  }) : super(key: key);

  @override
  State<BaseAppScreen> createState() => _BaseAppScreenState();
}

class _BaseAppScreenState extends State<BaseAppScreen> {
  final CategoryController _categoryController = Get.find();

  // 📂 Category handlers
  void _handleCategoryTap(Category category) {
    BottomNavBarScreenState.navigateToCategoryFromAnywhere(category);
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }
  }

  void _handleAddCategoryTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewListBottomSheet(),
    );
  }

  // 🔍 Search và AppBar handlers
  void _handleSearchChanged(String query) {
    print("Search query: $query");
  }

  void _handleNotificationTap() {
    print("Notification tapped");
  }

  void _handleMoreTap() {
    print("More options tapped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(child: widget.body),
        ],
      ),
    );
  }
}
