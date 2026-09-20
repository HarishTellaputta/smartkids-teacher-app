class TeacherLeaveModel {
  final int id;
  final int? teacherId;
  final String? teacherName;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String status;
  final String? rejectionReason;
  final DateTime? appliedAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TeacherLeaveModel({
    required this.id,
    this.teacherId,
    this.teacherName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.reason,
    required this.status,
    this.rejectionReason,
    this.appliedAt,
    this.approvedAt,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory TeacherLeaveModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return TeacherLeaveModel(
      id: _parseInt(json['id']),
      teacherId: _parseNullableInt(json['teacherId']),
      teacherName: json['teacherName']?.toString(),
      leaveType: json['leaveType']?.toString() ?? 'Leave',
      startDate: DateTime.parse(
        json['startDate'].toString(),
      ),
      endDate: DateTime.parse(
        json['endDate'].toString(),
      ),
      reason: json['reason']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      rejectionReason:
          json['rejectionReason']?.toString(),
      appliedAt:
          _parseDateTime(json['appliedAt']),
      approvedAt:
          _parseDateTime(json['approvedAt']),
      approvedBy:
          json['approvedBy']?.toString(),
      createdAt:
          _parseDateTime(json['createdAt']),
      updatedAt:
          _parseDateTime(json['updatedAt']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
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