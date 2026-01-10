// lib/ui/widgets/chat/chat_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:get/get.dart';

class ChatDrawer extends StatelessWidget {
  final ChatPageController controller;

  const ChatDrawer({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildConversationList()),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: AppColors.primary.withOpacity(0.6),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.primary.withOpacity(0.7),
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.secondary.withOpacity(0.2),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),

          // New conversation button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                controller.startNewConversation();
                Navigator.pop(context); // Close drawer
              },
              icon: const Icon(
                Icons.add,
                color: AppColors.primary,
                size: 22,
              ),
              label: const Text(
                'New conversation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return Obx(() {
      if (controller.convController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final conversations = controller.conversations;

      if (conversations.isEmpty) {
        return Center(
          child: Text(
            'No conversations yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final convo = conversations[index];
          final isSelected = convo.id.toString() == controller.conversationId;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            dense: true,
            selected: isSelected,
            selectedTileColor: AppColors.secondary.withOpacity(0.15),
            title: Text(
              convo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
            subtitle: convo.lastMessage != null
                ? Text(
                    convo.lastMessage!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            onTap: () async {
              Navigator.pop(context); // Close drawer
              await controller.switchConversation(convo.id);
            },
          );
        },
      );
    });
  }
}
