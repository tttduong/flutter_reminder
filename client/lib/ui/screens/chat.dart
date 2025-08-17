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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        backgroundColor: Colors.blueAccent,
        title: const Text("Lumiere", style: TextStyle(color: Colors.white)),
      ),
      body: DashChat(
        currentUser: _currentUser,
        messageOptions: MessageOptions(
          currentUserContainerColor: Colors.blueGrey,
          containerColor: Colors.black,
          textColor: Colors.white,
        ),
        onSend: (ChatMessage m) {
          // getChatResponse(m);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            getChatResponse(m);
          });
        },
        messages: _messages,
      ),
    );
  }

  static const String baseUrl = "${Constants.URI}/api/v1";

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
          "model": "llama3-70b-8192"
        })),
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(responseBody);
        String reply = responseData['response'];

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

  // Future<void> getChatResponse(ChatMessage m) async {
  //   setState(() {
  //     _messages.insert(0, m);
  //   });

  //   List<Map<String, dynamic>> _messageHistory = _messages.reversed.map((m) {
  //     return {
  //       'role': m.user == _currentUser ? 'user' : 'assistant',
  //       'content': m.text
  //     };
  //   }).toList();

  //   final url = Uri.parse("$baseUrl/chat/");

  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Authorization": "Bearer $FOREFRONT_API_KEY ",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode({
  //       "model": "gpt-3.5-turbo", // hoặc "" gpt-4 nếu bạn dùng phiên bản khác
  //       "messages": _messageHistory,
  //       "max_tokens": 200,
  //       "temperature": 0.7
  //     }),
  //   );

  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //     String reply = responseData['choices'][0]['message']['content'];

  //     setState(() {
  //       _messages.insert(
  //           0,
  //           ChatMessage(
  //             text: reply,
  //             user: _gptChatUser,
  //             createdAt: DateTime.now(),
  //           ));
  //     });
  //   } else {
  //     setState(() {
  //       _messages.insert(
  //           0,
  //           ChatMessage(
  //             text: "Lỗi: Không thể kết nối Forefront API.",
  //             user: _gptChatUser,
  //             createdAt: DateTime.now(),
  //           ));
  //     });
  //   }
  // }
}
