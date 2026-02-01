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
                            conversationId: null,
                          )),
                );
              },
          backgroundColor: AppColors.primary,
          elevation: 6,
          shape: const CircleBorder(),
          child: const Icon(Icons.chat_bubble_outline_rounded,
              color: Colors.white),
        ),
      ],
    );
  }
}
