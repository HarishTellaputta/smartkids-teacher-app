class SchoolNoticeModel {
  final int id;
  final String title;
  final String content;
  final String audience;
  final String category;
  final String status;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? sectionName;
  final String? publishedAt;
  final String? createdAt;

  SchoolNoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.audience,
    required this.category,
    required this.status,
    this.classId,
    this.sectionId,
    this.className,
    this.sectionName,
    this.publishedAt,
    this.createdAt,
  });

  factory SchoolNoticeModel.fromJson(Map<String, dynamic> json) {
    return SchoolNoticeModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      audience: json['audience'] ?? '',
      category: json['category'] ?? 'General',
      status: json['status'] ?? '',
      classId: json['classId'],
      sectionId: json['sectionId'],
      className: json['className'],
      sectionName: json['sectionName'],
      publishedAt: json['publishedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}