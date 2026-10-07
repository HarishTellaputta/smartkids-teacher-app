class StudentBirthdayStatusModel {
  final int id;
  final int? studentId;
  final String? studentName;
  final String? className;
  final String? section;
  final String? dateOfBirth;
  final String? birthdayDate;
  final int? age;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;

  StudentBirthdayStatusModel({
    required this.id,
    this.studentId,
    this.studentName,
    this.className,
    this.section,
    this.dateOfBirth,
    this.birthdayDate,
    this.age,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentBirthdayStatusModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return StudentBirthdayStatusModel(
      id: _toInt(json['id']) ?? 0,
      studentId: _toInt(json['studentId']),
      studentName: _string(json['studentName']),
      className: _string(json['className']),
      section: _string(json['section']),
      dateOfBirth: _string(json['dateOfBirth']),
      birthdayDate: _string(json['birthdayDate']),
      age: _toInt(json['age']),
      active: json['active'] as bool?,
      createdAt: _string(json['createdAt']),
      updatedAt: _string(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'section': section,
      'dateOfBirth': dateOfBirth,
      'birthdayDate': birthdayDate,
      'age': age,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static String? _string(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }
}