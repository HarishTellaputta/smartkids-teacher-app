import 'package:dio/dio.dart';

import '../models/student_section_assignment_model.dart';

class StudentSectionAssignmentService {
  final Dio _dio;

  StudentSectionAssignmentService(String token)
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

  // Get assignment by ID
  Future<StudentSectionAssignmentModel> getAssignmentById(
    int assignmentId,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-section-assignments/$assignmentId',
    );

    return StudentSectionAssignmentModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // Get all students assigned to a section
  Future<List<StudentSectionAssignmentModel>> getStudentsBySection(
    int sectionId,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-section-assignments/section/$sectionId',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => StudentSectionAssignmentModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    return [];
  }

  // Get student's section assignments
  Future<List<StudentSectionAssignmentModel>> getStudentAssignments(
    int studentId,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-section-assignments/student/$studentId',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => StudentSectionAssignmentModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    return [];
  }

  // Get assignments by academic year
  Future<List<StudentSectionAssignmentModel>> getByAcademicYear(
    int academicYearId,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-section-assignments/academic-year/$academicYearId',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => StudentSectionAssignmentModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    return [];
  }

  // Get section assignments by academic year
  Future<List<StudentSectionAssignmentModel>> getBySectionAndAcademicYear(
    int sectionId,
    int academicYearId,
  ) async {
    final response = await _dio.get(
      '/api/v1/student-section-assignments/section/$sectionId/academic-year/$academicYearId',
    );

    final data = response.data;

    if (data is List) {
      return data
          .map(
            (json) => StudentSectionAssignmentModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    return [];
  }
}
