import 'package:dio/dio.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final Dio _dio;

  AttendanceService(String token)
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

  Future<List<AttendanceModel>> markBulkAttendance({
    required int classId,
    required int teacherId,
    required String attendanceDate,
    required List<Map<String, dynamic>> attendanceRecords,
  }) async {
    print('========== BULK ATTENDANCE ==========');
    print('URL: ${_dio.options.baseUrl}/api/v1/attendances/bulk');
    print('Class ID: $classId');
    print('Teacher ID: $teacherId');
    print('Date: $attendanceDate');
    print('Records: $attendanceRecords');
    print('=====================================');

    final response = await _dio.post(
      '/api/v1/attendances/bulk',
      data: {
        'classId': classId,
        'teacherId': teacherId,
        'attendanceDate': attendanceDate,
        'attendanceRecords': attendanceRecords,
      },
    );

    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.data}');

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => AttendanceModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }

    return [];
  }

  // Get attendance for a class on a specific date
  Future<List<AttendanceModel>> getClassAttendance({
    required int classId,
    required String date,
  }) async {
    final response = await _dio.get(
      '/api/v1/attendances/class/$classId',
      queryParameters: {'date': date},
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => AttendanceModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }

    return [];
  }

  // Update already marked attendance
  Future<AttendanceModel> updateAttendance({
    required int attendanceId,
    required int teacherId,
    required String status,
    String? remarks,
  }) async {
    final response = await _dio.put(
      '/api/v1/attendances/$attendanceId',
      data: {
        'teacherId': teacherId,
        'status': status,
        'remarks': remarks ?? '',
      },
    );

    return AttendanceModel.fromJson(Map<String, dynamic>.from(response.data));
  }
}
