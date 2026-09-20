import 'package:flutter/material.dart';

import 'class_students_screen.dart';

class StudentListScreen extends StatelessWidget {
  final int classId;
  final String className;
  final String subject;

  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return ClassStudentsScreen(
      classId: classId,
      className: className,
      subject: subject,
      openAttendance: false,
    );
  }
}