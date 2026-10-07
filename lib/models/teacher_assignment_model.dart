class TeacherAssignmentModel {
  final int id;

  final int teacherId;
  final String teacherName;

  final int classId;
  final String className;

  final int? sectionId;
  final String? sectionName;

  final int? subjectId;
  final String subject;
  final String? subjectCode;

  final String? assignedAt;

  TeacherAssignmentModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.className,
    this.sectionId,
    this.sectionName,
    this.subjectId,
    required this.subject,
    this.subjectCode,
    this.assignedAt,
  });

  factory TeacherAssignmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TeacherAssignmentModel(
      id: json['id'] ?? 0,

      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',

      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',

      sectionId: json['sectionId'],
      sectionName: json['sectionName'],

      subjectId: json['subjectId'],

      // Backend sends subjectName
      subject: json['subjectName'] ??
          json['subject'] ??
          '',

      subjectCode: json['subjectCode'],

      assignedAt: json['assignedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'teacherId': teacherId,
      'teacherName': teacherName,

      'classId': classId,
      'className': className,

      'sectionId': sectionId,
      'sectionName': sectionName,

      'subjectId': subjectId,
      'subjectName': subject,
      'subjectCode': subjectCode,

      'assignedAt': assignedAt,
    };
  }
}