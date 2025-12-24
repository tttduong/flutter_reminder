import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:flutter_to_do_app/controller/conversation_controller.dart';
import 'package:flutter_to_do_app/data/models/conversation.dart';
import 'package:flutter_to_do_app/data/models/task_intent_response.dart';
import 'package:flutter_to_do_app/data/services/category_service.dart';
import 'package:flutter_to_do_app/data/services/conversation_service.dart';
import 'package:flutter_to_do_app/ui/widgets/my_chat_message.dart';
import 'package:flutter_to_do_app/ui/widgets/typing_indicator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ChatPage extends StatefulWidget {
  final String conversationId;
  const ChatPage({super.key, required this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Duong', lastName: 'Thuy');
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Lumiere', lastName: '');
  List<MyChatMessage> _messages = [];
  bool isLoading = false;
  List<Map<String, String>> _conversationHistory = [];
  List<TaskIntentResponse> _lastTaskIntents = [];
  final uuid = Uuid();

  List<Conversation> _conversations = [];
  String _selectedConversationId = '1';

  final ConversationController convController =
      Get.put(ConversationController());

  List<dynamic> messages = [];
  late TextEditingController _textController;

  String _selectedMode = "normal"; //"generate_plan" / "normal"

  String? _lastCreatedCategoryId;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    convController.fetchConversations();
    _loadMessages();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data =
          await ConversationService.fetchMessages(widget.conversationId);

      List<MyChatMessage> loadedMessages = [];

      for (var msg in data) {
        ChatUser messageUser;
        if (msg['role'] == 'user') {
          messageUser = _currentUser;
        } else if (msg['role'] == 'assistant') {
          messageUser = _gptChatUser;
        } else {
          continue;
        }
        final customProps =
            msg['custom_properties'] as Map<String, dynamic>? ?? {};
        final scheduleDraft =
            customProps['schedule_draft'] as Map<String, dynamic>?;
        loadedMessages.add(
          MyChatMessage(
            conversationId: _selectedConversationId,
            text: msg['content'] ?? '',
            user: messageUser,
            createdAt: msg['created_at'] != null
                ? DateTime.parse(msg['created_at'])
                : DateTime.now(),
            customProperties: customProps,
            scheduleDraft: scheduleDraft,
          ),
        );

        _conversationHistory.add({
          "role": msg['role'],
          "content": msg['content'] ?? '',
        });
      }

      setState(() {
        _messages = loadedMessages.reversed.toList();
        messages = data;
        isLoading = false;
      });

      print("✅ Loaded ${_messages.length} messages successfully");
    } catch (e) {
      print("❌ Error loading messages: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMessagesForConversation(String conversationId) async {
    setState(() {
      isLoading = true;
      _messages = [];
      _conversationHistory = [];
    });

    try {
      final data = await ConversationService.fetchMessages(conversationId);

      List<MyChatMessage> loadedMessages = [];

      for (var msg in data) {
        ChatUser messageUser;
        if (msg['role'] == 'user') {
          messageUser = _currentUser;
        } else if (msg['role'] == 'assistant') {
          messageUser = _gptChatUser;
        } else {
          continue;
        }
// ✅ Extract scheduleDraft từ custom_properties
        final customProps =
            msg['custom_properties'] as Map<String, dynamic>? ?? {};
        final scheduleDraft =
            customProps['schedule_draft'] as Map<String, dynamic>?;
        loadedMessages.add(
          MyChatMessage(
            conversationId: _selectedConversationId,
            text: msg['content'] ?? '',
            user: messageUser,
            createdAt: msg['created_at'] != null
                ? DateTime.parse(msg['created_at'])
                : DateTime.now(),
            customProperties: customProps,
            scheduleDraft: scheduleDraft,
          ),
        );

        _conversationHistory.add({
          "role": msg['role'],
          "content": msg['content'] ?? '',
        });
      }

      setState(() {
        _messages = loadedMessages.reversed.toList();
        messages = data;
        isLoading = false;
      });

      print(
          "✅ Loaded ${_messages.length} messages for conversation $conversationId");
    } catch (e) {
      print("❌ Error loading messages for conversation $conversationId: $e");
      setState(() {
        isLoading = false;
      });

      Get.snackbar(
        'Error',
        'Failed to load conversation messages',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("🎯 ChatPage build() called");
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, color: AppColors.primary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                print("open chat drawer");
              },
            ),
          ),
          backgroundColor: AppColors.background,
          title: const Text(
            "Lumiere",
            style: TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.primary),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
        drawer: Drawer(
          width: 280,
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
                  child: Column(
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
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final newId = uuid.v4();
                              _conversations.insert(
                                0,
                                Conversation(
                                  id: newId,
                                  title: 'New conversation',
                                  lastMessage: 'Bắt đầu trò chuyện với Lumiere',
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                ),
                              );
                              _selectedConversationId = newId;
                            });
                            Navigator.pop(context);
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
                ),
                Expanded(
                  child: Obx(() {
                    if (convController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: convController.conversations.length,
                      itemBuilder: (context, index) {
                        final convo = convController.conversations[index];
                        final isSelected =
                            convo.id.toString() == _selectedConversationId;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          dense: true,
                          selected: isSelected,
                          selectedTileColor:
                              AppColors.secondary.withOpacity(0.15),
                          title: Text(
                            convo.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: convo.lastMessage != null
                              ? Text(
                                  convo.lastMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          onTap: () async {
                            setState(() {
                              _selectedConversationId = convo.id.toString();
                            });
                            Navigator.pop(context);
                            await _loadMessagesForConversation(convo.id);
                          },
                        );
                      },
                    );
                  }),
                ),
                const Divider(height: 1),
              ],
            ),
          ),
        ),
        body: Column(children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isLoading && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 24,
                          child: TypingIndicatorCustom(),
                        ),
                      ],
                    ),
                  );
                }

                final messageIndex = isLoading ? index - 1 : index;
                final message = _messages[messageIndex];
                final isUserMessage = message.user.id == _currentUser.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8), //padding giữa các message
                  child: Column(
                    crossAxisAlignment: isUserMessage
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: isUserMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isUserMessage
                                    ? AppColors.primary
                                    : AppColors.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildMessageContent(
                                message.text,
                                isUserMessage,
                                customProps: message.customProperties,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_messages.isNotEmpty &&
              _messages.first.user.id == _gptChatUser.id &&
              !isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildSuggestionButtons(),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),

            //textfield message
            child: Row(
              children: [
                // Nút dấu cộng
                GestureDetector(
                  onTap: () {
                    _showModeBottomSheet();
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // TextField
                Expanded(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Aa',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                //send button
                GestureDetector(
                  onTap: () {
                    if (_textController.text.isNotEmpty) {
                      final message = MyChatMessage(
                        conversationId: _selectedConversationId,
                        text: _textController.text,
                        user: _currentUser,
                        createdAt: DateTime.now(),
                      );
                      _onSendMessage(message);
                      _textController.clear();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // color: !_textController.text.isEmpty
                      //     ? AppColors.primary
                      //     : Colors.grey[300],
                      color: AppColors.primary,
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          )
        ]));
  }

// 2️⃣ Hàm show bottom sheet chọn mode
  void _showModeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                "Select Mode",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Các nút mode
              _buildModeButton("Normal Chat", "normal"),
              const SizedBox(height: 12),
              _buildModeButton("Generate Plan", "generate_plan"),
              // thêm mode khác

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

// 3️⃣ Widget nút mode
  Widget _buildModeButton(String label, String mode) {
    bool isSelected = _selectedMode == mode;

    return SizedBox(
      width: double.infinity, // Chiếm full chiều ngang
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // đóng bottom sheet
          setState(() {
            _selectedMode = mode;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primary : AppColors.white,
          foregroundColor: isSelected ? Colors.white : AppColors.primary,
          elevation: 0,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.secondary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(
    String text,
    bool isUser, {
    Map<String, dynamic>? customProps,
  }) {
    final scheduleDraft = customProps?["schedule_draft"];

    bool hasValidSchedule = false;
    List<MapEntry<String, dynamic>> scheduleEntries = [];

    if (scheduleDraft != null && scheduleDraft is Map<String, dynamic>) {
      // Check format cũ (có schedule_title)
      if (scheduleDraft.containsKey('schedule_title') &&
          scheduleDraft.containsKey('days') &&
          scheduleDraft['days'] is List &&
          (scheduleDraft['schedule_title']?.toString().isNotEmpty ?? false)) {
        hasValidSchedule = true;
      }
      // Check format mới (key là ngày, value là List)
      else if (scheduleDraft.isNotEmpty) {
        final entries = scheduleDraft.entries
            .where((e) => e.value is List && (e.value as List).isNotEmpty)
            .toList();

        if (entries.isNotEmpty) {
          hasValidSchedule = true;
          scheduleEntries = entries;
        }
      }
    }

    // ✅ Nếu không có schedule hợp lệ → chỉ hiện text
    if (!hasValidSchedule) {
      return Text(
        text,
        style: TextStyle(
          color: isUser ? Colors.white : Colors.black,
        ),
      );
    }

    // ✅ Nếu có schedule hợp lệ → hiện schedule card
    if (scheduleDraft.containsKey('schedule_title')) {
      // Format cũ
      final days = scheduleDraft['days'] as List<dynamic>;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Chỉ hiện schedule_title nếu có
                  if (scheduleDraft['schedule_title'] != null &&
                      scheduleDraft['schedule_title'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        scheduleDraft['schedule_title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // ✅ Chỉ hiện start_date nếu có
                  if (scheduleDraft['start_date'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text("Start: ${scheduleDraft['start_date']}"),
                    ),
                  // ✅ Chỉ hiện end_date nếu có
                  if (scheduleDraft['end_date'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text("End: ${scheduleDraft['end_date']}"),
                    ),
                  const SizedBox(height: 8),
                  ...days.map((dayItem) {
                    final day = dayItem as Map<String, dynamic>? ?? {};
                    final tasks = day['tasks'] as List<dynamic>? ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            day['date'] ?? '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...tasks.map((taskItem) {
                            final task =
                                taskItem as Map<String, dynamic>? ?? {};
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                "- ${task['time'] ?? '-'} | ${task['description'] ?? '-'} (${task['length'] ?? '-'})",
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: () => _createSchedule(customProps, context),
            child: const Text("Create Schedule"),
          ),
        ],
      );
    } else {
      // Format mới (key là ngày)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: TextStyle(
              color: isUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...scheduleEntries.map((entry) {
                    final date = entry.key;
                    final tasks = entry.value as List<dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...tasks.map((taskItem) {
                            final task =
                                taskItem as Map<String, dynamic>? ?? {};
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                "- ${task['time'] ?? '-'} | ${task['description'] ?? '-'} (${task['length'] ?? '-'})",
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: () => _createSchedule(customProps, context),
            child: const Text("Create Schedule"),
          ),
        ],
      );
    }
  }

  // Future<void> _createSchedule(
  //   Map<String, dynamic>? customProps,
  //   BuildContext context,
  // ) async {
  //   if (customProps == null || customProps["schedule_draft"] == null) return;

  //   final draft = Map<String, dynamic>.from(customProps["schedule_draft"]);

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (_) => const Center(
  //       child: CircularProgressIndicator(strokeWidth: 2.5),
  //     ),
  //   );

  //   try {
  //     final result = await ApiService.createTasksFromSchedule(
  //       scheduleDraft: draft,
  //     );

  //     Navigator.pop(context);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Tasks created successfully!",
  //             style: const TextStyle(color: Colors.green)),
  //         backgroundColor: Colors.green.shade100,
  //       ),
  //     );
  //   } catch (e) {
  //     Navigator.pop(context);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text("Failed: $e"),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  Future<void> _createSchedule(
    Map<String, dynamic>? customProps,
    BuildContext context,
  ) async {
    if (customProps == null || customProps["schedule_draft"] == null) return;

    final draft = Map<String, dynamic>.from(customProps["schedule_draft"]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );

    try {
      // ✅ 1. Tạo category mới
      final categoryName = draft['schedule_title'] ??
          'Schedule ${DateFormat('dd/MM/yyyy').format(DateTime.now())}';

      final categoryResponse = await CategoryService.create_category(
        title: categoryName,
        color: '#6366F1',
        iconCodePoint: Icons.calendar_today.codePoint,
      );

      final categoryId = categoryResponse['id']; // ✅ Lấy id từ response

      // ✅ 2. Tạo tasks với categoryId vừa tạo
      final result = await ApiService.createTasksFromSchedule(
        scheduleDraft: draft,
        categoryId: categoryId,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Category '$categoryName' created with ${result['tasks_count'] ?? 'multiple'} tasks!",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Custom typing indicator
  List<Widget> _buildSuggestionButtons() {
    return []; // Bạn có thể thêm suggestion buttons ở đây
  }

  Future<void> _onSendMessage(MyChatMessage m) async {
    setState(() {
      _messages.insert(0, m); // user message
      isLoading = true;
    });

    _conversationHistory.add({"role": "user", "content": m.text});

    try {
      Map<String, dynamic> responseData;

      // ==== CALL API REAL ====
      if (_selectedMode == "generate_plan") {
        // Gọi endpoint /chat/schedule
        responseData = await ApiService.sendScheduleMessage(
            conversation_id: _selectedConversationId, message: m.text);

        final scheduleDraft = responseData["extra"]?["schedule_draft"];
        final reply = responseData['response'] ?? "No response";
        _conversationHistory.add({"role": "assistant", "content": reply});

        print(">>> SENDING schedule message:");
        print("conversation_id FE gửi: $_selectedConversationId");
        print("body: {conversation_id: $_selectedConversationId, message: $m}");

        setState(() {
          _messages.insert(
            0,
            MyChatMessage(
              conversationId: _selectedConversationId,
              text: reply, // dùng nội dung trả về thật
              user: _gptChatUser,
              createdAt: DateTime.now(),
              customProperties: {
                "schedule_draft": scheduleDraft,
              },
            ),
          );
          isLoading = false;
        });
      } else {
        // Gọi chat bình thường
        responseData = await ApiService.sendChat(
          conversationId: _selectedConversationId,
          message: m.text,
          conversationHistory: _conversationHistory,
          model: "gpt-4o-mini",
        );

        final reply = responseData['response'] ?? "No response";
        _conversationHistory.add({"role": "assistant", "content": reply});

        // Insert **1 message assistant duy nhất**
        final extraMap = <String, dynamic>{};
        if (responseData["extra"] != null && responseData["extra"] is Map) {
          responseData["extra"].forEach((k, v) {
            extraMap[k.toString()] = v;
          });
        }

        setState(() {
          _messages.insert(
            0,
            MyChatMessage(
              conversationId: _selectedConversationId,
              text: reply,
              user: _gptChatUser,
              createdAt: DateTime.now(),
              customProperties: extraMap,
            ),
          );
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          MyChatMessage(
            conversationId: _selectedConversationId,
            text: "Error Connection: ${e.toString()}",
            user: _gptChatUser,
            createdAt: DateTime.now(),
          ),
        );
        isLoading = false;
      });
    }
  }
}
