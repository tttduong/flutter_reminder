import 'package:flutter_to_do_app/data/services/conversation_service.dart';
import 'package:get/get.dart';
import 'package:flutter_to_do_app/data/models/conversation.dart';

class ConversationController extends GetxController {
  var conversations = <Conversation>[].obs;
  var isLoading = false.obs;

  var currentConversationId = Rxn<String>(); // Nullable String
  var isNewConversation = true.obs;
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

  // ✅ Helper method để set conversation
  void setConversation(String? id, bool isNew) {
    currentConversationId.value = id;
    isNewConversation.value = isNew;
    print("🔄 Controller state updated: id=$id, isNew=$isNew");
  }

  // ✅ Helper method để reset về new conversation
  void resetToNewConversation() {
    currentConversationId.value = null;
    isNewConversation.value = true;
    print("🆕 Reset to new conversation");
  }
}
