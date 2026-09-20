import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/conversation_model.dart';
import '../models/communication_message_model.dart';
import '../models/student_chat_model.dart';

class CommunicationService {
  final Dio _dio;

  CommunicationService(String token)
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

  // ============================================================
  // GET ALL CONVERSATIONS
  // ============================================================

  Future<List<ConversationModel>> getConversations() async {
    debugPrint('========== GET COMMUNICATIONS ==========');

    try {
      final response = await _dio.get('/api/v1/communications');

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final data = response.data;

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (json) => ConversationModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError('GET COMMUNICATIONS', e);
      rethrow;
    }
  }

  // ============================================================
  // GET TEACHER'S ASSIGNED STUDENTS FOR CHAT
  // ============================================================

  Future<List<StudentChatModel>> getTeacherStudents() async {
    debugPrint('========== GET TEACHER CHAT STUDENTS ==========');

    try {
      final response = await _dio.get(
        '/api/v1/communications/teacher/students',
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      final data = response.data;

      if (data is! List) {
        return [];
      }

      return data
          .map(
            (json) => StudentChatModel.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    } on DioException catch (e) {
      _logError('GET TEACHER CHAT STUDENTS', e);
      rethrow;
    }
  }

  // ============================================================
  // START NEW CONVERSATION
  // ============================================================

  Future<ConversationModel> startConversation({
    required int studentId,
    required String initialMessage,
    String? subject,
  }) async {
    debugPrint('========== START CONVERSATION ==========');
    debugPrint('Student ID: $studentId');
    debugPrint('Subject: $subject');
    debugPrint('Message: $initialMessage');

    final body = <String, dynamic>{
      'studentId': studentId,
      'initialMessage': initialMessage.trim(),
    };

    if (subject != null && subject.trim().isNotEmpty) {
      body['subject'] = subject.trim();
    }

    try {
      final response = await _dio.post(
        '/api/v1/communications',
        data: body,
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      return ConversationModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      _logError('START CONVERSATION', e);
      rethrow;
    }
  }

  // ============================================================
  // GET CONVERSATION HISTORY
  // ============================================================

  Future<ConversationModel> getConversation(int conversationId) async {
    debugPrint('========== GET CONVERSATION ==========');
    debugPrint('Conversation ID: $conversationId');

    try {
      final response = await _dio.get(
        '/api/v1/communications/$conversationId',
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      return ConversationModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      _logError('GET CONVERSATION', e);
      rethrow;
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<CommunicationMessageModel> sendMessage({
    required int conversationId,
    required String content,
    String messageType = 'TEXT',
  }) async {
    debugPrint('========== SEND MESSAGE ==========');
    debugPrint('Conversation ID: $conversationId');
    debugPrint('Content: $content');

    final body = {
      'content': content.trim(),
      'messageType': messageType,
    };

    try {
      final response = await _dio.post(
        '/api/v1/communications/$conversationId/messages',
        data: body,
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      return CommunicationMessageModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      _logError('SEND MESSAGE', e);
      rethrow;
    }
  }

  // ============================================================
  // ERROR LOG
  // ============================================================

  void _logError(String operation, DioException e) {
    debugPrint('========== $operation ERROR ==========');
    debugPrint('URL: ${e.requestOptions.uri}');
    debugPrint('Status: ${e.response?.statusCode}');
    debugPrint('Response: ${e.response?.data}');
    debugPrint('Message: ${e.message}');
    debugPrint('======================================');
  }
}