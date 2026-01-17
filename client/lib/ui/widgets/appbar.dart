// widgets/appbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMoreTap;
  final bool showSearchBar;
  final String? searchHint;
  final Function(String)? onSearchChanged;

  const CustomAppBar({
    Key? key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onMoreTap,
    this.showSearchBar = false,
    this.searchHint = 'Search',
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          // onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
          onPressed: onMenuTap,
          // onPressed: () => Scaffold.of(context).openDrawer()
        ),
      ),

      // Search bar (optional)
      title: showSearchBar ? _buildSearchBar() : null,

      // actions: [
      //   IconButton(
      //     icon: const Icon(Icons.notifications, color: AppColors.primary),
      //     onPressed: onNotificationTap ?? () {},
      //   ),
      //   IconButton(
      //     icon: const Icon(Icons.more_vert, color: AppColors.primary),
      //     onPressed: onMoreTap ?? () {},
      //   ),
      //   const SizedBox(width: 8),
      // ],
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: AppColors.primary),
              onPressed: onNotificationTap ?? () {},
            ),
            _soonBadge(),
          ],
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onPressed: onMoreTap ?? () {},
            ),
            _soonBadge(),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _soonBadge() {
    return Positioned(
      top: 2,
      right: 2,
      child: Transform.rotate(
        angle: 0.6, // chéo nhẹ
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'SOON',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: TextStyle(
            color: AppColors.primary.withOpacity(0.6),
            fontSize: 14,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary.withOpacity(0.7),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
        ),
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Custom App Bar với title
class CustomAppBarWithTitle extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onMoreTap;
  final List<Widget>? customActions;
  final Widget? leading;
  final bool centerTitle;

  const CustomAppBarWithTitle({
    Key? key,
    required this.title,
    this.onMenuTap,
    this.onNotificationTap,
    this.onMoreTap,
    this.customActions,
    this.leading,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading ??
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
            ),
          ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: customActions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications, color: AppColors.primary),
              onPressed: onNotificationTap ?? () {},
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.more_vert, color: AppColors.primary),
              onPressed: onMoreTap ?? () {},
            ),
            const SizedBox(width: 8),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
