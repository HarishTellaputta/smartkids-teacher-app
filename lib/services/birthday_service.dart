import 'package:dio/dio.dart';

import '../models/birthday_chat_message_model.dart';
import '../models/student_birthday_chat_model.dart';

class BirthdayChatService {
  final Dio _dio;

  BirthdayChatService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.24.241.80:8080',
            connectTimeout:
                const Duration(seconds: 15),
            receiveTimeout:
                const Duration(seconds: 15),
            sendTimeout:
                const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ),
        );

  // =========================================================
  // GET BIRTHDAY CHAT LIST
  // =========================================================

  Future<List<StudentBirthdayChatModel>>
      getBirthdayChat() async {
    final response = await _dio.get(
      '/api/v1/student-birthday-status/chat',
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (json) =>
              StudentBirthdayChatModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // =========================================================
  // GET MESSAGES
  // =========================================================

  Future<List<BirthdayChatMessageModel>>
      getMessages(
    int studentId,
  ) async {
    final response = await _dio.get(
      '/api/v1/birthday-chat/$studentId',
    );

    final data = response.data;

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (json) =>
              BirthdayChatMessageModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // =========================================================
  // SEND MESSAGE
  // =========================================================

  Future<BirthdayChatMessageModel> sendMessage({
    required int studentId,
    required String message,
  }) async {
    final response = await _dio.post(
      '/api/v1/birthday-chat/$studentId/messages',
      data: {
        'message': message,
      },
    );

    return BirthdayChatMessageModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // =========================================================
  // EDIT MESSAGE
  // =========================================================

  Future<BirthdayChatMessageModel> editMessage({
    required int messageId,
    required String message,
  }) async {
    final response = await _dio.put(
      '/api/v1/birthday-chat/messages/$messageId',
      data: {
        'message': message,
      },
    );

    return BirthdayChatMessageModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // =========================================================
  // DELETE MESSAGE
  // =========================================================

  Future<void> deleteMessage(
    int messageId,
  ) async {
    await _dio.delete(
      '/api/v1/birthday-chat/messages/$messageId',
    );
  }

  // =========================================================
  // REPLY
  // =========================================================

  Future<BirthdayChatMessageModel> replyToMessage({
    required int messageId,
    required String message,
  }) async {
    final response = await _dio.post(
      '/api/v1/birthday-chat/messages/$messageId/reply',
      data: {
        'message': message,
      },
    );

    return BirthdayChatMessageModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // =========================================================
  // ADD REACTION
  // =========================================================

  Future<BirthdayChatMessageModel> addReaction({
    required int messageId,
    required String reaction,
  }) async {
    final response = await _dio.post(
      '/api/v1/birthday-chat/messages/$messageId/reaction',
      data: {
        'reaction': reaction,
      },
    );

    return BirthdayChatMessageModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  // =========================================================
  // REMOVE REACTION
  // =========================================================

  Future<void> removeReaction({
    required int messageId,
    required String reaction,
  }) async {
    await _dio.delete(
      '/api/v1/birthday-chat/messages/$messageId/reaction',
      data: {
        'reaction': reaction,
      },
    );
  }
}