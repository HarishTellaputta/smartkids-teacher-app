class ClassModel {
  final int id;
  final int schoolId;
  final String name;
  final String code;
  final String grade;
  final int year;
  final String description;

  ClassModel({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.code,
    required this.grade,
    required this.year,
    required this.description,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? 0,
      schoolId: json['schoolId'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      grade: json['grade']?.toString() ?? '',
      year: json['year'] ?? 0,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'name': name,
      'code': code,
      'grade': grade,
      'year': year,
      'description': description,
    };
  }
}
