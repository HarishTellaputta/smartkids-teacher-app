class TeacherAssignmentModel {
  final int id;
  final int teacherId;
  final int classId;
  final String subject;

  TeacherAssignmentModel({
    required this.id,
    required this.teacherId,
    required this.classId,
    required this.subject,
  });

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    return TeacherAssignmentModel(
      id: json['id'] ?? 0,
      teacherId: json['teacherId'] ?? 0,
      classId: json['classId'] ?? 0,
      subject: json['subject'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'classId': classId,
      'subject': subject,
    };
  }
}
