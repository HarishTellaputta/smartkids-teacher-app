class ExamResultModel {
  final int id;

  final int examScheduleId;
  final int studentId;

  final String? studentName;
  final String? studentRollNumber;

  final int? markedByTeacherId;
  final String? markedByTeacherName;

  final int marksObtained;
  final int? maxMarks;

  final double? percentage;
  final String? grade;

  final int? classRank;
  final int? sectionRank;

  final String? remarks;
  final String? status;

  final bool? isPublished;

  final DateTime? markedAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExamResultModel({
    required this.id,
    required this.examScheduleId,
    required this.studentId,
    this.studentName,
    this.studentRollNumber,
    this.markedByTeacherId,
    this.markedByTeacherName,
    required this.marksObtained,
    this.maxMarks,
    this.percentage,
    this.grade,
    this.classRank,
    this.sectionRank,
    this.remarks,
    this.status,
    this.isPublished,
    this.markedAt,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ExamResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExamResultModel(
      id: _toInt(json['id']) ?? 0,

      examScheduleId:
          _toInt(json['examScheduleId']) ?? 0,

      studentId:
          _toInt(json['studentId']) ?? 0,

      studentName:
          json['studentName']?.toString(),

      studentRollNumber:
          json['studentRollNumber']?.toString(),

      markedByTeacherId:
          _toInt(json['markedByTeacherId']),

      markedByTeacherName:
          json['markedByTeacherName']?.toString(),

      marksObtained:
          _toInt(json['marksObtained']) ?? 0,

      maxMarks:
          _toInt(json['maxMarks']),

      percentage:
          _toDouble(json['percentage']),

      grade:
          json['grade']?.toString(),

      classRank:
          _toInt(json['classRank']),

      sectionRank:
          _toInt(json['sectionRank']),

      remarks:
          json['remarks']?.toString(),

      status:
          json['status']?.toString(),

      isPublished:
          _toBool(json['isPublished']),

      markedAt:
          _toDateTime(json['markedAt']),

      publishedAt:
          _toDateTime(json['publishedAt']),

      createdAt:
          _toDateTime(json['createdAt']),

      updatedAt:
          _toDateTime(json['updatedAt']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;

    if (value is bool) {
      return value;
    }

    return value.toString().toLowerCase() == 'true';
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}