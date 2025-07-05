import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_to_do_app/consts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:dash_chat_2/dash_chat_2.dart';

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
          getChatResponse(m);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage m) async {
    setState(() {
      _messages.insert(0, m);
    });

    List<Map<String, dynamic>> _messageHistory = _messages.reversed.map((m) {
      return {
        'role': m.user == _currentUser ? 'user' : 'assistant',
        'content': m.text
      };
    }).toList();

    final url = Uri.parse("https://api.forefront.ai/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $FOREFRONT_API_KEY ",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo", // hoặc "" gpt-4 nếu bạn dùng phiên bản khác
        "messages": _messageHistory,
        "max_tokens": 200,
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String reply = responseData['choices'][0]['message']['content'];

      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: reply,
              user: _gptChatUser,
              createdAt: DateTime.now(),
            ));
      });
    } else {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text: "Lỗi: Không thể kết nối Forefront API.",
              user: _gptChatUser,
              createdAt: DateTime.now(),
            ));
      });
    }
  }
}
