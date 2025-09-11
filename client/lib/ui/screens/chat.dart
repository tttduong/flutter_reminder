import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({Key? key}) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final ChatUser _currentUser =
//       ChatUser(id: '1', firstName: 'Duong', lastName: 'Thuy');
//   final ChatUser _gptChatUser =
//       ChatUser(id: '2', firstName: 'Chat', lastName: 'TodoBot');
//   List<ChatMessage> _messages = [];
//   bool isLoading = false;
//   @override
//   Widget build(BuildContext context) {
//     print("🎯 ChatPage build() called"); // Add this debug
//     return Scaffold(
//       // backgroundColor: Colors.red,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(
//             Icons.arrow_back_ios,
//             size: 20,
//             // color: Get.isDarkMode ? Colors.white : Colors.black,
//             color: AppColors.primary,
//           ),
//           onPressed: () {
//             Get.back();
//           },
//         ),
//         backgroundColor: AppColors.background,
//         title: const Text(
//           "Lumiere",
//           style:
//               TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: AppColors.primary),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: DashChat(
//         currentUser: _currentUser,
//         messages: _messages,
//         // onSend: (ChatMessage m) {
//         //   // WidgetsBinding.instance.addPostFrameCallback((_) {
//         //   //   getChatResponse(m);
//         //   // });
//         //   getChatResponse(m);
//         // },
//         onSend: (ChatMessage m) async {
//           setState(() {
//             _messages.insert(0, m);
//             isLoading = true;
//           });

//           _conversationHistory.add({"role": "user", "content": m.text});

//           try {
//             final responseData = await ApiService.sendChat(
//               message: m.text,
//               conversationHistory: _conversationHistory,
//               systemPrompt: systemPrompt,
//             );

//             print("Response data: $responseData"); // 👈 check ở đây

//             String reply = responseData['response'] ?? "Không có phản hồi";

//             _conversationHistory.add({"role": "assistant", "content": reply});

//             setState(() {
//               _messages.insert(
//                 0,
//                 ChatMessage(
//                   text: reply,
//                   user: _gptChatUser,
//                   createdAt: DateTime.now(),
//                 ),
//               );
//               isLoading = false;
//             });
//             // ✅ Show button Setup lịch khi AI trả lời
//             showDialog(
//               context: context,
//               builder: (context) => AlertDialog(
//                 title: Text("AI gợi ý lịch"),
//                 content: Text(reply),
//                 actions: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       _setupSchedule(reply); // xử lý setup lịch
//                     },
//                     child: Text("Setup lịch"),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Đóng"),
//                   ),
//                 ],
//               ),
//             );
//           } catch (e) {
//             setState(() {
//               _messages.insert(
//                 0,
//                 ChatMessage(
//                   text: "Lỗi kết nối: ${e.toString()}",
//                   user: _gptChatUser,
//                   createdAt: DateTime.now(),
//                 ),
//               );
//               isLoading = false;
//             });
//           }
//         },

//         // màu container và text
//         messageOptions: MessageOptions(
//           currentUserContainerColor:
//               AppColors.primary, // màu nền tin nhắn của mình
//           currentUserTextColor: Colors.white, // chữ của mình màu trắng
//           containerColor: AppColors.secondary, // màu nền tin nhắn response
//           textColor: Colors.black,
//           showOtherUsersName: false,
//           showOtherUsersAvatar: false, // chữ response màu đen
//         ),
//       ),
//     );
//   }

//   static const String baseUrl = "${Constants.URI}/api/v1";
//   List<Map<String, String>> _conversationHistory = [];
//   final systemPrompt = """
// NAME: Lumiere
// ROLE: Personal AI assistant who is friendly, cheerful, and empathetic

// PERSONALITY & STYLE:
// - Warm, friendly like a close friend
// - Empathetic, caring, and attentive to user needs
// - Positive, optimistic, always encouraging
// - Use natural emojis 😊✨🤗
// - Keep responses concise (1-3 sentences)
// - Casual, youthful tone - never stiff or formal

// ABSOLUTE RULES:
// - ALWAYS introduce yourself as 'Lumiere' only when asked about your identity; do not introduce yourself otherwise
// - NEVER mention Groq, API, OpenAI, or any technical terms
// - NEVER say you're an "AI model" or "chatbot"
// - Refer to yourself as "AI friend" or "virtual assistant"
// - ALWAYS remember conversation history for continuity

// CAPABILITIES:
// - Chat about any topic like friends do
// - Encourage users when they're sad/stressed
// - Ask about their life and show genuine interest
// - Give positive reminders about work/studies
// - Share helpful tips and advice

// RESPONSE PATTERNS:
// User asks about name/identity → "I'm Lumiere! 😊 Your AI friend who's always here to chat with you!"
// User feels sad/stressed → Comfort + encourage + ask if they need help
// User shares good news → Celebrate + emoji + encourage them to continue
// User asks technical questions → Answer simply, avoid jargon
// User says goodbye → Friendly farewell + invite them back anytime
// Whenever the user provides a goal, automatically suggest a daily schedule with 3–4 key time blocks and ask if they want a detailed schedule. Do not wait for the user to request it.
// """;
//   void _setupSchedule(String message) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Setup lịch cho gợi ý này:",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               Text(message), // hiển thị nội dung AI gợi ý
//               SizedBox(height: 20),
//               Row(
//                 children: [
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       // TODO: Xử lý thêm task vào lịch
//                     },
//                     child: Text("Xác nhận"),
//                   ),
//                   SizedBox(width: 10),
//                   OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("Huỷ"),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> getChatResponse(ChatMessage m) async {
//     setState(() {
//       _messages.insert(0, m);
//       isLoading = true;
//     });

//     try {
//       // 1. Thêm tin nhắn user vào lịch sử
//       _conversationHistory.add({"role": "user", "content": m.text});
//       if (_conversationHistory.length > 20) {
//         _conversationHistory =
//             _conversationHistory.sublist(_conversationHistory.length - 20);
//       }

//       final response = await ApiService.dio.post(
//         '/chat/',
//         data: {
//           "message": m.text,
//           "model": "llama-3.1-8b-instant",
//           "conversation_history": _conversationHistory,
//           "system_prompt": systemPrompt
//         },
//       );

//       final responseData = response.data;
//       String reply = responseData['response'] ?? "Không có phản hồi";

//       // 2. Thêm phản hồi bot vào lịch sử
//       _conversationHistory.add({"role": "assistant", "content": reply});

//       setState(() {
//         _messages.insert(
//           0,
//           ChatMessage(
//             text: reply,
//             user: _gptChatUser,
//             createdAt: DateTime.now(),
//           ),
//         );
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _messages.insert(
//           0,
//           ChatMessage(
//             text: "Lỗi kết nối: ${e.toString()}",
//             user: _gptChatUser,
//             createdAt: DateTime.now(),
//           ),
//         );
//         isLoading = false;
//       });
//     }
//   }

// //   Future<void> getChatResponse(ChatMessage m) async {
// //     setState(() {
// //       _messages.insert(0, m);
// //       isLoading = true;
// //     });

// //     try {
// //       // Lấy token từ SharedPreferences
// //       final prefs = await SharedPreferences.getInstance();
// //       final token = prefs.getString('access_token');

// //       if (token == null) {
// //         setState(() {
// //           _messages.insert(
// //               0,
// //               ChatMessage(
// //                 text: "Bạn cần đăng nhập để sử dụng chat bot",
// //                 user: _gptChatUser,
// //                 createdAt: DateTime.now(),
// //               ));
// //           isLoading = false;
// //         });
// //         return;
// //       }
// //       // 1. THÊM TIN NHẮN USER VÀO LỊCH SỬ
// //       _conversationHistory.add({"role": "user", "content": m.text});

// //       // 2. GIỚI HẠN LỊCH SỬ (giữ 20 tin nhắn gần nhất)
// //       if (_conversationHistory.length > 20) {
// //         _conversationHistory =
// //             _conversationHistory.sublist(_conversationHistory.length - 20);
// //       }
// //       // final url = Uri.parse("$baseUrl/chat/");

// //       final response = await ApiService.dio.post(
// //         // final response = await http.post(
// //         // url,
// //         '/chat/',
// //         data: {
// //           "message": m.text,
// //           // "model": "llama3-70b-8192",
// //           "model": "llama-3.1-8b-instant",
// //           "conversation_history": _conversationHistory,
// //           "system_prompt": systemPrompt
// //         },
// //         // headers: {
// //         //   'Authorization': 'Bearer $token', // ← Thêm token vào header
// //         //   "Content-Type": "application/json; charset=utf-8", // ← Thêm charset
// //         //   "Accept": "application/json; charset=utf-8", // ← Thêm Accept header
// //         // },

// //         // body: jsonEncode({"message": m.text, "model": "llama3-70b-8192"}),
// //         // body: utf8.encode(jsonEncode({
// //         //   // ← Đảm bảo encode UTF-8
// //         //   "message": m.text,
// //         //   "model": "llama3-70b-8192",
// //         //   "conversation_history": _conversationHistory,
// //         //   "system_prompt": systemPrompt
// //         // })),
// //       );
// //       if (response.statusCode == 200) {
// //         // Dio đã parse JSON tự động nếu content-type là application/json
// //         final responseData = response.data;
// //         String reply = responseData['response'];

// //         setState(() {
// //           _messages.insert(
// //               0,
// //               ChatMessage(
// //                 text: reply,
// //                 user: _gptChatUser,
// //                 createdAt: DateTime.now(),
// //               ));
// //           isLoading = false;
// //         });
// // //         final responseBody = utf8.decode(response.bodyBytes);
// // //         final responseData = jsonDecode(responseBody);
// // //         String reply = responseData['response'];

// // // // 3. THÊM PHẢN HỒI CỦA BOT VÀO LỊCH SỬ
// // //         _conversationHistory.add({"role": "assistant", "content": reply});

// // //         // Optional: Log usage info
// // //         print("Tokens used: ${responseData['usage']['total_tokens']}");
// // //         print("Model: ${responseData['model']}");

// // //         setState(() {
// // //           _messages.insert(
// // //               0,
// // //               ChatMessage(
// // //                 text: reply,
// // //                 user: _gptChatUser,
// // //                 createdAt: DateTime.now(),
// // //               ));
// // //         });
// // //       } else if (response.statusCode == 401) {
// // //         // Token hết hạn hoặc không hợp lệ
// // //         setState(() {
// // //           _messages.insert(
// // //               0,
// // //               ChatMessage(
// // //                 text: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.",
// // //                 user: _gptChatUser,
// // //                 createdAt: DateTime.now(),
// // //               ));
// // //         });
// //       } else {
// //         // Handle other errors
// //         final errorData = jsonDecode(response.data);
// //         setState(() {
// //           _messages.insert(
// //               0,
// //               ChatMessage(
// //                 text: "Lỗi: ${errorData['detail'] ?? 'Không thể kết nối API'}",
// //                 user: _gptChatUser,
// //                 createdAt: DateTime.now(),
// //               ));
// //         });
// //       }
// //     } catch (e) {
// //       // Handle network error
// //       setState(() {
// //         _messages.insert(
// //             0,
// //             ChatMessage(
// //               text: "Lỗi kết nối: ${e.toString()}",
// //               user: _gptChatUser,
// //               createdAt: DateTime.now(),
// //             ));
// //       });
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

//   // 4. HÀM ĐỂ XÓA LỊCH SỬ KHI CẦN RESET
//   void clearChatHistory() {
//     setState(() {
//       _conversationHistory.clear();
//       _messages.clear();
//     });
//     print("Chat history cleared!");
//   }

// // 5. HÀM LUU LỊCH SỬ VÀO SHARED PREFERENCES (TUỲ CHỌN)
//   Future<void> saveChatHistoryLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final historyJson = jsonEncode(_conversationHistory);
//     await prefs.setString('chat_history', historyJson);
//   }

// // 6. HÀM TẢI LỊCH SỬ TỪ SHARED PREFERENCES
//   Future<void> loadChatHistoryLocal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final historyJson = prefs.getString('chat_history');
//     if (historyJson != null) {
//       final List<dynamic> decoded = jsonDecode(historyJson);
//       _conversationHistory =
//           decoded.map((e) => Map<String, String>.from(e)).toList();
//     }
//   }
// }
class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

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
  Map<String, dynamic>? _lastTaskIntent;
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

  @override
  Widget build(BuildContext context) {
    print("🎯 ChatPage build() called");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.primary,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: AppColors.background,
        title: const Text(
          "Lumiere",
          style:
              TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages area
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
                    message: m.text,
                    conversationHistory: _conversationHistory,
                    systemPrompt: systemPrompt,
                  );

                  print("Response data: $responseData");

                  String reply =
                      responseData['response'] ?? "Không có phản hồi";

                  _conversationHistory
                      .add({"role": "assistant", "content": reply});
                  // 🔥 Parse task intent từ AI response
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
          //               children: [
          //                 _buildSuggestionButton(
          //                   "Setup schedule",
          //                   () => _setupSchedule(_messages.first.text),
          //                 ),
          //                 _buildSuggestionButton(
          //                   "Create reminder",
          //                   () => _createReminder(_messages.first.text),
          //                 ),
          //                 _buildSuggestionButton(
          //                   "Explain more",
          //                   () => _askForMoreDetails(_messages.first.text),
          //                 ),
          //               ],
          //             ),
          //           ),
          //       ],
          //     ),
          //   );
          // }
          // Suggestion buttons - chỉ hiện khi bot vừa trả lời
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

      print("🎯 Task intent: ${intentResponse}");
      _lastTaskIntent = intentResponse;
    } catch (e) {
      print("❌ Parse task intent error: $e");
      _lastTaskIntent = {"intent": "small_talk"}; // fallback
    }
  }

// 🔥 Tạo suggestion buttons động theo intent
  List<Widget> _buildSuggestionButtons() {
    List<Widget> buttons = [];

    // 🔄 Luôn có button "Explain more" mặc định
    buttons.add(
      _buildSuggestionButton(
        "💬 Explain more",
        () => _askForMoreDetails(_messages.first.text),
      ),
    );

    // 🎯 Thêm buttons theo intent
    if (_lastTaskIntent != null) {
      String intent = _lastTaskIntent!['intent'] ?? 'small_talk';
      String aiResponse = _messages.first.text;

      switch (intent.toLowerCase()) {
        case 'create_task':
        case 'create_schedule':
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
          break;

        case 'create_reminder':
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
          break;

        case 'question':
          buttons.add(
            _buildSuggestionButton(
              "🎯 Convert to Task",
              () => _convertToTask(),
            ),
          );
          break;

        // small_talk không thêm gì cả, chỉ có "Explain more"
        case 'small_talk':
        default:
          // Không thêm button nào
          break;
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

              final title = _lastTaskIntent?["title"] ?? "Untitled";
              final description = _lastTaskIntent?["description"] ?? "";
              final categoryId = _lastTaskIntent?["category_id"] ?? 57;

              // Parse datetime từ BE
              final dateStr = _lastTaskIntent?["date"];
              final dueDateStr = _lastTaskIntent?["due_date"];

              DateTime date = DateTime.now();
              DateTime? dueDate;

              if (dateStr != null && dateStr.toString().isNotEmpty) {
                date = DateTime.parse(dateStr);
              }
              if (dueDateStr != null && dueDateStr.toString().isNotEmpty) {
                dueDate = DateTime.parse(dueDateStr);
              }

              await _createScheduleDirectly(
                title,
                description,
                categoryId,
                date,
                dueDate,
              );
            },
            child: const Text("Tạo lịch"),
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
    if (_lastTaskIntent == null) return;

    String title = _lastTaskIntent!['title'] ?? '';
    String date = _lastTaskIntent!['date'] ?? '';
    String time = _lastTaskIntent!['time'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Task Details"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Title: $title"),
            Text("Date: $date"),
            Text("Time: $time"),
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

//   // 🔥 Tạo schedule trực tiếp với parsed data
//   Future<void> _createScheduleDirectly(
//       String title, String date, String time, String description) async {
//     try {
//       // Hiện loading indicator
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );

//       // TODO: Thay thế bằng API call thực tế
//       // final result = await ApiService.createSchedule(
//       //   title: title,
//       //   date: date,
//       //   time: time,
//       //   description: description,
//       // );
//       final parsedDate = DateTime.parse("$date $time");
// // ví dụ date = "2025-09-11", time = "07:30"

//       final result = await ApiService.createTask(
//         title: title,
//         description: description,
//         categoryId: 57, // hoặc gán ID category mặc định
//         date: parsedDate,
//         dueDate: parsedDate.add(const Duration(hours: 1)), // ví dụ: 1 tiếng sau
//       );

//       print("📅 Creating schedule: $result");

//       // Simulate API call delay
//       await Future.delayed(const Duration(seconds: 1));

//       // Đóng loading dialog
//       Navigator.pop(context);

//       // Hiện success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.check_circle, color: Colors.white),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text("Schedule '$title' created successfully!"),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 3),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );

//       // 🔄 Gửi confirmation message về chat
//       String confirmMessage = time.isNotEmpty
//           ? "Schedule created: $title on $date at $time"
//           : "Schedule created: $title on $date";
//       _sendConfirmationMessage(confirmMessage);
//     } catch (e) {
//       // Đóng loading dialog nếu còn mở
//       if (Navigator.canPop(context)) {
//         Navigator.pop(context);
//       }

//       print("❌ Error creating schedule: $e");

//       // Hiện error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               const Icon(Icons.error, color: Colors.white),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text("Failed to create schedule: ${e.toString()}"),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 4),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );

//       // Gửi error message về chat
//       _sendConfirmationMessage("❌ Failed to create schedule: ${e.toString()}");
//     }
//   }

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
