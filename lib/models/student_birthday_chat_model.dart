class StudentBirthdayChatModel {
  final int? studentId;
  final String? studentName;
  final String? className;
  final String? section;
  final String? birthdayDate;
  final int messageCount;
  final String? lastMessage;
  final String? lastMessageTime;

  StudentBirthdayChatModel({
    this.studentId,
    this.studentName,
    this.className,
    this.section,
    this.birthdayDate,
    this.messageCount = 0,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory StudentBirthdayChatModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentBirthdayChatModel(
      studentId: _toInt(json['studentId']),
      studentName: json['studentName']?.toString(),
      className: json['className']?.toString(),
      section: json['section']?.toString(),
      birthdayDate: json['birthdayDate']?.toString(),
      messageCount:
          _toInt(json['messageCount']) ?? 0,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime:
          json['lastMessageTime']?.toString(),
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