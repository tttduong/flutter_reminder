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
          backgroundColor: Colors.white.withOpacity(0.3),
          // backgroundColor: Colors.white, // Màu trắng mờ
          // backgroundColor: Colors.transparent,
          elevation: 0,
          // currentIndex: currentIndex,
          currentIndex: displayIndex,
          unselectedItemColor: Colors.grey.withOpacity(0.4),
          selectedItemColor: AppColors.primary,
          showSelectedLabels: true,
          type: BottomNavigationBarType.fixed,
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
    // // Floating Action Button - Di chuyển ra ngoài
    //               const SizedBox(height: 40),
    //               Center(
    //                 child: Container(
    //                   width: 56,
    //                   height: 56,
    //                   decoration: BoxDecoration(
    //                     gradient: const LinearGradient(
    //                       begin: Alignment.topLeft,
    //                       end: Alignment.bottomRight,
    //                       colors: [
    //                         Color(0xFF113355),
    //                         Color(0xFF7B4BFF),
    //                         Color(0xFF575DFB),
    //                       ],
    //                       stops: [0.0, 0.87, 1.0],
    //                     ),
    //                     borderRadius: BorderRadius.circular(28),
    //                     boxShadow: [
    //                       BoxShadow(
    //                         color: Colors.indigo.withOpacity(0.3),
    //                         blurRadius: 12,
    //                         offset: const Offset(0, 4),
    //                       ),
    //                     ],
    //                   ),
    //                   child: Material(
    //                     color: Colors.transparent,
    //                     child: InkWell(
    //                       borderRadius: BorderRadius.circular(28),
    //                       onTap: () => _handleAddCategoryTap(),
    //                       child: const Icon(
    //                         Icons.add,
    //                         color: Colors.white,
    //                         size: 32,
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ),

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF113355),
            Color(0xFF7B4BFF),
            Color(0xFF575DFB),
          ],
          stops: [0.0, 0.87, 1.0],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.background, width: 4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onMiddleButtonTap,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
      // child: Material(
      //   color: Colors.transparent,
      //   child: InkWell(
      //     borderRadius: BorderRadius.circular(30),
      //     onTap: onMiddleButtonTap,
      //     child: Container(
      //       height: 60,
      //       width: 60,
      //       decoration: BoxDecoration(
      //         color: AppColors.primary,
      //         shape: BoxShape.circle,
      //         border: Border.all(color: AppColors.background, width: 4),
      //       ),
      //       child: const Icon(
      //         Icons.add,
      //         color: Colors.white,
      //         size: 30,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
