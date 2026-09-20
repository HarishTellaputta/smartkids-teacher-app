import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

import 'package:teacher_app/home/teacher_home_screen.dart';
import 'package:teacher_app/auth/auth_service.dart';
import 'package:teacher_app/auth/auth_storage.dart';
import 'package:teacher_app/auth/forgot_password_screen.dart';
import 'package:teacher_app/auth/reset_password_screen.dart';
import 'package:teacher_app/services/teacher_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER =================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 40, bottom: 45),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),

                child: Column(
                  children: [
                    Container(
                      height: 110,
                      width: 110,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: Color(0xff1565C0),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "SmartKids",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),

                    Text(
                      "EMPLOYEE PORTAL",
                      style: GoogleFonts.poppins(
                        color: Colors.yellow.shade200,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "One Login for All Employees",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ================= LOGIN CARD =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Card(
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(.2),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          "Welcome 👋",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Login using your employee username and password.",
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ================= USERNAME =================
                        Text(
                          "Username",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xff1565C0),
                            ),

                            hintText: "Enter Username",

                            filled: true,
                            fillColor: Colors.grey.shade100,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xff1565C0),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ================= PASSWORD =================
                        Text(
                          "Password",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          textInputAction: TextInputAction.done,

                          onSubmitted: (_) {
                            _login();
                          },

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xff1565C0),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),

                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),

                            hintText: "Enter Password",

                            filled: true,
                            fillColor: Colors.grey.shade100,

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Color(0xff1565C0),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ================= LOGIN BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1565C0),
                              elevation: 5,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            onPressed: isLoading ? null : _login,

                            child: isLoading
                                ? const SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Login",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ================= FEATURES =================
                        Text(
                          "Why SmartKids?",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        _featureTile(
                          Icons.people_alt_rounded,
                          "Employee Management",
                          "Manage teachers and staff easily",
                        ),

                        _featureTile(
                          Icons.assignment_rounded,
                          "Daily Updates",
                          "Attendance, tasks and reports",
                        ),

                        _featureTile(
                          Icons.notifications_active_rounded,
                          "Instant Notifications",
                          "Stay connected with school activities",
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ================= FOOTER =================
              Text(
                "Powered by SmartKids Technologies",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================
  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      _showMessage("Please enter username", Colors.red);
      return;
    }

    if (password.isEmpty) {
      _showMessage("Please enter password", Colors.red);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // =========================================================
      // LOGIN API
      // =========================================================

      final loginResponse = await authService.login(
        username: username,
        password: password,
      );

      // =========================================================
      // LOGIN RESPONSE
      // =========================================================

      final token = loginResponse['token']?.toString();
      final userId = loginResponse['userId'];
      final loggedInUsername = loginResponse['username']?.toString();
      final role = loginResponse['role']?.toString();

      debugPrint("==========================================");
      debugPrint("             LOGIN RESPONSE");
      debugPrint("==========================================");
      debugPrint("User ID  : $userId");
      debugPrint("Username : $loggedInUsername");
      debugPrint("Role     : $role");
      debugPrint("==========================================");

      // =========================================================
      // TOKEN VALIDATION
      // =========================================================

      if (token == null || token.isEmpty) {
        throw Exception("Login token not found.");
      }

      // =========================================================
      // USER ID VALIDATION
      // =========================================================

      if (userId == null) {
        throw Exception("User ID not found.");
      }

      final parsedUserId = int.tryParse(userId.toString());

      if (parsedUserId == null) {
        throw Exception("Invalid User ID.");
      }

      // =========================================================
      // SAVE BASIC LOGIN DATA
      // =========================================================

      await AuthStorage.saveToken(token);

      await AuthStorage.saveUserId(parsedUserId);

      await AuthStorage.saveTeacherUsername(loggedInUsername ?? '');

      await AuthStorage.saveTeacherRole(role ?? '');

      // =========================================================
      // TEACHER → FIND TEACHER ID USING USER ID
      // =========================================================

      if (role == 'TEACHER') {
        debugPrint("Finding Teacher ID using User ID: $parsedUserId");

        final teacherService = TeacherService(token);

        final teacherData = await teacherService.getTeacherByUserId(
          parsedUserId,
        );

        debugPrint("Teacher API Response: $teacherData");

        // =======================================================
        // GET TEACHER ID
        // =======================================================

        final teacherId = teacherData['id'];

        if (teacherId == null) {
          throw Exception("Teacher profile not found for this user.");
        }

        final parsedTeacherId = int.tryParse(teacherId.toString());

        if (parsedTeacherId == null) {
          throw Exception("Invalid Teacher ID.");
        }

        // =======================================================
        // SAVE TEACHER ID
        // =======================================================

        await AuthStorage.saveTeacherId(parsedTeacherId);

        debugPrint("==========================================");
        debugPrint("       TEACHER ID FOUND");
        debugPrint("==========================================");
        debugPrint("User ID    : $parsedUserId");
        debugPrint("Teacher ID : $parsedTeacherId");
        debugPrint("Username   : $loggedInUsername");
        debugPrint("Role       : $role");
        debugPrint("==========================================");
      }

      // =========================================================
      // LOGIN SUCCESS
      // =========================================================

      debugPrint("========== LOGIN SUCCESS ==========");

      debugPrint("User ID: $parsedUserId");

      debugPrint("Username: $loggedInUsername");

      debugPrint("Role: $role");

      // =========================================================
      // NAVIGATION
      // =========================================================

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TeacherHomeScreen()),
      );
    }
    // ==========================================================
    // DIO ERROR
    // ==========================================================
    on DioException catch (e) {
      debugPrint("LOGIN DIO ERROR: ${e.response?.data}");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = "Login failed";

      if (e.response?.data != null) {
        if (e.response!.data is String) {
          message = e.response!.data;
        } else if (e.response!.data is Map &&
            e.response!.data['message'] != null) {
          message = e.response!.data['message'].toString();
        }
      }

      _showMessage(message, Colors.red);
    }
    // ==========================================================
    // GENERAL ERROR
    // ==========================================================
    catch (e, stackTrace) {
      debugPrint("LOGIN ERROR: $e");

      debugPrint("STACK TRACE: $stackTrace");

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  } // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: color,
      ),
    );
  }

  // ============================================================
  // FEATURE TILE
  // ============================================================

  Widget _featureTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,

            decoration: const BoxDecoration(
              color: Color(0xff1565C0),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: Colors.white, size: 23),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),

                Text(
                  subtitle,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}
