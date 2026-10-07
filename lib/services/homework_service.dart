import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/homework_model.dart';

class HomeworkService {
  static const String baseUrl = 'http://10.24.241.80:8080';

  final String token;

  HomeworkService(this.token);

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Get all homework for a class + section.
  Future<List<HomeworkModel>> getByClassAndSection(
    int classId,
    int sectionId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/homeworks/class/$classId/section/$sectionId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map(
            (json) => HomeworkModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();
    }

    throw Exception(
      'Failed to load homework '
      '(${response.statusCode}): ${response.body}',
    );
  }

  /// Get all homework assigned by a particular teacher,
  /// then filter it by class + section.
  ///
  /// Backend currently has:
  /// GET /api/v1/homeworks/teacher/{teacherId}
  ///
  /// There is NO:
  /// /teacher/{teacherId}/class/{classId}/section/{sectionId}
  Future<List<HomeworkModel>> getByTeacherClassAndSection(
    int teacherId,
    int classId,
    int sectionId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/homeworks/teacher/$teacherId'),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load teacher homework '
        '(${response.statusCode}): ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    final homeworkList = data
        .map((json) => HomeworkModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    // Filter teacher's homework for selected class + section.
    return homeworkList.where((homework) {
      return homework.classId == classId && homework.sectionId == sectionId;
    }).toList();
  }

  Future<HomeworkModel> createHomework({
    required int classId,
    required int sectionId,
    required int teacherId,
    int? subjectId,
    required String title,
    String? description,
    required String dueDate,
    String? status,
    String? attachmentUrl,
    String? priority,
  }) async {
    final body = {
      'classId': classId,
      'sectionId': sectionId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status ?? 'ACTIVE',
      'attachmentUrl': attachmentUrl,
      'priority': priority ?? 'MEDIUM',
    };

    print('========== CREATE HOMEWORK ==========');
    print('URL: $baseUrl/api/v1/homeworks');
    print('BODY: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/homeworks'),
      headers: _headers,
      body: jsonEncode(body),
    );

    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');
    print('=====================================');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        throw Exception(
          'Homework created, but backend returned empty response.',
        );
      }

      return HomeworkModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception(
      'Failed to create homework '
      '(${response.statusCode}): ${response.body}',
    );
  }

  Future<HomeworkModel> updateHomework({
    required int id,
    required int classId,
    required int sectionId,
    required int teacherId,
    int? subjectId,
    required String title,
    String? description,
    required String dueDate,
    String? status,
    String? attachmentUrl,
    String? priority,
  }) async {
    final body = {
      'classId': classId,
      'sectionId': sectionId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'status': status ?? 'ACTIVE',
      'attachmentUrl': attachmentUrl,
      'priority': priority ?? 'MEDIUM',
    };

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/homeworks/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return HomeworkModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception(
      'Failed to update homework '
      '(${response.statusCode}): ${response.body}',
    );
  }

  Future<void> deleteHomework(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/homeworks/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete homework '
        '(${response.statusCode}): ${response.body}',
      );
    }
  }
}
