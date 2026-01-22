// lib/ui/widgets/chat/chat_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:get/get.dart';

class ChatDrawer extends StatefulWidget {
  final ChatPageController controller;

  const ChatDrawer({super.key, required this.controller});

  @override
  State<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends State<ChatDrawer> {
  @override
  void initState() {
    super.initState();
    // ✅ Load conversations khi drawer được khởi tạo
    widget.controller.convController.fetchConversations();
  }

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
          // Search field with SOON badge
          Stack(
            children: [
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
                enabled: false, // Disable vì chưa có chức năng
              ),
              Positioned(
                top: 2,
                right: 2,
                child: Transform.rotate(
                  angle: 0.6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
              ),
            ],
          ),

          // New conversation button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                widget.controller.startNewConversation();
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
      if (widget.controller.convController.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final conversations = widget.controller.conversations;

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
          final isSelected =
              convo.id.toString() == widget.controller.conversationId;

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
              await widget.controller.switchConversation(convo.id);
            },
          );
        },
      );
    });
  }
}
