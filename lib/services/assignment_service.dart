import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/assignment_model.dart';

class AssignmentService {
  static const String baseUrl = 'http://10.51.231.80:8080';

  final String token;

  AssignmentService(this.token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<AssignmentModel>> getByClassAndSection(
    int classId,
    int sectionId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/v1/assignments/class/$classId/section/$sectionId',
      ),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => AssignmentModel.fromJson(json))
          .toList();
    }

    throw Exception(
      'Failed to load assignments (${response.statusCode}): ${response.body}',
    );
  }

  Future<AssignmentModel> createAssignment({
    required int classId,
    required int sectionId,
    required int teacherId,
    int? subjectId,
    required String title,
    String? description,
    required String assignedDate,
    required String dueDate,
    String? status,
    String? attachmentUrl,
    String? priority,
    String? submissionType,
    int? maxMarks,
  }) async {
    final body = {
      'classId': classId,
      'sectionId': sectionId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'assignedDate': assignedDate,
      'dueDate': dueDate,
      'status': status ?? 'ASSIGNED',
      'attachmentUrl': attachmentUrl,
      'priority': priority ?? 'MEDIUM',
      'submissionType': submissionType,
      'maxMarks': maxMarks,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/assignments'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return AssignmentModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to create assignment (${response.statusCode}): ${response.body}',
    );
  }

  Future<AssignmentModel> updateAssignment({
    required int id,
    required int classId,
    required int sectionId,
    required int teacherId,
    int? subjectId,
    required String title,
    String? description,
    required String assignedDate,
    required String dueDate,
    String? status,
    String? attachmentUrl,
    String? priority,
    String? submissionType,
    int? maxMarks,
  }) async {
    final body = {
      'classId': classId,
      'sectionId': sectionId,
      'teacherId': teacherId,
      'subjectId': subjectId,
      'title': title,
      'description': description,
      'assignedDate': assignedDate,
      'dueDate': dueDate,
      'status': status ?? 'ASSIGNED',
      'attachmentUrl': attachmentUrl,
      'priority': priority ?? 'MEDIUM',
      'submissionType': submissionType,
      'maxMarks': maxMarks,
    };

    final response = await http.put(
      Uri.parse('$baseUrl/api/v1/assignments/$id'),
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return AssignmentModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      'Failed to update assignment (${response.statusCode}): ${response.body}',
    );
  }

  Future<void> deleteAssignment(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/v1/assignments/$id'),
      headers: _headers,
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete assignment (${response.statusCode}): ${response.body}',
      );
    }
  }
}