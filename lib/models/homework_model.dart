class HomeworkModel {
  final int? id;
  final int? classId;
  final String? className;
  final int? sectionId;
  final String? sectionName;

  final int? assignedByTeacherId;
  final String? assignedByTeacherName;
  final String? teacherEmployeeId;

  final int? subjectId;
  final String? subjectName;
  final String? subjectCode;

  final String? title;
  final String? description;
  final String? dueDate;
  final String? status;
  final String? attachmentUrl;
  final String? priority;

  final String? createdAt;
  final String? updatedAt;

  HomeworkModel({
    this.id,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.assignedByTeacherId,
    this.assignedByTeacherName,
    this.teacherEmployeeId,
    this.subjectId,
    this.subjectName,
    this.subjectCode,
    this.title,
    this.description,
    this.dueDate,
    this.status,
    this.attachmentUrl,
    this.priority,
    this.createdAt,
    this.updatedAt,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      id: json['id'],
      classId: json['classId'],
      className: json['className'],
      sectionId: json['sectionId'],
      sectionName: json['sectionName'],
      assignedByTeacherId: json['assignedByTeacherId'],
      assignedByTeacherName: json['assignedByTeacherName'],
      teacherEmployeeId: json['teacherEmployeeId'],
      subjectId: json['subjectId'],
      subjectName: json['subjectName'],
      subjectCode: json['subjectCode'],
      title: json['title'],
      description: json['description'],
      dueDate: json['dueDate']?.toString(),
      status: json['status'],
      attachmentUrl: json['attachmentUrl'],
      priority: json['priority'],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}