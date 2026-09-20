class ExaminationModel {
  final int id;
  final int? academicYearId;
  final String? academicYearName;
  final String name;
  final String? description;
  final String examType;
  final int? year;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExaminationModel({
    required this.id,
    this.academicYearId,
    this.academicYearName,
    required this.name,
    this.description,
    required this.examType,
    this.year,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ExaminationModel.fromJson(Map<String, dynamic> json) {
    return ExaminationModel(
      id: _toInt(json['id']) ?? 0,
      academicYearId: _toInt(json['academicYearId']),
      academicYearName: json['academicYearName']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      examType: json['examType']?.toString() ?? '',
      year: _toInt(json['year']),
      status: json['status']?.toString(),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}