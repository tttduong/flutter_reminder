// lib/ui/widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/ui/widgets/my_chat_message.dart';
import 'package:flutter_to_do_app/ui/widgets/schedule_card.dart';

class MessageBubble extends StatelessWidget {
  final MyChatMessage message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final scheduleDraft = message.customProperties?["schedule_draft"];

    // Kiểm tra có schedule draft hợp lệ không
    if (scheduleDraft != null && _hasValidSchedule(scheduleDraft)) {
      return ScheduleCard(
        messageText: message.text,
        isCurrentUser: isCurrentUser,
        scheduleDraft: scheduleDraft,
        conversationId: message.conversationId,
      );
    }

    // Text thông thường
    return Text(
      message.text,
      style: TextStyle(
        color: isCurrentUser ? Colors.white : Colors.black,
      ),
    );
  }

  bool _hasValidSchedule(dynamic scheduleDraft) {
    if (scheduleDraft is! Map<String, dynamic>) return false;

    // Format có schedule_title + days
    if (scheduleDraft.containsKey('schedule_title') &&
        scheduleDraft.containsKey('days') &&
        scheduleDraft['days'] is List &&
        (scheduleDraft['schedule_title']?.toString().isNotEmpty ?? false)) {
      return true;
    }

    // Format date-based
    final entries = scheduleDraft.entries
        .where((e) => e.value is List && (e.value as List).isNotEmpty)
        .toList();

    return entries.isNotEmpty;
  }
}
