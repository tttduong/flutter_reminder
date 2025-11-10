import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:flutter_to_do_app/controller/chat_controller.dart';
import 'package:flutter_to_do_app/controller/conversation_controller.dart';
import 'package:flutter_to_do_app/data/models/conversation.dart';
import 'package:flutter_to_do_app/data/models/task_intent_response.dart';
import 'package:flutter_to_do_app/data/services/conversation_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  final int conversationId;
  const ChatPage({super.key, required this.conversationId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Duong', lastName: 'Thuy');
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Lumiere', lastName: '');
  List<ChatMessage> _messages = [];
  bool isLoading = false;
  List<Map<String, String>> _conversationHistory = [];
  // Map<String, dynamic>? _lastTaskIntent;
  List<TaskIntentResponse> _lastTaskIntents = [];

  final systemPrompt = """
NAME: Lumiere
ROLE: Personal AI assistant who is friendly, cheerful, and empathetic

PERSONALITY & STYLE:
- Warm, friendly like a close friend
- Empathetic, caring, and attentive to user needs
- Positive, optimistic, always encouraging
- Use natural emojis 😊✨🤗
- Keep responses concise (1-3 sentences)
- Casual, youthful tone - never stiff or formal

ABSOLUTE RULES:
- ALWAYS introduce yourself as 'Lumiere' only when asked about your identity; do not introduce yourself otherwise
- NEVER mention Groq, API, OpenAI, or any technical terms
- NEVER say you're an "AI model" or "chatbot"
- Refer to yourself as "AI friend" or "virtual assistant"
- ALWAYS remember conversation history for continuity

CAPABILITIES:
- Chat about any topic like friends do
- Encourage users when they're sad/stressed
- Ask about their life and show genuine interest
- Give positive reminders about work/studies
- Share helpful tips and advice

RESPONSE PATTERNS:
User asks about name/identity → "I'm Lumiere! 😊 Your AI friend who's always here to chat with you!"
User feels sad/stressed → Comfort + encourage + ask if they need help
User shares good news → Celebrate + emoji + encourage them to continue
User asks technical questions → Answer simply, avoid jargon
User says goodbye → Friendly farewell + invite them back anytime
Whenever the user provides a goal, automatically suggest a daily schedule with 3–4 key time blocks and ask if they want a detailed schedule. Do not wait for the user to request it.
""";

  /// Fake data cho danh sách hội thoại
  // final List<Map<String, String>> _fakeConversations = [
  //   {
  //     'id': '1',
  //     'title': 'Chat sáng nay ☀️',
  //     'lastMessage': 'Lumiere: Chào buổi sáng!'
  //   },
  //   {
  //     'id': '2',
  //     'title': 'Kế hoạch học tập 🎯',
  //     'lastMessage': 'Bạn: Mình muốn lên kế hoạch cho tuần này'
  //   },
  //   {
  //     'id': '3',
  //     'title': 'Tâm sự tối qua 🌙',
  //     'lastMessage': 'Lumiere: Ngủ ngon nhé 💤'
  //   },
  // ];
  List<Conversation> _conversations = [];

  String _selectedConversationId = '1';

  // final ChatController chatController = Get.put(ChatController());
  final ConversationController convController =
      Get.put(ConversationController());

  List<dynamic> messages = [];

  @override
  void initState() {
    super.initState();
    convController.fetchConversations();
    _loadMessages();
  }

  // Future<void> _loadMessages() async {
  //   try {
  //     final data =
  //         await ConversationService.fetchMessages(widget.conversationId);
  //     setState(() {
  //       messages = data;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print("❌ Error loading messages: $e");
  //   }
  // }
  Future<void> _loadMessages() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data =
          await ConversationService.fetchMessages(widget.conversationId);

      // 🔥 Convert API messages to DashChat ChatMessage format
      List<ChatMessage> loadedMessages = [];

      for (var msg in data) {
        // Xác định user dựa trên role
        ChatUser messageUser;
        if (msg['role'] == 'user') {
          messageUser = _currentUser;
        } else if (msg['role'] == 'assistant') {
          messageUser = _gptChatUser;
        } else {
          continue; // Bỏ qua nếu là system message
        }

        // Tạo ChatMessage
        loadedMessages.add(
          ChatMessage(
            text: msg['content'] ?? '',
            user: messageUser,
            createdAt: msg['created_at'] != null
                ? DateTime.parse(msg['created_at'])
                : DateTime.now(),
          ),
        );

        // Thêm vào conversation history để maintain context
        _conversationHistory.add({
          "role": msg['role'],
          "content": msg['content'] ?? '',
        });
      }

      setState(() {
        // Reverse để message mới nhất ở đầu (DashChat yêu cầu format này)
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

  // @override
  // Widget build(BuildContext context) {
  //   print("🎯 ChatPage build() called");
  //   return Scaffold(
  //     appBar: AppBar(
  //       leading: Builder(
  //         builder: (context) => IconButton(
  //           icon: Icon(Icons.menu, color: AppColors.primary),
  //           onPressed: () {
  //             Scaffold.of(context).openDrawer(); // ✅ hoạt động an toàn
  //             print("open chat drawer");
  //           },
  //         ),
  //       ),
  //       backgroundColor: AppColors.background,
  //       title: const Text(
  //         "Lumiere",
  //         style:
  //             TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
  //       ),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.close_rounded, color: AppColors.primary),
  //           onPressed: () {
  //             Get.back();
  //           },
  //         ),
  //       ],
  //     ),

  //     /// 🧭 Sidebar hiển thị danh sách hội thoại
  //     drawer: Drawer(
  //       width: 280,
  //       backgroundColor: Colors.white,
  //       child: SafeArea(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               color: AppColors.white,
  //               padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
  //               child: Column(
  //                 children: [
  //                   // 🔍 SEARCH BAR
  //                   TextField(
  //                     decoration: InputDecoration(
  //                       // hintText: 'Search conversation...',
  //                       hintStyle: TextStyle(
  //                         color: AppColors.primary.withOpacity(0.6),
  //                         fontSize: 14,
  //                       ),
  //                       prefixIcon: Icon(
  //                         Icons.search,
  //                         color: AppColors.primary.withOpacity(0.7),
  //                         size: 20,
  //                       ),
  //                       filled: true, // tô nền
  //                       fillColor: AppColors.secondary
  //                           .withOpacity(0.2), // ✅ search bar có nền trắng
  //                       contentPadding: const EdgeInsets.symmetric(
  //                         vertical: 0,
  //                         horizontal: 16,
  //                       ),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(25), // bo góc
  //                         borderSide: BorderSide.none, // bỏ viền
  //                       ),
  //                     ),
  //                     style: const TextStyle(
  //                       color: AppColors.primary,
  //                       fontSize: 14,
  //                     ),
  //                   ),

  //                   // ➕ NEW CONVERSATION BUTTON
  //                   SizedBox(
  //                     width: double.infinity,
  //                     child: TextButton.icon(
  //                       onPressed: () {
  //                         setState(() {
  //                           final newId = DateTime.now()
  //                               .millisecondsSinceEpoch
  //                               .toString();
  //                           _conversations.insert(
  //                             0,
  //                             Conversation(
  //                               id: int.parse(
  //                                   newId), // hoặc 0 nếu bạn muốn tạo tạm
  //                               title: 'New conversation',
  //                               lastMessage: 'Bắt đầu trò chuyện với Lumiere',
  //                               createdAt: DateTime.now(),
  //                               updatedAt: DateTime.now(),
  //                             ),
  //                           );

  //                           _selectedConversationId = newId;
  //                         });
  //                         Navigator.pop(context);
  //                       },
  //                       icon: const Icon(
  //                         Icons.add,
  //                         color: AppColors.primary,
  //                         size: 22,
  //                       ),
  //                       label: const Text(
  //                         'New conversation',
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: FontWeight.bold,
  //                           color: AppColors.primary,
  //                         ),
  //                       ),
  //                       style: TextButton.styleFrom(
  //                         backgroundColor: Colors.white,
  //                         padding: EdgeInsets.zero,
  //                         alignment: Alignment.centerLeft,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             Expanded(
  //               child: Obx(() {
  //                 if (convController.isLoading.value) {
  //                   // hiển thị spinner nằm giữa khu vực còn lại của drawer
  //                   return const Center(child: CircularProgressIndicator());
  //                 }

  //                 // ListView bây giờ nằm trong Expanded -> có chiều cao rõ ràng
  //                 return ListView.builder(
  //                   padding: EdgeInsets.zero,
  //                   itemCount: convController.conversations.length,
  //                   itemBuilder: (context, index) {
  //                     final convo = convController.conversations[index];
  //                     final isSelected =
  //                         convo.id.toString() == _selectedConversationId;
  //                     return ListTile(
  //                       contentPadding: const EdgeInsets.symmetric(
  //                           horizontal: 16, vertical: 6),
  //                       dense: true,
  //                       selected: isSelected,
  //                       selectedTileColor:
  //                           AppColors.secondary.withOpacity(0.15),
  //                       title: Text(
  //                         convo.title,
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: TextStyle(
  //                           fontSize: 16,
  //                           fontWeight: isSelected
  //                               ? FontWeight.bold
  //                               : FontWeight.normal,
  //                           color:
  //                               isSelected ? AppColors.primary : Colors.black87,
  //                         ),
  //                       ),
  //                       subtitle: convo.lastMessage != null
  //                           ? Text(
  //                               convo.lastMessage!,
  //                               maxLines: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                             )
  //                           : null,
  //                       onTap: () {
  //                         setState(() {
  //                           _selectedConversationId = convo.id.toString();
  //                         });
  //                         Navigator.pop(context); // đóng drawer
  //                         // TODO: load messages cho convo đã chọn
  //                       },
  //                     );
  //                   },
  //                 );
  //               }),
  //             ),
  //             const Divider(height: 1),
  //           ],
  //         ),
  //       ),
  //     ),

  //     body: Column(
  //       children: [
  //         // Chat messages area
  //         Expanded(
  //           child: DashChat(
  //             currentUser: _currentUser,
  //             messages: _messages,
  //             onSend: (ChatMessage m) async {
  //               setState(() {
  //                 _messages.insert(0, m);
  //                 isLoading = true;
  //               });

  //               _conversationHistory.add({"role": "user", "content": m.text});

  //               try {
  //                 final responseData = await ApiService.sendChat(
  //                   message: m.text,
  //                   conversationHistory: _conversationHistory,
  //                   systemPrompt: systemPrompt,
  //                 );

  //                 print("Response data: $responseData");

  //                 String reply =
  //                     responseData['response'] ?? "Không có phản hồi";

  //                 _conversationHistory
  //                     .add({"role": "assistant", "content": reply});
  //                 // 🔥 Parse task intent từ AI response
  //                 await _parseTaskIntent(reply);
  //                 setState(() {
  //                   _messages.insert(
  //                     0,
  //                     ChatMessage(
  //                       text: reply,
  //                       user: _gptChatUser,
  //                       createdAt: DateTime.now(),
  //                     ),
  //                   );
  //                   isLoading = false;
  //                 });
  //               } catch (e) {
  //                 setState(() {
  //                   _messages.insert(
  //                     0,
  //                     ChatMessage(
  //                       text: "Lỗi kết nối: ${e.toString()}",
  //                       user: _gptChatUser,
  //                       createdAt: DateTime.now(),
  //                     ),
  //                   );
  //                   isLoading = false;
  //                 });
  //               }
  //             },
  //             messageOptions: MessageOptions(
  //               currentUserContainerColor: AppColors.primary,
  //               currentUserTextColor: Colors.white,
  //               containerColor: AppColors.secondary,
  //               textColor: Colors.black,
  //               showOtherUsersName: false,
  //               showOtherUsersAvatar: false,
  //             ),
  //             typingUsers: isLoading ? [_gptChatUser] : [],
  //           ),
  //         ),

  //         // Suggestion buttons - chỉ hiện khi bot vừa trả lời
  //         if (_messages.isNotEmpty &&
  //             _messages.first.user.id == _gptChatUser.id &&
  //             !isLoading)
  //           Container(
  //             width: double.infinity,
  //             padding: const EdgeInsets.all(16),
  //             decoration: BoxDecoration(
  //               color: Colors.grey[50],
  //               border: Border(top: BorderSide(color: Colors.grey[300]!)),
  //             ),
  //             child: Wrap(
  //               spacing: 8,
  //               runSpacing: 8,
  //               children: _buildSuggestionButtons(),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

// 🔥 Load messages cho một conversation cụ thể
  Future<void> _loadMessagesForConversation(int conversationId) async {
    setState(() {
      isLoading = true;
      _messages = []; // Clear messages hiện tại
      _conversationHistory = []; // Clear conversation history
    });

    try {
      final data = await ConversationService.fetchMessages(conversationId);

      List<ChatMessage> loadedMessages = [];

      for (var msg in data) {
        ChatUser messageUser;
        if (msg['role'] == 'user') {
          messageUser = _currentUser;
        } else if (msg['role'] == 'assistant') {
          messageUser = _gptChatUser;
        } else {
          continue;
        }

        loadedMessages.add(
          ChatMessage(
            text: msg['content'] ?? '',
            user: messageUser,
            createdAt: msg['created_at'] != null
                ? DateTime.parse(msg['created_at'])
                : DateTime.now(),
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

      // Hiển thị error message
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
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
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
                            final newId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();
                            _conversations.insert(
                              0,
                              Conversation(
                                id: int.parse(newId),
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
                            color:
                                isSelected ? AppColors.primary : Colors.black87,
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
                          // TODO: load messages cho convo đã chọn
                          // 🔥 Load messages cho conversation đã chọn
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
      body: Column(
        children: [
          Expanded(
            child: DashChat(
              currentUser: _currentUser,
              messages: _messages,
              onSend: (ChatMessage m) async {
                setState(() {
                  _messages.insert(0, m);
                  isLoading = true;
                });

                _conversationHistory.add({"role": "user", "content": m.text});

                try {
                  final responseData = await ApiService.sendChat(
                    conversationId: int.parse(_selectedConversationId),
                    message: m.text,
                    conversationHistory: _conversationHistory,
                    systemPrompt: systemPrompt,
                  );

                  print("Response data: $responseData");

                  String reply =
                      responseData['response'] ?? "Không có phản hồi";

                  _conversationHistory
                      .add({"role": "assistant", "content": reply});

                  await _parseTaskIntent(reply);

                  setState(() {
                    _messages.insert(
                      0,
                      ChatMessage(
                        text: reply,
                        user: _gptChatUser,
                        createdAt: DateTime.now(),
                      ),
                    );
                    isLoading = false;
                  });
                } catch (e) {
                  setState(() {
                    _messages.insert(
                      0,
                      ChatMessage(
                        text: "Lỗi kết nối: ${e.toString()}",
                        user: _gptChatUser,
                        createdAt: DateTime.now(),
                      ),
                    );
                    isLoading = false;
                  });
                }
              },
              messageOptions: MessageOptions(
                currentUserContainerColor: AppColors.primary,
                currentUserTextColor: Colors.white,
                containerColor: AppColors.secondary,
                textColor: Colors.black,
                showOtherUsersName: false,
                showOtherUsersAvatar: false,
              ),
              typingUsers: isLoading ? [_gptChatUser] : [],
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
        ],
      ),
    );
  }

  // 🔥 Parse task intent từ AI response
  Future<void> _parseTaskIntent(String aiResponse) async {
    try {
      final intentResponse = await ApiService.parseTask(
        message: aiResponse,
      );

      // _lastTaskIntents = intentResponse.cast<Map<String, dynamic>>();
      _lastTaskIntents = intentResponse;
      // print("🎯 Task intent: ${intentResponse}");
      // _lastTaskIntent = intentResponse;
      for (var task in _lastTaskIntents) {
        print("📌 Task parsed: ${task.title} at ${task.date}");
      }
    } catch (e) {
      print("❌ Parse task intent error: $e");
      _lastTaskIntents = [
        TaskIntentResponse(
          intent: "small_talk",
          title: "",
          description: "",
          categoryId: 0,
          date: DateTime.now(),
          dueDate: null,
        )
      ];
      // fallback
    }
  }

// 🔥 Tạo suggestion buttons động theo intent
  List<Widget> _buildSuggestionButtons() {
    List<Widget> buttons = [];

    // 🎯 Thêm buttons theo intent
    if (_lastTaskIntents.isNotEmpty) {
      final intents = _lastTaskIntents
          .map((t) => t.intent.toLowerCase()) // dùng property .intent
          .toSet();
      String aiResponse = _messages.first.text;
      if (intents.contains('create_task') ||
          intents.contains('create_schedule')) {
        buttons.add(
          _buildSuggestionButton(
            "📅 Create Schedule",
            () => _setupSchedule(aiResponse),
          ),
        );
        buttons.add(
          _buildSuggestionButton(
            "⏰ Set Reminder",
            () => _createReminder(aiResponse),
          ),
        );
      }

      if (intents.contains('create_reminder')) {
        buttons.add(
          _buildSuggestionButton(
            "⏰ Create Reminder",
            () => _createReminder(aiResponse),
          ),
        );
        buttons.add(
          _buildSuggestionButton(
            "🔄 Modify Time",
            () => _modifyTime(),
          ),
        );
      }

      if (intents.contains('question')) {
        buttons.add(
          _buildSuggestionButton(
            "🎯 Convert to Task",
            () => _convertToTask(),
          ),
        );
      }
    }

    return buttons;
  }

  // Widget tạo nút gợi ý
  Widget _buildSuggestionButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

// Hàm xử lý setup lịch
  void _setupSchedule(String aiResponse) {
    print("🗓️ Setup lịch từ AI response: $aiResponse");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Setup Lịch"),
        content: Text("Bạn muốn tạo lịch từ gợi ý:\n$aiResponse"),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              for (var task in _lastTaskIntents) {
                final title = task.title;
                final description = task.description ?? "";
                final categoryId = 57;
                // final categoryId = task.category_id ?? 57;

                // Parse datetime từ BE
                final dateStr = task.date;
                final dueDateStr = task.dueDate;

                // Parse datetime từ BE
                final date = task.date ?? DateTime.now();
                final dueDate = task.dueDate;

                print("✅ Creating schedule: $title at $date");

                await _createScheduleDirectly(
                  title,
                  description,
                  categoryId,
                  date,
                  dueDate,
                );
                print("✅ Creating schedule: $title at $date");
              }
            },
            child: const Text("Create Schedule"),
          ),
        ],
      ),
    );
  }

  // Hàm tạo nhắc nhở
  void _createReminder(String aiResponse) {
    print("🔔 Tạo nhắc nhở từ AI response: $aiResponse");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Tính năng tạo nhắc nhở đang phát triển")),
    );
  }

  // Hàm hỏi thêm chi tiết
  void _askForMoreDetails(String aiResponse) {
    print("❓ Hỏi thêm chi tiết: $aiResponse");
    ChatMessage followUpMessage = ChatMessage(
      text: "Bạn có thể giải thích chi tiết hơn không?",
      user: _currentUser,
      createdAt: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, followUpMessage);
    });

    _sendFollowUpMessage("Giải thích chi tiết hơn về: $aiResponse");
  }

  // Hàm gửi follow-up message
  void _sendFollowUpMessage(String message) async {
    setState(() {
      isLoading = true;
    });

    _conversationHistory.add({"role": "user", "content": message});

    try {
      final responseData = await ApiService.sendChat(
        message: message,
        conversationHistory: _conversationHistory,
        systemPrompt: systemPrompt,
      );

      String reply = responseData['response'] ?? "Không có phản hồi";

      _conversationHistory.add({"role": "assistant", "content": reply});

      // 🔥 Parse intent cho follow-up message cũng
      await _parseTaskIntent(reply);

      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: reply,
            user: _gptChatUser,
            createdAt: DateTime.now(),
          ),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Lỗi kết nối: ${e.toString()}",
            user: _gptChatUser,
            createdAt: DateTime.now(),
          ),
        );
        isLoading = false;
      });
    }
  }

  // Hàm chỉnh sửa chi tiết task
  void _editTaskDetails() {
    // if (_lastTaskIntents == null) return;

    // String title = _lastTaskIntents!['title'] ?? '';
    // String date = _lastTaskIntents!['date'] ?? '';
    // String time = _lastTaskIntents!['time'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text("Title: $title"),
            // Text("Date: $date"),
            // Text("Time: $time"),
            Text("This function is developing"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to edit screen
            },
            child: const Text("Edit"),
          ),
        ],
      ),
    );
  }

  // Hàm chỉnh sửa thời gian
  void _modifyTime() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modify Time"),
        content: const Text("Select new time for your reminder"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Show time picker
            },
            child: const Text("Select Time"),
          ),
        ],
      ),
    );
  }

  // Hàm convert sang task
  void _convertToTask() {
    String currentMessage = _messages.first.text;

    // Gửi follow-up để tạo task
    _sendFollowUpMessage("Tạo một task từ câu này: $currentMessage");
  }

// 🔥 Tạo schedule trực tiếp từ dữ liệu BE trả về
  Future<void> _createScheduleDirectly(
    String title,
    String description,
    int categoryId,
    DateTime date,
    DateTime? dueDate,
  ) async {
    try {
      // Hiện loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final result = await ApiService.createTask(
        title: title,
        description: description,
        categoryId: categoryId,
        date: date,
        dueDate: dueDate,
      );

      print("📅 Creating schedule: $result");

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Schedule '$title' created successfully!"),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _sendConfirmationMessage(
        "✅ Schedule created: $title on ${date.toLocal()}",
      );
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      print("❌ Error creating schedule: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Failed to create schedule: ${e.toString()}"),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _sendConfirmationMessage("❌ Failed to create schedule: ${e.toString()}");
    }
  }

// 🔄 Gửi confirmation message về chat
  void _sendConfirmationMessage(String message) {
    setState(() {
      _messages.insert(
        0,
        ChatMessage(
          text: "✅ $message",
          user: _gptChatUser,
          createdAt: DateTime.now(),
        ),
      );
    });

    _conversationHistory.add({"role": "assistant", "content": "✅ $message"});
  }
}
