class CommunicationMessageModel {
  final int id;
  final int conversationId;
  final String content;
  final String messageType;
  final String senderRole;
  final bool read;
  final DateTime? createdAt;

  CommunicationMessageModel({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.messageType,
    required this.senderRole,
    required this.read,
    this.createdAt,
  });

  factory CommunicationMessageModel.fromJson(Map<String, dynamic> json) {
    return CommunicationMessageModel(
      id: _parseInt(json['id']),
      conversationId: _parseInt(json['conversationId']),
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      senderRole: json['senderRole']?.toString() ?? '',
      read: json['read'] == true,
      createdAt: _parseDateTime(json['createdAt']),
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