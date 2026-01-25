import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:flutter_to_do_app/controller/conversation_controller.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_drawer.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_input_field.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_message_list.dart';
import 'package:flutter_to_do_app/ui/widgets/mode_selector_bottom_sheet.dart';
import 'package:get/get.dart';

// class ChatPage extends StatelessWidget {
//   final String? conversationId;

//   const ChatPage({super.key, this.conversationId});

//   @override
//   Widget build(BuildContext context) {
//     // ✅ Put ConversationController trước
//     Get.put(ConversationController());
//     // ✅ Initialize controller
//     final controller = Get.put(ChatPageController());

//     // ✅ Load messages nếu có conversationId
//     if (conversationId != null) {
//       controller.convController.setConversation(conversationId!, false);
//       controller.loadMessages();
//     }

//     return Scaffold(
//       appBar: _buildAppBar(controller),
//       drawer: ChatDrawer(controller: controller),
//       body: Column(
//         children: [
//           // Messages
//           Expanded(
//             child: Obx(() => ChatMessageList(
//                   messages: controller.messages,
//                   isLoading: controller.isLoading.value,
//                   currentUser: controller.currentUser,
//                   gptUser: controller.gptChatUser,
//                 )),
//           ),

//           // Input field
//           ChatInputField(
//             onSend: controller.sendMessage,
//             onModeSelect: () => _showModeSelector(context, controller),
//           ),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(ChatPageController controller) {
//     return AppBar(
//       leading: Builder(
//         builder: (context) => IconButton(
//           icon: const Icon(Icons.menu, color: AppColors.primary),
//           onPressed: () => Scaffold.of(context).openDrawer(),
//         ),
//       ),
//       backgroundColor: AppColors.background,
//       title: Obx(() => Text(
//             controller.isNewConversation ? "New Chat" : "Lumiere",
//             style: const TextStyle(
//               color: AppColors.primary,
//               fontWeight: FontWeight.w600,
//             ),
//           )),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.close_rounded, color: AppColors.primary),
//           onPressed: () => Get.back(),
//         ),
//       ],
//     );
//   }

//   void _showModeSelector(BuildContext context, ChatPageController controller) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (_) => ModeSelectorBottomSheet(controller: controller),
//     );
//   }
// }

class ChatPage extends StatefulWidget {
  final String? conversationId;

  const ChatPage({super.key, this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatPageController controller;

  @override
  void initState() {
    super.initState();

    // ✅ Initialize controllers
    Get.put(ConversationController());
    controller = Get.put(ChatPageController());

    // ✅ Setup sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupInitialState();
    });
  }

  void _setupInitialState() {
    if (widget.conversationId != null) {
      // 1️⃣ Có conversationId → load conversation thật
      controller.convController.setConversation(widget.conversationId!, false);
      controller.loadMessages();
    } else {
      // 2️⃣ Không có conversationId → draft mode
      controller.convController.resetToNewConversation();
      controller.messages.clear();
      controller.isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: ChatDrawer(controller: controller),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() {
              // ✅ Hiển thị empty state khi draft mode
              if (controller.convController.isDraftMode.value &&
                  controller.messages.isEmpty) {
                return _buildEmptyState();
              }

              return ChatMessageList(
                messages: controller.messages,
                isLoading: controller.isLoading.value,
                currentUser: controller.currentUser,
                gptUser: controller.gptChatUser,
              );
            }),
          ),

          // Input field
          // ChatInputField(
          //   onSend: controller.sendMessage,
          //   onModeSelect: () => _showModeSelector(context),
          // ),
          // Trong ChatPage widget
          Obx(() => ChatInputField(
                onSend: controller.sendMessage,
                onModeSelect: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) =>
                        ModeSelectorBottomSheet(controller: controller),
                  );
                },
                currentMode:
                    controller.selectedMode.value, // Truyền mode hiện tại
              ))
        ],
      ),
    );
  }

  // ✅ Empty state widget cho draft mode
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Start a new conversation',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      backgroundColor: AppColors.background,
      title: Obx(() => Text(
            controller.convController.isDraftMode.value
                ? "Lumiere" // ✅ Draft mode
                : "Lumiere", // ✅ Conversation mode
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          )),
      actions: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primary),
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  void _showModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ModeSelectorBottomSheet(controller: controller),
    );
  }
}
