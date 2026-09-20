import 'communication_message_model.dart';

class ConversationModel {
  final int id;
  final int parentId;
  final int teacherId;
  final int studentId;

  final String? teacherName;
  final String? studentName;
  final String? subject;

  final DateTime? createdAt;

  final List<CommunicationMessageModel> messages;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.parentId,
    required this.teacherId,
    required this.studentId,
    this.teacherName,
    this.studentName,
    this.subject,
    this.createdAt,
    required this.messages,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final messagesJson = json['messages'];

    return ConversationModel(
      id: _parseInt(json['id']),
      parentId: _parseInt(json['parentId']),
      teacherId: _parseInt(json['teacherId']),
      studentId: _parseInt(json['studentId']),
      teacherName: json['teacherName']?.toString(),
      studentName: json['studentName']?.toString(),
      subject: json['subject']?.toString(),
      createdAt: _parseDateTime(json['createdAt']),
      messages: messagesJson is List
          ? messagesJson
              .map(
                (item) => CommunicationMessageModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
      unreadCount: _parseInt(json['unreadCount']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}