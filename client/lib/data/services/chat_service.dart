// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_to_do_app/data/models/conversation.dart';
// import 'package:flutter_to_do_app/consts.dart';

// class ChatService {
//   static const String baseUrl = "${Constants.URI}/api/v1";
//   static Future<List<Conversation>> getAllConversations() async {
//     final url = Uri.parse('$baseUrl/conversations/');

//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body) as List;
//       return data.map((e) => Conversation.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to fetch conversations');
//     }
//   }
// }
