
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/call_parent_model.dart';
import '../models/class_model.dart';
import '../models/section_model.dart';
import 'class_service.dart';
import 'section_service.dart';
import 'student_service.dart';

class CallParentService {
  final String token;

  CallParentService({required this.token});

  // Uses the base URL configured in existing services.
  Dio get _dio => Dio(
        BaseOptions(
          baseUrl: 'http://10.24.241.80:8080',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

  Future<List<ClassModel>> getClasses() {
    return ClassService(token).getAllClasses();
  }

  Future<List<SectionModel>> getSections(int classId) {
    return SectionService(token).getSectionsByClassId(classId);
  }

  Future<Map<int, Map<String, String>>> getParentContacts() async {
    final response = await _dio.get('/api/v1/parents');

    if (response.data is! List) {
      throw Exception('Invalid parent API response');
    }

    final result = <int, Map<String, String>>{};

    for (final item in response.data as List) {
      if (item is! Map) continue;

      final id = int.tryParse('${item['id'] ?? ''}');
      if (id == null) continue;

      final father = (item['fatherName'] ?? '').toString().trim();
      final mother = (item['motherName'] ?? '').toString().trim();
      final guardian = (item['guardianName'] ?? '').toString().trim();
      final phone = (item['contactPhone'] ?? '').toString().trim();

      final parentName = father.isNotEmpty
          ? father
          : guardian.isNotEmpty
              ? guardian
              : mother;

      result[id] = {
        'name': parentName,
        'phone': phone,
      };
    }

    return result;
  }

  Future<List<CallParentModel>> getStudents({
    required int sectionId,
    required Map<int, Map<String, String>> parentContacts,
  }) async {
    final students =
        await StudentService(token).getStudentsBySectionId(sectionId);

    return students.map<CallParentModel>((student) {
      final parentId = student.parentId;
      final contact = parentId > 0 ? parentContacts[parentId] : null;

      final contactParentName = contact?['name'] ?? '';
      final existingParentName = student.parentName.trim();

      return CallParentModel(
        studentId: student.id,
        studentName: student.name,
        admissionNo: student.admissionNo,
        parentId: parentId > 0 ? parentId : null,
        parentName: contactParentName.isNotEmpty
            ? contactParentName
            : existingParentName,
        parentPhone: contact?['phone'],
        sectionId: student.sectionId,
        sectionName: student.sectionName,
      );
    }).toList();
  }

  Future<void> callParent(String phone) async {
    final cleanedPhone = phone.trim();

    if (cleanedPhone.isEmpty) {
      throw Exception('Parent phone number is unavailable');
    }

    final uri = Uri(scheme: 'tel', path: cleanedPhone);
    final launched = await launchUrl(uri);

    if (!launched) {
      throw Exception('Unable to open phone dialer');
    }
  }
}
