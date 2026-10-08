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
  final String address;
  final int sectionId;
  final int parentId;
  final int academicYearId;
  final String sectionName;
  final String parentName;
  final String academicYearName;
  final String status;

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
    required this.address,
    required this.sectionId,
    required this.parentId,
    required this.academicYearId,
    required this.sectionName,
    required this.parentName,
    required this.academicYearName,
    required this.status,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      admissionNo: json['admissionNo'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      admissionDate: json['admissionDate'] ?? '',
      address: json['address'] ?? '',
      sectionId: json['sectionId'] ?? 0,
      parentId: json['parentId'] ?? 0,
      academicYearId: json['academicYearId'] ?? 0,
      sectionName: json['sectionName'] ?? '',
      parentName: json['parentName'] ?? '',
      academicYearName: json['academicYearName'] ?? '',
      status: json['status'] ?? '',
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
      'address': address,
      'sectionId': sectionId,
      'parentId': parentId,
      'academicYearId': academicYearId,
      'sectionName': sectionName,
      'parentName': parentName,
      'academicYearName': academicYearName,
      'status': status,
    };
  }
}
