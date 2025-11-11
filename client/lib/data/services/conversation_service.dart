import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/data/models/conversation.dart';

class ConversationService {
  static Future<List<Conversation>> getAllConversations() async {
    try {
      final response = await ApiService.dio.get('/api/v1/conversations/');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((e) => Conversation.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load conversations");
      }
    } on DioException catch (e) {
      print("❌ Dio Error: ${e.response?.data}");
      throw Exception("Conversation API Error: ${e.message}");
    }
  }

  static Future<Conversation> createConversation(String title) async {
    try {
      final response = await ApiService.dio.post(
        '/api/v1/conversations/',
        data: {'title': title},
      );
      return Conversation.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("Create conversation failed: ${e.message}");
    }
  }

  static Future<List<dynamic>> fetchMessages(String conversationId) async {
    try {
      final response = await ApiService.dio.get(
        '/api/v1/conversations/$conversationId/messages/',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return response.data; // list message JSON
      } else {
        throw Exception("Failed to load messages: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
      rethrow;
    }
  }
}
