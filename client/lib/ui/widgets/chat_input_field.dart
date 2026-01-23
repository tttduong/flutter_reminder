// lib/ui/widgets/chat/chat_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';

class ChatInputField extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback onModeSelect;
  final String currentMode;

  const ChatInputField({
    super.key,
    required this.onSend,
    required this.onModeSelect,
    required this.currentMode,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isGeneratePlanMode = widget.currentMode == "generate_plan";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Mode selector button
          GestureDetector(
            onTap: widget.onModeSelect,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGeneratePlanMode
                    ? AppColors.primary.withOpacity(0.9)
                    : AppColors.primary,
              ),
              child: Icon(
                isGeneratePlanMode ? Icons.calendar_today : Icons.add,
                color: Colors.white,
                size: isGeneratePlanMode ? 20 : 24,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text input
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
              decoration: InputDecoration(
                prefixIcon: isGeneratePlanMode
                    ? Icon(
                        Icons.event_note,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                hintText: isGeneratePlanMode ? 'Describe your plan...' : 'Aa',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: isGeneratePlanMode ? 14 : 16,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isGeneratePlanMode
                        ? AppColors.primary
                        : Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: isGeneratePlanMode
                        ? AppColors.primary
                        : Colors.grey[300]!,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: isGeneratePlanMode ? 2.0 : 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isGeneratePlanMode ? 12 : 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isGeneratePlanMode
                    ? AppColors.primary.withOpacity(0.9)
                    : AppColors.primary,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
