import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String tokenKey = 'jwt_token';

  // User ID = Authentication related
  static const String userIdKey = 'user_id';

  // Teacher ID = Education/Teacher related
  static const String teacherIdKey = 'teacher_id';

  static const String teacherUsernameKey = 'teacher_username';
  static const String teacherRoleKey = 'teacher_role';

  // ================= TOKEN =================

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(tokenKey);
  }

  // ================= USER ID =================

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(userIdKey);
  }

  // ================= TEACHER ID =================

  static Future<void> saveTeacherId(int teacherId) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(teacherIdKey, teacherId);
  }

  static Future<int?> getTeacherId() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(teacherIdKey);
  }

  // ================= USERNAME =================

  static Future<void> saveTeacherUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(teacherUsernameKey, username);
  }

  static Future<String?> getTeacherUsername() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(teacherUsernameKey);
  }

  // ================= ROLE =================

  static Future<void> saveTeacherRole(String role) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(teacherRoleKey, role);
  }

  static Future<String?> getTeacherRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(teacherRoleKey);
  }

  // ================= LOGIN STATUS =================

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // ================= CLEAR LOGIN DATA =================

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(teacherIdKey);
    await prefs.remove(teacherUsernameKey);
    await prefs.remove(teacherRoleKey);
  }
}