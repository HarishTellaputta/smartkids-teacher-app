import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_storage.dart';
import '../models/school_notice_model.dart';

class SchoolNoticeService {
  static const String baseUrl = 'http://10.24.241.80:8080';

  Future<List<SchoolNoticeModel>> getRelevantNotices() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/notices'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('NOTICE GET STATUS: ${response.statusCode}');
    print('NOTICE GET RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);

      if (data is! List) {
        throw Exception('Invalid notice response');
      }

      return data
          .map(
            (item) =>
                SchoolNoticeModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    }

    if (response.statusCode == 403) {
      throw Exception('You do not have permission to view notices.');
    }

    throw Exception('Failed to load notices (${response.statusCode})');
  }
}
