import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:flutter_to_do_app/controller/conversation_controller.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_drawer.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_input_field.dart';
import 'package:flutter_to_do_app/ui/widgets/chat_message_list.dart';
import 'package:flutter_to_do_app/ui/widgets/mode_selector_bottom_sheet.dart';
import 'package:get/get.dart';

class ChatPage extends StatelessWidget {
  final String? conversationId;

  const ChatPage({super.key, this.conversationId});

  @override
  Widget build(BuildContext context) {
    // ✅ Put ConversationController trước
    Get.put(ConversationController());
    // ✅ Initialize controller
    final controller = Get.put(ChatPageController());

    // ✅ Load messages nếu có conversationId
    if (conversationId != null) {
      controller.convController.setConversation(conversationId!, false);
      controller.loadMessages();
    }

    return Scaffold(
      appBar: _buildAppBar(controller),
      drawer: ChatDrawer(controller: controller),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Obx(() => ChatMessageList(
                  messages: controller.messages,
                  isLoading: controller.isLoading.value,
                  currentUser: controller.currentUser,
                  gptUser: controller.gptChatUser,
                )),
          ),

          // Input field
          ChatInputField(
            onSend: controller.sendMessage,
            onModeSelect: () => _showModeSelector(context, controller),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatPageController controller) {
    return AppBar(
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      backgroundColor: AppColors.background,
      title: Obx(() => Text(
            controller.isNewConversation ? "New Chat" : "Lumiere",
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

  void _showModeSelector(BuildContext context, ChatPageController controller) {
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
