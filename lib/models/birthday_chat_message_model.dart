import 'birthday_chat_reaction_model.dart';

class BirthdayChatMessageModel {
  final int id;
  final int? studentId;
  final int? senderId;
  final String? senderName;
  final String? senderUsername;
  final String message;

  final String? createdAt;
  final String? updatedAt;

  final bool isEdited;
  final bool isDeleted;

  final List<BirthdayChatReactionModel> reactions;

  final int? parentMessageId;
  final String? replyToMessage;

  BirthdayChatMessageModel({
    required this.id,
    this.studentId,
    this.senderId,
    this.senderName,
    this.senderUsername,
    required this.message,
    this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.isDeleted = false,
    this.reactions = const [],
    this.parentMessageId,
    this.replyToMessage,
  });

  factory BirthdayChatMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final List<BirthdayChatReactionModel> parsedReactions = [];

    final rawReactions = json['reactions'];

    if (rawReactions is List) {
      for (final item in rawReactions) {
        if (item is Map) {
          parsedReactions.add(
            BirthdayChatReactionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }

    return BirthdayChatMessageModel(
      id: _toInt(json['id']) ?? 0,
      studentId: _toInt(json['studentId']),
      senderId: _toInt(json['senderId']),

      senderName: json['senderName']?.toString(),

      // If backend does not currently send this,
      // it will simply remain null.
      senderUsername: json['senderUsername']?.toString(),

      message: json['message']?.toString() ?? '',

      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),

      isEdited:
          json['edited'] == true ||
          json['isEdited'] == true,

      isDeleted:
          json['deleted'] == true,

      reactions: parsedReactions,

      parentMessageId: _toInt(
        json['replyToMessageId'] ??
            json['parentMessageId'],
      ),

      replyToMessage:
          json['replyToMessage']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}