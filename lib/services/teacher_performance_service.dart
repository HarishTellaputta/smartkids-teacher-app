import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/teacher_performance_model.dart';

class TeacherPerformanceService {
  final Dio _dio;

  TeacherPerformanceService(String token)
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
  // GET LOGGED-IN TEACHER PERFORMANCE
  // ============================================================

  Future<List<TeacherPerformanceModel>> getMyPerformance() async {
    debugPrint('========================================');
    debugPrint(
      'TEACHER PERFORMANCE API: '
      'GET /api/v1/teachers/me/performance',
    );

    try {
      final response = await _dio.get(
        '/api/v1/teachers/me/performance',
      );

      debugPrint(
        'Teacher Performance Status: ${response.statusCode}',
      );

      debugPrint(
        'Teacher Performance Response: ${response.data}',
      );

      final data = response.data;

      if (data is List) {
        debugPrint(
          'Performance records received: ${data.length}',
        );

        final performances = data
            .map(
              (json) => TeacherPerformanceModel.fromJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        debugPrint(
          'Performance records parsed: ${performances.length}',
        );

        for (final performance in performances) {
          debugPrint(
            'PERFORMANCE -> '
            'Class: ${performance.className}, '
            'Section: ${performance.sectionName}, '
            'Subject: ${performance.subjectName}, '
            'Exam: ${performance.latestExamName}, '
            'Average: ${performance.averageMarks}, '
            'Percentage: ${performance.performancePercentage}%',
          );
        }

        debugPrint('========================================');

        return performances;
      }

      debugPrint(
        'WARNING: Teacher performance response is not a List',
      );

      debugPrint('========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('TEACHER PERFORMANCE API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint('TEACHER PERFORMANCE ERROR: $e');
      debugPrint('========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET LOGGED-IN TEACHER SUBJECT PERFORMANCE HISTORY
  // ============================================================

  Future<List<TeacherPerformanceModel>>
      getMySubjectPerformance() async {
    debugPrint('========================================');
    debugPrint(
      'TEACHER SUBJECT PERFORMANCE API: '
      'GET /api/v1/teachers/me/performance/subjects',
    );

    try {
      final response = await _dio.get(
        '/api/v1/teachers/me/performance/subjects',
      );

      debugPrint(
        'Teacher Subject Performance Status: '
        '${response.statusCode}',
      );

      debugPrint(
        'Teacher Subject Performance Response: '
        '${response.data}',
      );

      final data = response.data;

      if (data is List) {
        debugPrint(
          'Subject performance records received: '
          '${data.length}',
        );

        final performances = data
            .map(
              (json) => TeacherPerformanceModel.fromSubjectJson(
                Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        debugPrint(
          'Subject performance records parsed: '
          '${performances.length}',
        );

        debugPrint('========================================');

        return performances;
      }

      debugPrint(
        'WARNING: Subject performance response is not a List',
      );

      debugPrint('========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('TEACHER SUBJECT PERFORMANCE API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('========================================');

      rethrow;
    } catch (e) {
      debugPrint(
        'TEACHER SUBJECT PERFORMANCE ERROR: $e',
      );
      debugPrint('========================================');

      rethrow;
    }
  }
}