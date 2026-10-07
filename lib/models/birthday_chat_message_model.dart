class BirthdayChatMessageModel {
  final int id;
  final int? studentId;
  final String? studentName;
  final String? senderName;
  final String? senderUsername;
  final String message;
  final String? createdAt;
  final String? updatedAt;
  final bool isEdited;
  final List<String> reactions;
  final int? parentMessageId;

  BirthdayChatMessageModel({
    required this.id,
    this.studentId,
    this.studentName,
    this.senderName,
    this.senderUsername,
    required this.message,
    this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.reactions = const [],
    this.parentMessageId,
  });

  factory BirthdayChatMessageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BirthdayChatMessageModel(
      id: _toInt(json['id']) ?? 0,
      studentId: _toInt(json['studentId']),
      studentName: json['studentName']?.toString(),
      senderName: json['senderName']?.toString(),
      senderUsername: json['senderUsername']?.toString(),
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      isEdited: json['isEdited'] == true,
      reactions: _parseReactions(json['reactions']),
      parentMessageId: _toInt(json['parentMessageId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'message': message,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isEdited': isEdited,
      'reactions': reactions,
      'parentMessageId': parentMessageId,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static List<String> _parseReactions(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value
          .map((item) => item.toString())
          .toList();
    }

    return [];
  }
}