import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/class_model.dart';

class ClassService {
  final Dio _dio;

  ClassService(String token)
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

  // Get class by ID
  Future<ClassModel> getClassById(int classId) async {
    debugPrint('========== GET CLASS BY ID ==========');
    debugPrint('Class ID: $classId');
    debugPrint('URL: /api/v1/classes/$classId');

    try {
      final response = await _dio.get('/api/v1/classes/$classId');

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final classModel = ClassModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );

      debugPrint('CLASS LOADED: ID=${classModel.id}, Name=${classModel.name}');
      debugPrint('====================================');

      return classModel;
    } on DioException catch (e) {
      debugPrint('CLASS API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('====================================');

      rethrow;
    } catch (e) {
      debugPrint('CLASS PARSING ERROR: $e');
      debugPrint('====================================');

      rethrow;
    }
  }

  // Get all classes
  Future<List<ClassModel>> getAllClasses() async {
    debugPrint('========== GET ALL CLASSES ==========');
    debugPrint('URL: /api/v1/classes');

    try {
      final response = await _dio.get('/api/v1/classes');

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response type: ${response.data.runtimeType}');

      final data = response.data;

      if (data is List) {
        debugPrint('Classes received: ${data.length}');

        final classes = data
            .map((json) => ClassModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        debugPrint('Classes parsed successfully: ${classes.length}');

        for (final classModel in classes) {
          debugPrint('Class -> ID: ${classModel.id}, Name: ${classModel.name}');
        }

        debugPrint('====================================');

        return classes;
      }

      debugPrint('WARNING: Unexpected class response format');
      debugPrint('====================================');

      return [];
    } on DioException catch (e) {
      debugPrint('CLASS API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('====================================');

      rethrow;
    } catch (e) {
      debugPrint('CLASS ERROR: $e');
      debugPrint('====================================');

      rethrow;
    }
  }

  // Get classes by school ID
  Future<List<ClassModel>> getClassesBySchoolId(int schoolId) async {
    debugPrint('========== GET CLASSES BY SCHOOL ==========');
    debugPrint('School ID: $schoolId');
    debugPrint('URL: /api/v1/classes/school/$schoolId');

    try {
      final response = await _dio.get('/api/v1/classes/school/$schoolId');

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final data = response.data;

      if (data is List) {
        debugPrint('Classes found for school $schoolId: ${data.length}');

        final classes = data
            .map((json) => ClassModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        debugPrint('Classes parsed successfully: ${classes.length}');

        for (final classModel in classes) {
          debugPrint('Class -> ID: ${classModel.id}, Name: ${classModel.name}');
        }

        debugPrint('==========================================');

        return classes;
      }

      debugPrint('WARNING: School class response is not a List');
      debugPrint('==========================================');

      return [];
    } on DioException catch (e) {
      debugPrint('SCHOOL CLASS API ERROR');
      debugPrint('URL: ${e.requestOptions.uri}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      debugPrint('Message: ${e.message}');
      debugPrint('==========================================');

      rethrow;
    } catch (e) {
      debugPrint('SCHOOL CLASS ERROR: $e');
      debugPrint('==========================================');

      rethrow;
    }
  }
}
