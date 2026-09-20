class StudentChatModel {
  final int studentId;
  final String studentName;
  final int? parentId;
  final String? parentName;
  final int? classId;
  final String? className;
  final int? sectionId;
  final String? sectionName;

  StudentChatModel({
    required this.studentId,
    required this.studentName,
    this.parentId,
    this.parentName,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
  });

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  factory StudentChatModel.fromJson(Map<String, dynamic> json) {
    return StudentChatModel(
      studentId: _toInt(json['studentId']) ?? 0,
      studentName: json['studentName']?.toString() ?? '',
      parentId: _toInt(json['parentId']),
      parentName: json['parentName']?.toString(),
      classId: _toInt(json['classId']),
      className: json['className']?.toString(),
      sectionId: _toInt(json['sectionId']),
      sectionName: json['sectionName']?.toString(),
    );
  }
}