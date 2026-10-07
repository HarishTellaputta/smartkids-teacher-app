import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/teacher_leave_model.dart';

class TeacherLeaveService {
  final Dio _dio;

  TeacherLeaveService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.24.241.80:8080',
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

  Future<List<TeacherLeaveModel>>
      getMyLeaves(int teacherId) async {
    debugPrint(
      '========== GET MY LEAVES ==========',
    );
    debugPrint('Teacher ID: $teacherId');

    try {
      final response = await _dio.get(
        '/api/v1/teacher-leaves/teacher/$teacherId',
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
            (json) => TeacherLeaveModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError('GET MY LEAVES', e);
      rethrow;
    }
  }

  Future<TeacherLeaveModel> applyLeave({
    required int teacherId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    debugPrint(
      '========== APPLY LEAVE ==========',
    );

    final body = {
      'teacherId': teacherId,
      'leaveType': leaveType,
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      if (reason != null &&
          reason.trim().isNotEmpty)
        'reason': reason.trim(),
    };

    debugPrint('Request Body: $body');

    try {
      final response = await _dio.post(
        '/api/v1/teacher-leaves',
        data: body,
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      return TeacherLeaveModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      _logError('APPLY LEAVE', e);
      rethrow;
    }
  }

  Future<TeacherLeaveModel> updateLeave({
    required int leaveId,
    required int teacherId,
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    final body = {
      'teacherId': teacherId,
      'leaveType': leaveType,
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      if (reason != null &&
          reason.trim().isNotEmpty)
        'reason': reason.trim(),
    };

    debugPrint(
      '========== UPDATE LEAVE ==========',
    );
    debugPrint('Leave ID: $leaveId');
    debugPrint('Request Body: $body');

    try {
      final response = await _dio.put(
        '/api/v1/teacher-leaves/$leaveId',
        data: body,
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
      debugPrint(
        'Response: ${response.data}',
      );

      return TeacherLeaveModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      _logError('UPDATE LEAVE', e);
      rethrow;
    }
  }

  Future<void> deleteLeave(int leaveId) async {
    debugPrint(
      '========== DELETE LEAVE ==========',
    );
    debugPrint('Leave ID: $leaveId');

    try {
      final response = await _dio.delete(
        '/api/v1/teacher-leaves/$leaveId',
      );

      debugPrint(
        'Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      _logError('DELETE LEAVE', e);
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final month =
        date.month.toString().padLeft(2, '0');
    final day =
        date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
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