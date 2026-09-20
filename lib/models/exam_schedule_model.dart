class ExamScheduleModel {
  final int id;

  final int examinationId;
  final String? examinationName;

  final int classId;
  final String? className;

  final int? sectionId;
  final String? sectionName;

  final int subjectId;
  final String? subjectName;
  final String? subjectCode;

  final int? subjectTeacherId;
  final String? subjectTeacherName;

  final DateTime? examDate;
  final String? startTime;

  final int duration;
  final int maxMarks;

  final String examType;
  final String? roomNumber;
  final String? status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExamScheduleModel({
    required this.id,
    required this.examinationId,
    this.examinationName,
    required this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    required this.subjectId,
    this.subjectName,
    this.subjectCode,
    this.subjectTeacherId,
    this.subjectTeacherName,
    this.examDate,
    this.startTime,
    required this.duration,
    required this.maxMarks,
    required this.examType,
    this.roomNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ExamScheduleModel.fromJson(Map<String, dynamic> json) {
    return ExamScheduleModel(
      id: _toInt(json['id']) ?? 0,

      examinationId:
          _toInt(json['examinationId']) ?? 0,

      examinationName:
          json['examinationName']?.toString(),

      classId:
          _toInt(json['classId']) ?? 0,

      className:
          json['className']?.toString(),

      sectionId:
          _toInt(json['sectionId']),

      sectionName:
          json['sectionName']?.toString(),

      subjectId:
          _toInt(json['subjectId']) ?? 0,

      subjectName:
          json['subjectName']?.toString(),

      subjectCode:
          json['subjectCode']?.toString(),

      subjectTeacherId:
          _toInt(json['subjectTeacherId']),

      subjectTeacherName:
          json['subjectTeacherName']?.toString(),

      examDate:
          _toDateTime(json['examDate']),

      startTime:
          json['startTime']?.toString(),

      duration:
          _toInt(json['duration']) ?? 0,

      maxMarks:
          _toInt(json['maxMarks']) ?? 0,

      examType:
          json['examType']?.toString() ?? '',

      roomNumber:
          json['roomNumber']?.toString(),

      status:
          json['status']?.toString(),

      createdAt:
          _toDateTime(json['createdAt']),

      updatedAt:
          _toDateTime(json['updatedAt']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}