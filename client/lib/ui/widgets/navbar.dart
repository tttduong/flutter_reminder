import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onMiddleButtonTap;

  const Navbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.onMiddleButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // int displayIndex = currentIndex > 5 ? -1 : currentIndex;
    // Đảm bảo displayIndex không vượt quá range của navbar
    int displayIndex = currentIndex;
    if (displayIndex < 0 || displayIndex > 4) {
      displayIndex = -1; // Không highlight tab nào
    }
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Bottom Navigation Bar
        BottomNavigationBar(
          backgroundColor: AppColors.secondary,
          // currentIndex: currentIndex,
          currentIndex: displayIndex,
          unselectedItemColor: AppColors.white,
          selectedItemColor: AppColors.primary,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          onTap: (int index) {
            print("🔘 Navbar onTap called with index: $index");
            if (index == 2) return; // Giữ vị trí giữa không bấm
            onTap(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 30,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: SizedBox.shrink(), // giữ chỗ cho nút giữa
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view),
              label: "Grid",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Setting",
            ),
          ],
        ),

        // Floating Action Button ở giữa
        Positioned(
          bottom: 20,
          child: _buildFloatingActionButton(),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onMiddleButtonTap,
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 4),
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
