
class CallParentModel {
  final int studentId;
  final String studentName;
  final String? admissionNo;

  final int? parentId;
  final String parentName;
  final String? parentPhone;

  final int? classId;
  final String? className;

  final int? sectionId;
  final String? sectionName;

  const CallParentModel({
    required this.studentId,
    required this.studentName,
    this.admissionNo,
    this.parentId,
    required this.parentName,
    this.parentPhone,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
  });

  factory CallParentModel.fromJson(
    Map<String, dynamic> json, {
    String? parentName,
    String? parentPhone,
  }) {
    return CallParentModel(
      studentId: _parseInt(json['id']) ?? 0,
      studentName: (json['name'] ?? '').toString(),
      admissionNo: json['admissionNo']?.toString(),

      parentId: _parseInt(json['parentId']),
      parentName: parentName ??
          (json['parentName'] ?? '').toString(),
      parentPhone: parentPhone,

      classId: _parseInt(json['classId']),
      className: json['className']?.toString(),

      sectionId: _parseInt(json['sectionId']),
      sectionName: json['sectionName']?.toString(),
    );
  }

  bool get canCallParent =>
      parentPhone != null && parentPhone!.trim().isNotEmpty;

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
