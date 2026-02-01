import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/ui/widgets/message_bubble.dart';
import 'package:flutter_to_do_app/ui/widgets/my_chat_message.dart';
import 'package:flutter_to_do_app/ui/widgets/typing_indicator.dart';
import 'package:dash_chat_2/dash_chat_2.dart';

class ChatMessageList extends StatelessWidget {
  final List<MyChatMessage> messages;
  final bool isLoading;
  final ChatUser currentUser;
  final ChatUser gptUser;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.currentUser,
    required this.gptUser,
  });

  @override
  Widget build(BuildContext context) {
    // Empty state
    if (messages.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    // Messages list
    return ListView.builder(
      reverse: true, // Tin nhắn mới nhất ở dưới
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Typing indicator
        if (isLoading && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40,
                  height: 24,
                  child: TypingIndicatorCustom(),
                ),
              ],
            ),
          );
        }

        // Message bubble
        final messageIndex = isLoading ? index - 1 : index;
        final message = messages[messageIndex];

        return MessageBubble(
          message: message,
          isCurrentUser: message.user.id == currentUser.id,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Start a conversation with Lumiere',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
