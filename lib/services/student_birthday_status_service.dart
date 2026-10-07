import 'package:dio/dio.dart';

import '../models/student_birthday_status_model.dart';

class StudentBirthdayStatusService {
  final Dio _dio;

  StudentBirthdayStatusService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.24.241.80:8080',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

  // =========================================================
  // GET TODAY'S BIRTHDAYS
  // =========================================================

  Future<List<StudentBirthdayStatusModel>>
      getTodayBirthdays() async {
    final response = await _dio.get(
      '/api/v1/student-birthday-status/today',
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (json) =>
              StudentBirthdayStatusModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // =========================================================
  // GET ALL BIRTHDAY STATUS
  // =========================================================

  Future<List<StudentBirthdayStatusModel>>
      getAllBirthdays() async {
    final response = await _dio.get(
      '/api/v1/student-birthday-status',
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (json) =>
              StudentBirthdayStatusModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // =========================================================
  // GET BY ID
  // =========================================================

  Future<StudentBirthdayStatusModel>
      getBirthdayById(
    int id,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-birthday-status/$id',
    );

    return StudentBirthdayStatusModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // =========================================================
  // GET STUDENT BIRTHDAY HISTORY
  // =========================================================

  Future<List<StudentBirthdayStatusModel>>
      getStudentBirthdayHistory(
    int studentId,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-birthday-status/student/$studentId',
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (json) =>
              StudentBirthdayStatusModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }
}