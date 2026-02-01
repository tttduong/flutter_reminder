import 'package:dash_chat_2/dash_chat_2.dart';

/// {@category Models}
class MyChatMessage {
  MyChatMessage({
    required this.conversationId,
    required this.user,
    required this.createdAt,
    this.isMarkdown = true,
    this.text = '',
    this.medias,
    this.quickReplies,
    this.customProperties,
    this.mentions,
    this.status = MessageStatus.none,
    this.replyTo,
    this.scheduleDraft,
  });

  // final Map<String, dynamic>? customProps;
  final Map<String, dynamic>? scheduleDraft;

  /// Create a MyChatMessage instance from json data
  factory MyChatMessage.fromJson(Map<String, dynamic> jsonData) {
    return MyChatMessage(
      conversationId: jsonData['conversationId'] ?? '', // parse conversationId
      user: ChatUser.fromJson(jsonData['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(jsonData['createdAt'].toString()).toLocal(),
      text: jsonData['text']?.toString() ?? '',
      isMarkdown: jsonData['isMarkdown']?.toString() == 'true',
      medias: jsonData['medias'] != null
          ? (jsonData['medias'] as List<dynamic>)
              .map((dynamic media) =>
                  ChatMedia.fromJson(media as Map<String, dynamic>))
              .toList()
          : <ChatMedia>[],
      quickReplies: jsonData['quickReplies'] != null
          ? (jsonData['quickReplies'] as List<dynamic>)
              .map((dynamic quickReply) =>
                  QuickReply.fromJson(quickReply as Map<String, dynamic>))
              .toList()
          : <QuickReply>[],
      customProperties: jsonData['custom_properties'] as Map<String, dynamic>?,
      mentions: jsonData['mentions'] != null
          ? (jsonData['mentions'] as List<dynamic>)
              .map((dynamic mention) =>
                  Mention.fromJson(mention as Map<String, dynamic>))
              .toList()
          : <Mention>[],
      status: MessageStatus.parse(jsonData['status'].toString()),
      replyTo: jsonData['replyTo'] != null
          ? MyChatMessage.fromJson(jsonData['replyTo'] as Map<String, dynamic>)
          : null,
      scheduleDraft:
          jsonData['scheduleDraft'] as Map<String, dynamic>?, // parse thêm
    );
  }
  // conversation id (text)
  final String conversationId;

  /// If the message is Markdown formatted then it will be converted to Markdown (by default it will be false)
  bool isMarkdown;

  /// Text of the message (optional because you can also just send a media)
  String text;

  /// Author of the message
  ChatUser user;

  /// List of medias of the message
  List<ChatMedia>? medias;

  /// A list of quick replies that users can use to reply to this message
  List<QuickReply>? quickReplies;

  /// A list of custom properties to extend the existing ones
  /// in case you need to store more things.
  /// Can be useful to extend existing features
  Map<String, dynamic>? customProperties;

  /// Date of the message
  DateTime createdAt;

  /// Mentioned elements in the message
  List<Mention>? mentions;

  /// Status of the message TODO:
  MessageStatus? status;

  /// If the message is a reply of another one TODO:
  MyChatMessage? replyTo;

  /// Convert a MyChatMessage into a json
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'conversationId': conversationId, // serialize conversationId
      'user': user.toJson(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'text': text,
      'medias': medias?.map((ChatMedia media) => media.toJson()).toList(),
      'quickReplies': quickReplies
          ?.map((QuickReply quickReply) => quickReply.toJson())
          .toList(),
      'customProperties': customProperties,
      'mentions': mentions,
      'status': status.toString(),
      'replyTo': replyTo?.toJson(),
      'isMarkdown': isMarkdown,
      'scheduleDraft': scheduleDraft,
    };
  }
}

class MessageStatus {
  const MessageStatus._internal(this._value);
  final String _value;

  @override
  String toString() => _value;

  static MessageStatus parse(String value) {
    switch (value) {
      case 'none':
        return MessageStatus.none;
      case 'failed':
        return MessageStatus.failed;
      case 'sent':
        return MessageStatus.sent;
      case 'read':
        return MessageStatus.read;
      case 'received':
        return MessageStatus.received;
      case 'pending':
        return MessageStatus.pending;
      default:
        return MessageStatus.none;
    }
  }

  static const MessageStatus none = MessageStatus._internal('none');
  static const MessageStatus failed = MessageStatus._internal('failed');
  static const MessageStatus sent = MessageStatus._internal('sent');
  static const MessageStatus read = MessageStatus._internal('read');
  static const MessageStatus received = MessageStatus._internal('received');
  static const MessageStatus pending = MessageStatus._internal('pending');
}
