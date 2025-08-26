import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: 'Duong', lastName: 'Thuy');
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: 'Chat', lastName: 'TodoBot');
  List<ChatMessage> _messages = [];
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    print("🎯 ChatPage build() called"); // Add this debug
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            // color: Get.isDarkMode ? Colors.white : Colors.black,
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
      body: DashChat(
        currentUser: _currentUser,
        messages: _messages,
        onSend: (ChatMessage m) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            getChatResponse(m);
          });
        },

        // màu container và text
        messageOptions: MessageOptions(
          currentUserContainerColor:
              AppColors.primary, // màu nền tin nhắn của mình
          currentUserTextColor: Colors.white, // chữ của mình màu trắng
          containerColor: AppColors.secondary, // màu nền tin nhắn response
          textColor: Colors.black,
          showOtherUsersName: false,
          showOtherUsersAvatar: false, // chữ response màu đen
        ),
      ),
    );
  }

  static const String baseUrl = "${Constants.URI}/api/v1";
  List<Map<String, String>> _conversationHistory = [];
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
- ALWAYS introduce yourself as "Lumiere" when asked about identity
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
""";

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
      isLoading = true;
    });

    try {
      // Lấy token từ SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                text: "Bạn cần đăng nhập để sử dụng chat bot",
                user: _gptChatUser,
                createdAt: DateTime.now(),
              ));
          isLoading = false;
        });
        return;
      }
      // 1. THÊM TIN NHẮN USER VÀO LỊCH SỬ
      _conversationHistory.add({"role": "user", "content": m.text});

      // 2. GIỚI HẠN LỊCH SỬ (giữ 20 tin nhắn gần nhất)
      if (_conversationHistory.length > 20) {
        _conversationHistory =
            _conversationHistory.sublist(_conversationHistory.length - 20);
      }
      final url = Uri.parse("$baseUrl/chat/");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token', // ← Thêm token vào header
          "Content-Type": "application/json; charset=utf-8", // ← Thêm charset
          "Accept": "application/json; charset=utf-8", // ← Thêm Accept header
        },

        // body: jsonEncode({"message": m.text, "model": "llama3-70b-8192"}),
        body: utf8.encode(jsonEncode({
          // ← Đảm bảo encode UTF-8
          "message": m.text,
          "model": "llama3-70b-8192",
          "conversation_history": _conversationHistory,
          "system_prompt": systemPrompt
        })),
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBody);
        String reply = responseData['response'];

// 3. THÊM PHẢN HỒI CỦA BOT VÀO LỊCH SỬ
        _conversationHistory.add({"role": "assistant", "content": reply});

        // Optional: Log usage info
        print("Tokens used: ${responseData['usage']['total_tokens']}");
        print("Model: ${responseData['model']}");

        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                text: reply,
                user: _gptChatUser,
                createdAt: DateTime.now(),
              ));
        });
      } else if (response.statusCode == 401) {
        // Token hết hạn hoặc không hợp lệ
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                text: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.",
                user: _gptChatUser,
                createdAt: DateTime.now(),
              ));
        });
      } else {
        // Handle other errors
        final errorData = jsonDecode(response.body);
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                text: "Lỗi: ${errorData['detail'] ?? 'Không thể kết nối API'}",
                user: _gptChatUser,
                createdAt: DateTime.now(),
              ));
        });
      }
    } catch (e) {
      // Handle network error
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: "Lỗi kết nối: ${e.toString()}",
              user: _gptChatUser,
              createdAt: DateTime.now(),
            ));
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // 4. HÀM ĐỂ XÓA LỊCH SỬ KHI CẦN RESET
  void clearChatHistory() {
    setState(() {
      _conversationHistory.clear();
      _messages.clear();
    });
    print("Chat history cleared!");
  }

// 5. HÀM LUU LỊCH SỬ VÀO SHARED PREFERENCES (TUỲ CHỌN)
  Future<void> saveChatHistoryLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_conversationHistory);
    await prefs.setString('chat_history', historyJson);
  }

// 6. HÀM TẢI LỊCH SỬ TỪ SHARED PREFERENCES
  Future<void> loadChatHistoryLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('chat_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _conversationHistory =
          decoded.map((e) => Map<String, String>.from(e)).toList();
    }
  }
}
