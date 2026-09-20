import 'package:dio/dio.dart';

import '../models/teacher_assignment_model.dart';
import '../models/teacher_timetable_model.dart';

class TeacherService {
  final Dio _dio;

  TeacherService(String token)
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://10.51.231.80:8080',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

  // Get all classes/subjects assigned to teacher
  Future<List<TeacherAssignmentModel>> getTeacherAssignments(
    int teacherId,
  ) async {
    final response = await _dio.get(
      '/api/v1/teacher-class-assignments/teacher/$teacherId',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => TeacherAssignmentModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    return [];
  }

  // Get subjects assigned to teacher
  Future<List<String>> getTeacherSubjects(int teacherId) async {
    final response = await _dio.get(
      '/api/v1/teacher-class-assignments/teacher/$teacherId/subjects',
    );

    final data = response.data;

    if (data is List) {
      return data.map((item) => item.toString()).toList();
    }

    return [];
  }

  // Get today's timetable for teacher
  Future<List<TeacherTimetableModel>> getTodayTimetable(int teacherId) async {
    final now = DateTime.now();

    final dayOfWeek = _getDayOfWeek(now.weekday);

    print('================ TODAY TIMETABLE ================');
    print('Teacher ID : $teacherId');
    print('Day        : $dayOfWeek');

    final response = await _dio.get(
      '/api/v1/teacher-timetables/teacher/$teacherId/day/$dayOfWeek',
    );

    print('Status : ${response.statusCode}');
    print('Data   : ${response.data}');

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) =>
                TeacherTimetableModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }

    return [];
  }

  String _getDayOfWeek(int weekday) {
    const days = [
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY',
      'SATURDAY',
      'SUNDAY',
    ];

    return days[weekday - 1];
  }

  Future<List<TeacherTimetableModel>> getTeacherTimetable(int teacherId) async {
    final response = await _dio.get(
      '/api/v1/teacher-timetables/teacher/$teacherId',
    );

    print('========== FULL TIMETABLE ==========');
    print('Teacher ID: $teacherId');
    print('Status: ${response.statusCode}');
    print('Data: ${response.data}');
    print('====================================');

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) =>
                TeacherTimetableModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> getTeacherByUserId(int userId) async {
    final response = await _dio.get('/api/v1/teachers/by-user/$userId');

    return Map<String, dynamic>.from(response.data);
  }
}
