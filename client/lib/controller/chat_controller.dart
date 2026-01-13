import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_to_do_app/api.dart';
import 'package:flutter_to_do_app/controller/conversation_controller.dart';
import 'package:flutter_to_do_app/data/models/conversation.dart';
import 'package:flutter_to_do_app/data/services/conversation_service.dart';
import 'package:flutter_to_do_app/ui/widgets/my_chat_message.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class ChatPageController extends GetxController {
  // ===== Dependencies =====
  final ConversationController convController =
      Get.find<ConversationController>();
  final uuid = const Uuid();

  // ===== Observable State =====
  final RxList<MyChatMessage> messages = <MyChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedMode = "normal".obs; // "normal" | "generate_plan"

  // ===== Chat Users =====
  final ChatUser currentUser =
      ChatUser(id: '1', firstName: 'Duong', lastName: 'Thuy');
  final ChatUser gptChatUser =
      ChatUser(id: '2', firstName: 'Lumiere', lastName: '');

  // ===== Private State =====
  final List<Map<String, String>> _conversationHistory = [];

  // ===== Getters =====
  String? get conversationId => convController.currentConversationId.value;
  bool get isNewConversation => convController.isNewConversation.value;
  List<Conversation> get conversations => convController.conversations;

  // ===== Lifecycle =====
  @override
  void onInit() {
    super.onInit();
    convController.fetchConversations();
  }

  // ===== Public Methods =====

  /// Load messages từ conversationId hiện tại
  Future<void> loadMessages() async {
    if (conversationId == null) return;

    isLoading.value = true;
    try {
      final data = await ConversationService.fetchMessages(conversationId!);

      messages.value = _parseMessagesFromData(data);
      _conversationHistory.clear();
      _conversationHistory.addAll(data.map((msg) => {
            "role": msg['role'] as String,
            "content": msg['content'] as String? ?? '',
          }));

      print("✅ Loaded ${messages.length} messages");
    } catch (e) {
      print("❌ Error loading messages: $e");
      Get.snackbar(
        'Error',
        'Failed to load messages',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Switch sang conversation khác
  Future<void> switchConversation(String newConversationId) async {
    convController.setConversation(newConversationId, false);
    messages.clear();
    _conversationHistory.clear();
    await loadMessages();
  }

  /// Tạo conversation mới
  // void startNewConversation() {
  //   convController.resetToNewConversation();
  //   messages.clear();
  //   _conversationHistory.clear();
  // }

  Future<void> startNewConversation() async {
    try {
      isLoading.value = true;

      // 1️⃣ Gọi API tạo conversation
      final conversation =
          await ConversationService.createConversation("New Chat");

      // 2️⃣ Add vào list
      convController.conversations.insert(0, conversation);

      // 3️⃣ Set current conversation
      convController.setConversation(
        conversation.id.toString(),
        false,
      );

      // 4️⃣ Clear messages cũ
      // messages.clear();
      convController.resetToNewConversation();
      messages.clear();
      _conversationHistory.clear();
    } catch (e) {
      print("❌ Create conversation error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Gửi message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Tạo conversation mới nếu cần
    if (isNewConversation && conversationId == null) {
      await _createNewConversation(text);
    }

    if (conversationId == null) {
      print("❌ No conversation ID");
      return;
    }

    // Add user message
    final userMessage = MyChatMessage(
      conversationId: conversationId!,
      text: text,
      user: currentUser,
      createdAt: DateTime.now(),
    );

    messages.insert(0, userMessage);
    _conversationHistory.add({"role": "user", "content": text});
    isLoading.value = true;

    try {
      Map<String, dynamic> responseData;

      if (selectedMode.value == "generate_plan") {
        responseData = await ApiService.sendScheduleMessage(
          conversation_id: conversationId!,
          message: text,
        );
        _handleScheduleResponse(responseData);
      } else {
        responseData = await ApiService.sendChat(
          conversationId: conversationId!,
          message: text,
          conversationHistory: _conversationHistory,
          model: "gpt-4o-mini",
        );
        _handleNormalResponse(responseData);
      }
    } catch (e) {
      print("❌ Error sending message: $e");
      messages.insert(
          0,
          MyChatMessage(
            conversationId: conversationId!,
            text: "Error: ${e.toString()}",
            user: gptChatUser,
            createdAt: DateTime.now(),
          ));
    } finally {
      isLoading.value = false;
    }
  }

  /// Thay đổi mode chat
  void changeMode(String mode) {
    selectedMode.value = mode;
  }

  // ===== Private Methods =====

  Future<void> _createNewConversation(String firstMessage) async {
    final newConvId = uuid.v4();
    final newConv = Conversation(
      id: newConvId,
      title: firstMessage.length > 30
          ? '${firstMessage.substring(0, 30)}...'
          : firstMessage,
      lastMessage: firstMessage,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    convController.conversations.insert(0, newConv);
    convController.setConversation(newConvId, false);
    print("✅ Created conversation: $newConvId");
  }

  void _handleScheduleResponse(Map<String, dynamic> data) {
    final reply = data['response'] ?? "No response";
    final scheduleDraft = data["extra"]?["schedule_draft"];

    _conversationHistory.add({"role": "assistant", "content": reply});

    messages.insert(
        0,
        MyChatMessage(
          conversationId: conversationId!,
          text: reply,
          user: gptChatUser,
          createdAt: DateTime.now(),
          customProperties: {"schedule_draft": scheduleDraft},
        ));
  }

  void _handleNormalResponse(Map<String, dynamic> data) {
    final reply = data['response'] ?? "No response";
    _conversationHistory.add({"role": "assistant", "content": reply});

    final extraMap = <String, dynamic>{};
    if (data["extra"] != null && data["extra"] is Map) {
      data["extra"].forEach((k, v) => extraMap[k.toString()] = v);
    }

    messages.insert(
        0,
        MyChatMessage(
          conversationId: conversationId!,
          text: reply,
          user: gptChatUser,
          createdAt: DateTime.now(),
          customProperties: extraMap,
        ));
  }

  List<MyChatMessage> _parseMessagesFromData(List<dynamic> data) {
    return data
        .map((msg) {
          ChatUser messageUser;
          if (msg['role'] == 'user') {
            messageUser = currentUser;
          } else if (msg['role'] == 'assistant') {
            messageUser = gptChatUser;
          } else {
            return null;
          }

          final customProps =
              msg['custom_properties'] as Map<String, dynamic>? ?? {};
          final scheduleDraft =
              customProps['schedule_draft'] as Map<String, dynamic>?;

          return MyChatMessage(
            conversationId: conversationId!,
            text: msg['content'] ?? '',
            user: messageUser,
            createdAt: msg['created_at'] != null
                ? DateTime.parse(msg['created_at'])
                : DateTime.now(),
            customProperties: customProps,
            scheduleDraft: scheduleDraft,
          );
        })
        .whereType<MyChatMessage>()
        .toList()
        .reversed
        .toList();
  }
}
// import 'package:flutter_to_do_app/data/services/chat_service.dart';
// import 'package:get/get.dart';
// import 'package:flutter_to_do_app/data/models/conversation.dart';

// class ChatController extends GetxController {
//   var conversations = <Conversation>[].obs;
//   var isLoading = false.obs;

//   Future<void> fetchConversations() async {
//     try {
//       isLoading.value = true;
//       final data = await ChatService.getAllConversations();
//       conversations.assignAll(data);
//     } catch (e) {
//       print("Error fetching conversations: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }
