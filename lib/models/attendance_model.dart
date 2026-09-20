class AttendanceModel {
  final int? id;
  final int studentId;
  final String? studentName;
  final String? studentRollNumber;
  final int classId;
  final String? className;
  final int? teacherId;
  final String? teacherName;
  final String attendanceDate;
  final String status;
  final String? remarks;

  AttendanceModel({
    this.id,
    required this.studentId,
    this.studentName,
    this.studentRollNumber,
    required this.classId,
    this.className,
    this.teacherId,
    this.teacherName,
    required this.attendanceDate,
    required this.status,
    this.remarks,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'],
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'],
      studentRollNumber: json['studentRollNumber'],
      classId: json['classId'] ?? 0,
      className: json['className'],
      teacherId: json['markedByTeacherId'] ?? json['teacherId'],
      teacherName: json['markedByTeacherName'],
      attendanceDate: json['attendanceDate']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      remarks: json['remarks'],
    );
  }
}