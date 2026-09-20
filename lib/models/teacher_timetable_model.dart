class TeacherTimetableModel {
  final int id;
  final int teacherId;
  final String teacherName;

  final int classId;
  final String className;

  final int? sectionId;
  final String? sectionName;

  final int subjectId;
  final String subjectName;
  final String subjectCode;

  final String dayOfWeek;
  final String startTime;
  final String endTime;

  final String? roomNumber;

  TeacherTimetableModel({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.classId,
    required this.className,
    this.sectionId,
    this.sectionName,
    required this.subjectId,
    required this.subjectName,
    required this.subjectCode,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.roomNumber,
  });

  factory TeacherTimetableModel.fromJson(Map<String, dynamic> json) {
    return TeacherTimetableModel(
      id: json['id'] ?? 0,

      teacherId: json['teacherId'] ?? 0,
      teacherName: json['teacherName'] ?? '',

      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',

      sectionId: json['sectionId'],
      sectionName: json['sectionName'],

      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? '',
      subjectCode: json['subjectCode'] ?? '',

      dayOfWeek: json['dayOfWeek'] ?? '',

      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',

      roomNumber: json['roomNumber'],
    );
  }
}
