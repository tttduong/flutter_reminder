import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/ui/screens/chat.dart';
import 'package:get/get.dart';

class ChatFloatingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showBadge;
  final int unreadCount;

  const ChatFloatingButton({
    super.key,
    this.onPressed,
    this.showBadge = false,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          onPressed: onPressed ??
              () {
                // Mặc định: điều hướng sang màn hình chat
                // Get.toNamed('/chat');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChatPage(
                            conversationId: 5,
                          )),
                );
              },
          backgroundColor: AppColors.primary,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white),
        ),

        // Hiển thị badge thông báo nếu có tin nhắn chưa đọc
        // if (showBadge && unreadCount > 0)
        //   Positioned(
        //     right: -2,
        //     top: -2,
        // child: Container(
        //   padding: const EdgeInsets.all(5),
        //   decoration: const BoxDecoration(
        //     color: Colors.redAccent,
        //     shape: BoxShape.circle,
        //   ),
        //   constraints: const BoxConstraints(
        //     minWidth: 22,
        //     minHeight: 22,
        //   ),
        // child: Center(
        //   child: Text(
        //     unreadCount > 99 ? '99+' : '$unreadCount',
        //     style: const TextStyle(
        //       color: Colors.white,
        //       fontSize: 11,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        // ),
        // ),
      ],
    );
  }
}
