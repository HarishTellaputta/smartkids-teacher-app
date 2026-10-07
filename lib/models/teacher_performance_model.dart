class TeacherPerformanceModel {
  final int classId;
  final String className;
  final int? sectionId;
  final String? sectionName;
  final int subjectId;
  final String subjectName;
  final String? subjectCode;

  // Latest-performance API fields
  final int? latestExamScheduleId;
  final String? latestExamName;

  // Subject-history API field
  final int? examScheduleId;
  final String? examName;

  final DateTime? examDate;
  final int studentCount;
  final int assessedCount;
  final double averageMarks;
  final int maxMarks;
  final double performancePercentage;

  TeacherPerformanceModel({
    required this.classId,
    required this.className,
    this.sectionId,
    this.sectionName,
    required this.subjectId,
    required this.subjectName,
    this.subjectCode,
    this.latestExamScheduleId,
    this.latestExamName,
    this.examScheduleId,
    this.examName,
    this.examDate,
    required this.studentCount,
    required this.assessedCount,
    required this.averageMarks,
    required this.maxMarks,
    required this.performancePercentage,
  });

  // ------------------------------------------------------------
  // GET /api/v1/teachers/me/performance
  // ------------------------------------------------------------
  factory TeacherPerformanceModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TeacherPerformanceModel(
      classId: _toInt(json['classId']),
      className: json['className']?.toString() ?? '',

      sectionId: _toNullableInt(json['sectionId']),
      sectionName: json['sectionName']?.toString(),

      subjectId: _toInt(json['subjectId']),
      subjectName: json['subjectName']?.toString() ?? '',
      subjectCode: json['subjectCode']?.toString(),

      latestExamScheduleId:
          _toNullableInt(json['latestExamScheduleId']),
      latestExamName:
          json['latestExamName']?.toString(),

      examScheduleId: null,
      examName: null,

      examDate: _toDateTime(json['examDate']),

      studentCount: _toInt(json['studentCount']),
      assessedCount: _toInt(json['assessedCount']),

      averageMarks: _toDouble(json['averageMarks']),
      maxMarks: _toInt(json['maxMarks']),

      performancePercentage:
          _toDouble(json['performancePercentage']),
    );
  }

  // ------------------------------------------------------------
  // GET /api/v1/teachers/me/performance/subjects
  // ------------------------------------------------------------
  factory TeacherPerformanceModel.fromSubjectJson(
    Map<String, dynamic> json,
  ) {
    return TeacherPerformanceModel(
      classId: _toInt(json['classId']),
      className: json['className']?.toString() ?? '',

      sectionId: _toNullableInt(json['sectionId']),
      sectionName: json['sectionName']?.toString(),

      subjectId: _toInt(json['subjectId']),
      subjectName: json['subjectName']?.toString() ?? '',
      subjectCode: json['subjectCode']?.toString(),

      latestExamScheduleId: null,
      latestExamName: null,

      examScheduleId:
          _toNullableInt(json['examScheduleId']),
      examName:
          json['examName']?.toString(),

      examDate: _toDateTime(json['examDate']),

      studentCount: _toInt(json['studentCount']),
      assessedCount: _toInt(json['assessedCount']),

      averageMarks: _toDouble(json['averageMarks']),
      maxMarks: _toInt(json['maxMarks']),

      performancePercentage:
          _toDouble(json['performancePercentage']),
    );
  }

  // ------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------

  static int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }

  // ------------------------------------------------------------
  // Convenient exam name getter
  // ------------------------------------------------------------

  String get displayExamName {
    if (latestExamName != null &&
        latestExamName!.trim().isNotEmpty) {
      return latestExamName!;
    }

    if (examName != null &&
        examName!.trim().isNotEmpty) {
      return examName!;
    }

    return 'Exam';
  }

  int get displayExamScheduleId {
    return latestExamScheduleId ?? examScheduleId ?? 0;
  }
}