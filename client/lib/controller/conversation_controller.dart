import 'package:flutter_to_do_app/data/services/conversation_service.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/data/models/conversation.dart';

class ConversationController extends GetxController {
  var conversations = <Conversation>[].obs;
  var isLoading = false.obs;

  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      final data = await ConversationService.getAllConversations();
      conversations.assignAll(data);
    } catch (e) {
      print("Error fetching conversations: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
