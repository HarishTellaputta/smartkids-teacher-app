class TodayClassModel {
  final String startTime;
  final String endTime;
  final String className;
  final String section;
  final String subject;

  TodayClassModel({
    required this.startTime,
    required this.endTime,
    required this.className,
    required this.section,
    required this.subject,
  });

  factory TodayClassModel.fromJson(Map<String, dynamic> json) {
    return TodayClassModel(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      className: json['className'] ?? '',
      section: json['section'] ?? '',
      subject: json['subject'] ?? '',
    );
  }
}
