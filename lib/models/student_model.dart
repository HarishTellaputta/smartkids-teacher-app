
class StudentModel {
  final int id;
  final String admissionNo;
  final String rollNumber;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final String gender;
  final String bloodGroup;
  final String admissionDate;

  final int classId;
  final String className;

  final int sectionId;
  final String sectionName;

  final int parentId;
  final String parentName;

  final int academicYearId;
  final String academicYearName;

  final String status;
  final String address;

  final String createdAt;
  final String updatedAt;
  final bool transportRequired;

  StudentModel({
    required this.id,
    required this.admissionNo,
    required this.rollNumber,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodGroup,
    required this.admissionDate,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.parentId,
    required this.parentName,
    required this.academicYearId,
    required this.academicYearName,
    required this.status,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
    required this.transportRequired,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    String parseString(dynamic value) {
      return value?.toString() ?? '';
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;

      return value?.toString().toLowerCase() == 'true';
    }

    return StudentModel(
      id: parseInt(json['id']),
      admissionNo: parseString(json['admissionNo']),
      rollNumber: parseString(json['rollNumber']),
      name: parseString(json['name']),
      email: parseString(json['email']),
      phone: parseString(json['phone']),
      dateOfBirth: parseString(json['dateOfBirth']),
      gender: parseString(json['gender']),
      bloodGroup: parseString(json['bloodGroup']),
      admissionDate: parseString(json['admissionDate']),

      classId: parseInt(json['classId']),
      className: parseString(json['className']),

      sectionId: parseInt(json['sectionId']),
      sectionName: parseString(json['sectionName']),

      parentId: parseInt(json['parentId']),
      parentName: parseString(json['parentName']),

      academicYearId: parseInt(json['academicYearId']),
      academicYearName: parseString(json['academicYearName']),

      status: parseString(json['status']),
      address: parseString(json['address']),

      createdAt: parseString(json['createdAt']),
      updatedAt: parseString(json['updatedAt']),
      transportRequired: parseBool(json['transportRequired']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admissionNo': admissionNo,
      'rollNumber': rollNumber,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'admissionDate': admissionDate,
      'classId': classId,
      'className': className,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'parentId': parentId,
      'parentName': parentName,
      'academicYearId': academicYearId,
      'academicYearName': academicYearName,
      'status': status,
      'address': address,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'transportRequired': transportRequired,
    };
  }
}
