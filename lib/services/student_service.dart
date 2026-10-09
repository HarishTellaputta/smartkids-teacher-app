import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/student_model.dart';

class StudentService {
  final Dio _dio;

  StudentService(String token)
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'http://10.24.241.80:8080',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

  // ============================================================
  // GET STUDENT BY ID
  // ============================================================

  Future<StudentModel> getStudentById(int studentId) async {
    debugPrint('========================================');
    debugPrint('STUDENT API: GET /students/$studentId');
    debugPrint('Student ID: $studentId');

    try {
      final response = await _dio.get('/api/v1/students/$studentId');

      debugPrint('Student API Status: ${response.statusCode}');
      debugPrint('Student API Response: ${response.data}');

      final student = StudentModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      debugPrint('STUDENT LOADED: ID=${student.id}, Name=${student.name}');

      debugPrint('========================================');

      return student;
    } on DioException catch (e) {
      debugPrint('STUDENT API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('STUDENT PARSING ERROR: $e');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET ALL STUDENTS
  // ============================================================

  Future<List<StudentModel>> getAllStudents() async {
    debugPrint('========================================');
    debugPrint('STUDENT API: GET /students');

    try {
      final response = await _dio.get('/students');

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response type: ${response.data.runtimeType}');

      final data = response.data;

      // Direct list response
      if (data is List) {
        debugPrint('Student list response received');
        debugPrint('Student count: ${data.length}');

        final students = data
            .map(
              (json) => StudentModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        debugPrint('Students parsed successfully: ${students.length}');

        debugPrint('========================================');

        return students;
      }

      // Spring Page response
      if (data is Map && data['content'] is List) {
        final content = data['content'] as List;

        debugPrint('Spring Page response received');
        debugPrint('Student count: ${content.length}');

        final students = content
            .map(
              (json) => StudentModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        debugPrint('Students parsed successfully: ${students.length}');

        debugPrint('========================================');

        return students;
      }

      debugPrint('WARNING: Unexpected student response format');
      debugPrint('========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('STUDENT API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('STUDENT ERROR: $e');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS WITH PAGINATION
  // ============================================================

  Future<List<StudentModel>> getStudents({
    int page = 0,
    int size = 50,
    String sortBy = 'name',
    String sortDirection = 'asc',
  }) async {
    debugPrint('========================================');
    debugPrint('STUDENT API: GET /students');
    debugPrint(
      'page=$page, size=$size, sortBy=$sortBy, '
      'sortDirection=$sortDirection',
    );

    try {
      final response = await _dio.get(
        '/students',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
        },
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response type: ${response.data.runtimeType}');

      final data = response.data;

      if (data is List) {
        debugPrint('Direct list response');
        debugPrint('Student count: ${data.length}');

        final students = data
            .map(
              (json) => StudentModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        debugPrint('Students parsed: ${students.length}');
        debugPrint('========================================');

        return students;
      }

      if (data is Map && data['content'] is List) {
        final content = data['content'] as List;

        debugPrint('Spring Page response');
        debugPrint('Student count: ${content.length}');

        final students = content
            .map(
              (json) => StudentModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        debugPrint('Students parsed: ${students.length}');
        debugPrint('========================================');

        return students;
      }

      debugPrint('WARNING: Unexpected response format');
      debugPrint('========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('STUDENT API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('STUDENT ERROR: $e');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS BY CLASS ID
  // ============================================================

  Future<List<StudentModel>> getStudentsByClassId(int classId) async {
    debugPrint('========================================');
    debugPrint('STUDENT API: GET /students/class/$classId');
    debugPrint('Class ID: $classId');

    try {
      final response = await _dio.get('/api/v1/students/class/$classId');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final data = response.data;

      if (data is List) {
        debugPrint('Students found for class $classId: ${data.length}');

        final students = data
            .map(
              (json) => StudentModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        debugPrint('Students parsed successfully: ${students.length}');

        for (final student in students) {
          debugPrint(
            'Student -> ID: ${student.id}, '
            'Name: ${student.name}, '
            'Roll: ${student.rollNumber}',
          );
        }

        debugPrint('========================================');

        return students;
      }

      debugPrint('WARNING: Class student response is not a List');

      debugPrint('========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('CLASS STUDENT API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('CLASS STUDENT ERROR: $e');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET STUDENTS BY SECTION ID
  // ============================================================

  Future<List<StudentModel>> getStudentsBySectionId(int sectionId) async {
    debugPrint('========================================');
    debugPrint('STUDENT API: GET /students/section/$sectionId');
    debugPrint('Section ID: $sectionId');

    try {
      final response = await _dio.get('/api/v1/students/section/$sectionId');

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final data = response.data;

      if (data is List) {
        debugPrint('Students found for section $sectionId: ${data.length}');

        final students = data
            .map(
              (json) => StudentModel.fromJson(Map<String, dynamic>.from(json)),
            )
            .toList();

        for (final student in students) {
          debugPrint(
            'Student -> '
            'ID: ${student.id}, '
            'Name: ${student.name}, '
            'Roll: ${student.rollNumber}',
          );
        }

        debugPrint('========================================');

        return students;
      }

      debugPrint('WARNING: Response is not a List');
      debugPrint('========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('SECTION STUDENT API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('SECTION STUDENT ERROR: $e');
      debugPrint('========================================');

      rethrow;
    }
  }
}
