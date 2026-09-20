class StudentSectionAssignmentModel {
  final int id;
  final int studentId;
  final int sectionId;
  final int academicYearId;

  StudentSectionAssignmentModel({
    required this.id,
    required this.studentId,
    required this.sectionId,
    required this.academicYearId,
  });

  factory StudentSectionAssignmentModel.fromJson(Map<String, dynamic> json) {
    return StudentSectionAssignmentModel(
      id: json['id'] ?? 0,
      studentId: json['studentId'] ?? 0,
      sectionId: json['sectionId'] ?? 0,
      academicYearId: json['academicYearId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'sectionId': sectionId,
      'academicYearId': academicYearId,
    };
  }
}
