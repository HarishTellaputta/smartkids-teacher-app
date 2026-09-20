import 'package:dio/dio.dart';

import '../models/section_model.dart';

class SectionService {
  final Dio _dio;

  SectionService(String token)
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

  // Get section by ID
  Future<SectionModel> getSectionById(int sectionId) async {
    final response = await _dio.get('/api/v1/sections/$sectionId');

    return SectionModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  // Get all sections
  Future<List<SectionModel>> getAllSections() async {
    final response = await _dio.get('/api/v1/sections');

    final data = response.data;

    if (data is List) {
      return data
          .map((json) => SectionModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    return [];
  }

  // Get sections by class ID
  Future<List<SectionModel>> getSectionsByClassId(int classId) async {
    final response = await _dio.get('/api/v1/sections/class/$classId');

    final data = response.data;

    if (data is List) {
      return data
          .map((json) => SectionModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    return [];
  }
}
