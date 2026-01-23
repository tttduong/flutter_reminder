// lib/ui/widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/ui/widgets/my_chat_message.dart';
import 'package:flutter_to_do_app/ui/widgets/schedule_card.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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

    // 1️⃣ Schedule card (ưu tiên cao nhất)
    if (scheduleDraft != null && _hasValidSchedule(scheduleDraft)) {
      return ScheduleCard(
        messageText: message.text,
        isCurrentUser: isCurrentUser,
        scheduleDraft: scheduleDraft,
        conversationId: message.conversationId,
      );
    }

    // 2️⃣ Markdown message
    if (message.isMarkdown) {
      return _buildMarkdown();
    }

    // 3️⃣ Plain text
    return Text(
      message.text,
      style: TextStyle(
        color: isCurrentUser ? Colors.white : Colors.black,
        fontSize: 15,
      ),
    );
  }

  Widget _buildMarkdown() {
    return MarkdownBody(
      data: message.text,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          fontSize: 15,
          color: isCurrentUser ? Colors.white : Colors.black87,
          height: 1.45,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.w700,
          color: isCurrentUser ? Colors.white : Colors.black,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
        ),
        code: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          backgroundColor:
              isCurrentUser ? Colors.white.withOpacity(0.15) : Colors.black12,
        ),
        codeblockDecoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.black.withOpacity(0.25)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        listBullet: TextStyle(
          color: isCurrentUser ? Colors.white : Colors.black,
        ),
        blockquoteDecoration: BoxDecoration(
          color: isCurrentUser
              ? Colors.white.withOpacity(0.08)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  bool _hasValidSchedule(dynamic scheduleDraft) {
    if (scheduleDraft is! Map<String, dynamic>) return false;

    // 1️⃣ Format có schedule_title + days (days PHẢI có phần tử)
    if (scheduleDraft.containsKey('schedule_title') &&
        scheduleDraft.containsKey('days') &&
        scheduleDraft['days'] is List &&
        (scheduleDraft['days'] as List).isNotEmpty &&
        (scheduleDraft['schedule_title']?.toString().isNotEmpty ?? false)) {
      return true;
    }

    // 2️⃣ Format date-based (giữ nguyên)
    final entries = scheduleDraft.entries
        .where((e) => e.value is List && (e.value as List).isNotEmpty)
        .toList();

    return entries.isNotEmpty;
  }
}
