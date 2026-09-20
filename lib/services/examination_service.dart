import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:teacher_app/models/exam_schedule_model.dart';
import 'package:teacher_app/models/examination_model.dart';
import 'package:teacher_app/models/exam_result_model.dart';


class ExaminationService {
  final Dio _dio;

  ExaminationService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.51.231.80:8080',
            connectTimeout:
                const Duration(seconds: 15),
            receiveTimeout:
                const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

  // ============================================================
  // GET EXAMINATIONS
  // ============================================================

  Future<List<ExaminationModel>>
      getExaminations({
    int? academicYearId,
  }) async {
    debugPrint(
      '========== GET EXAMINATIONS ==========',
    );

    try {
      final response = await _dio.get(
        '/api/v1/examinations',
        queryParameters: academicYearId == null
            ? null
            : {
                'academicYearId':
                    academicYearId,
              },
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      final data = response.data;

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (json) =>
                ExaminationModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError(
        'GET EXAMINATIONS',
        e,
      );
      rethrow;
    }
  }

  // ============================================================
  // GET SCHEDULES
  // ============================================================

  Future<List<ExamScheduleModel>>
      getSchedules({
    int? examinationId,
    int? classId,
    int? sectionId,
  }) async {
    debugPrint(
      '========== GET EXAM SCHEDULES ==========',
    );

    try {
      final Map<String, dynamic> params =
          {};

      if (examinationId != null) {
        params['examinationId'] =
            examinationId;
      }

      if (classId != null) {
        params['classId'] = classId;
      }

      if (sectionId != null) {
        params['sectionId'] =
            sectionId;
      }

      final response = await _dio.get(
        '/api/v1/examinations/schedules',
        queryParameters:
            params.isEmpty ? null : params,
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      final data = response.data;

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (json) =>
                ExamScheduleModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError(
        'GET EXAM SCHEDULES',
        e,
      );
      rethrow;
    }
  }

  // ============================================================
  // GET RESULTS
  // ============================================================

  Future<List<ExamResultModel>>
      getResults({
    int? scheduleId,
    int? studentId,
  }) async {
    debugPrint(
      '========== GET EXAM RESULTS ==========',
    );

    try {
      final Map<String, dynamic> params =
          {};

      if (scheduleId != null) {
        params['scheduleId'] =
            scheduleId;
      }

      if (studentId != null) {
        params['studentId'] =
            studentId;
      }

      final response = await _dio.get(
        '/api/v1/examinations/results',
        queryParameters:
            params.isEmpty ? null : params,
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      final data = response.data;

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (json) =>
                ExamResultModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError(
        'GET EXAM RESULTS',
        e,
      );
      rethrow;
    }
  }

  // ============================================================
  // GET GRADE RULES
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getGradeRules() async {
    debugPrint(
      '========== GET GRADE RULES ==========',
    );

    try {
      final response = await _dio.get(
        '/api/v1/examinations/grade-rules',
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      final data = response.data;

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (json) => Map<String, dynamic>.from(
              json,
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError(
        'GET GRADE RULES',
        e,
      );
      rethrow;
    }
  }

  // ============================================================
  // ENTER MARKS
  // ============================================================

  Future<ExamResultModel> enterMarks({
    required int examScheduleId,
    required int studentId,
    required int teacherId,
    required int marksObtained,
    int? maxMarks,
    String? grade,
    String? remarks,
    String? status,
  }) async {
    debugPrint(
      '========== ENTER EXAM MARKS ==========',
    );

    final body = {
      'examScheduleId':
          examScheduleId,
      'studentId': studentId,
      'teacherId': teacherId,
      'marksObtained':
          marksObtained,
      if (maxMarks != null)
        'maxMarks': maxMarks,
      if (grade != null)
        'grade': grade,
      if (remarks != null &&
          remarks.trim().isNotEmpty)
        'remarks': remarks.trim(),
      if (status != null)
        'status': status,
    };

    debugPrint(
      'Request Body: $body',
    );

    try {
      final response = await _dio.post(
        '/api/v1/examinations/results',
        data: body,
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      return ExamResultModel.fromJson(
        Map<String, dynamic>.from(
          response.data,
        ),
      );
    } on DioException catch (e) {
      _logError(
        'ENTER EXAM MARKS',
        e,
      );
      rethrow;
    }
  }

  void _logError(
    String operation,
    DioException e,
  ) {
    debugPrint(
      '========== $operation ERROR ==========',
    );
    debugPrint(
      'URL: ${e.requestOptions.uri}',
    );
    debugPrint(
      'Status: ${e.response?.statusCode}',
    );
    debugPrint(
      'Response: ${e.response?.data}',
    );
    debugPrint(
      'Message: ${e.message}',
    );
    debugPrint(
      '======================================',
    );
  }
}