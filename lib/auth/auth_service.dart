import 'package:dio/dio.dart';

class AuthService {
  final Dio _dio;

  AuthService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://10.51.231.80:8080',
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  // ================= DEBUG LOG =================

  void _logResponse(Response response) {
    print('========== API RESPONSE ==========');
    print('URL    : ${response.requestOptions.uri}');
    print('METHOD : ${response.requestOptions.method}');
    print('STATUS : ${response.statusCode}');
    print('DATA   : ${response.data}');
    print('==================================');
  }

  void _logError(DioException e) {
    print('========== API ERROR =============');
    print('URL    : ${e.requestOptions.uri}');
    print('METHOD : ${e.requestOptions.method}');
    print('TYPE   : ${e.type}');
    print('STATUS : ${e.response?.statusCode}');
    print('DATA   : ${e.response?.data}');
    print('ERROR  : ${e.message}');
    print('==================================');
  }

  // ================= LOGIN =================

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    print('========== LOGIN REQUEST ==========');
    print('URL      : ${_dio.options.baseUrl}/auth/login');
    print('USERNAME : $username');
    print('===================================');

    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      _logResponse(response);

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _logError(e);
      rethrow;
    }
  }

  // ================= REGISTER =================

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    print('========== REGISTER REQUEST ========');
    print('URL      : ${_dio.options.baseUrl}/auth/register');
    print('USERNAME : $username');
    print('EMAIL    : $email');
    print('ROLE     : $role');
    print('====================================');

    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      _logResponse(response);

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      _logError(e);
      rethrow;
    }
  }

  // ================= FORGOT PASSWORD =================

  Future<String> forgotPassword({
    required String email,
  }) async {
    print('======= FORGOT PASSWORD REQUEST =======');
    print('URL   : ${_dio.options.baseUrl}/auth/forgot-password');
    print('EMAIL : $email');
    print('=======================================');

    try {
      final response = await _dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      _logResponse(response);

      return response.data.toString();
    } on DioException catch (e) {
      _logError(e);
      rethrow;
    }
  }

  // ================= RESET PASSWORD =================

  Future<String> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    print('========== RESET PASSWORD REQUEST ==========');
    print('URL : ${_dio.options.baseUrl}/auth/reset-password');
    print('============================================');

    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      _logResponse(response);

      return response.data.toString();
    } on DioException catch (e) {
      _logError(e);
      rethrow;
    }
  }

  // ================= CHANGE PASSWORD =================

  Future<String> changePassword({
    required String jwtToken,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    print('========== CHANGE PASSWORD REQUEST ==========');
    print('URL : ${_dio.options.baseUrl}/auth/change-password');
    print('=============================================');

    try {
      final response = await _dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      _logResponse(response);

      return response.data.toString();
    } on DioException catch (e) {
      _logError(e);
      rethrow;
    }
  }

  // ================= LOGOUT =================

  Future<String> logout({
    required String jwtToken,
  }) async {
    print('========== LOGOUT REQUEST ==========');
    print('URL : ${_dio.options.baseUrl}/auth/logout');
    print('====================================');

    try {
      final response = await _dio.post(
        '/auth/logout',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
          },
        ),
      );

      _logResponse(response);

      return response.data['message'] ?? 'Logged out successfully';
    } on DioException catch (e) {
      _logError(e);
      rethrow;
    }
  }
}