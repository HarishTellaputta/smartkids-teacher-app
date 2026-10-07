import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:teacher_app/home/teacher_home_screen.dart';
import 'package:teacher_app/auth/auth_service.dart';
import 'package:teacher_app/auth/auth_storage.dart';
import 'package:teacher_app/auth/forgot_password_screen.dart';
import 'package:teacher_app/auth/register_screen.dart';
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

  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color darkColor = Color(0xff172033);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color mutedColor = Color(0xff667085);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeroHeader(size),

              Transform.translate(
                offset: const Offset(0, -35),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildLoginCard(),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -20),
                child: _buildBottomContent(),
              ),

              const SizedBox(height: 5),

              _buildFooter(),

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  } // ============================================================
  // HERO HEADER
  // ============================================================

  Widget _buildHeroHeader(Size size) {
    final heroHeight = (size.height * 0.39).clamp(300.0, 430.0);

    return Container(
      width: double.infinity,
      height: heroHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff0D47A1), Color(0xff1565C0), Color(0xff42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 25, 24, 55),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildLogo(),

              const SizedBox(height: 18),

              Text(
                'SmartKids',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .5,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'TEACHER PORTAL',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(.88),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(.16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: Colors.white.withOpacity(.95),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Secure • Simple • Smart',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  } // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.16),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(Icons.school_rounded, size: 48, color: primaryColor),
    );
  }

  // ============================================================
  // LOGIN CARD
  // ============================================================

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(.10),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: darkColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Sign in to continue to your teacher dashboard.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: mutedColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.login_rounded,
                  color: primaryColor,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          _buildLabel('Username'),

          const SizedBox(height: 9),

          _buildTextField(
            controller: usernameController,
            hint: 'Enter your username',
            icon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Password'),

              GestureDetector(
                onTap: isLoading ? null : _openForgotPassword,
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 9),

          _buildTextField(
            controller: passwordController,
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              splashRadius: 22,
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xff98A2B3),
                size: 21,
              ),
            ),
            onSubmitted: (_) {
              if (!isLoading) {
                _login();
              }
            },
          ),

          const SizedBox(height: 25),

          _buildLoginButton(),

          const SizedBox(height: 20),

          _buildRegisterDivider(),

          const SizedBox(height: 16),

          _buildRegisterButton(),
        ],
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: const Color(0xff344054),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputAction? textInputAction,
    VoidCallback? onTap,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      onTap: onTap,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: darkColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xff98A2B3),
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(left: 6, right: 4),
          child: Icon(icon, color: primaryColor, size: 21),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xffF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xffE4E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: Color(0xffE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: primaryColor, width: 1.6),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN BUTTON
  // ============================================================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff1565C0), Color(0xff1976D2)],
          ),
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 9),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================
  // REGISTER DIVIDER
  // ============================================================

  Widget _buildRegisterDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xffEAECF0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xff98A2B3),
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xffEAECF0))),
      ],
    );
  }

  // ============================================================
  // REGISTER BUTTON
  // ============================================================

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : _openRegister,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0xffB7D4F7), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_add_alt_1_rounded, size: 20),
            const SizedBox(width: 9),
            Text(
              'Create Teacher Account',
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM CONTENT
  // ============================================================

  Widget _buildBottomContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything you need',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: darkColor,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Manage your teaching activities from one place.',
            style: GoogleFonts.poppins(fontSize: 12, color: mutedColor),
          ),

          const SizedBox(height: 16),

          _featureTile(
            icon: Icons.people_alt_rounded,
            title: 'My Classes',
            subtitle: 'Access your assigned classes and students',
          ),

          _featureTile(
            icon: Icons.fact_check_rounded,
            title: 'Attendance & Homework',
            subtitle: 'Manage daily classroom activities easily',
          ),

          _featureTile(
            icon: Icons.notifications_active_rounded,
            title: 'Stay Connected',
            subtitle: 'Get important school updates instantly',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURE TILE
  // ============================================================

  Widget _featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE8EDF4)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xffEAF3FF), Color(0xffDCEEFF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: darkColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    color: mutedColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.chevron_right_rounded, color: Color(0xff98A2B3)),
        ],
      ),
    );
  }

  // ============================================================
  // FOOTER
  // ============================================================

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 14,
              color: Color(0xff98A2B3),
            ),
            const SizedBox(width: 5),
            Text(
              'Secure teacher access',
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: const Color(0xff98A2B3),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        Text(
          'Powered by SmartKids Technologies',
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            color: const Color(0xff98A2B3),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _openForgotPassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _openRegister() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      _showMessage('Please enter username', Colors.red);
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter password', Colors.red);
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

      debugPrint('==========================================');
      debugPrint('             LOGIN RESPONSE');
      debugPrint('==========================================');
      debugPrint('User ID  : $userId');
      debugPrint('Username : $loggedInUsername');
      debugPrint('Role     : $role');
      debugPrint('==========================================');

      // =========================================================
      // TOKEN VALIDATION
      // =========================================================

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found.');
      }

      // =========================================================
      // USER ID VALIDATION
      // =========================================================

      if (userId == null) {
        throw Exception('User ID not found.');
      }

      final parsedUserId = int.tryParse(userId.toString());

      if (parsedUserId == null) {
        throw Exception('Invalid User ID.');
      }

      // =========================================================
      // SAVE BASIC LOGIN DATA
      // =========================================================

      await AuthStorage.saveToken(token);

      await AuthStorage.saveUserId(parsedUserId);

      await AuthStorage.saveTeacherUsername(loggedInUsername ?? '');

      await AuthStorage.saveTeacherRole(role ?? '');

      // =========================================================
      // TEACHER → FIND TEACHER ID
      // =========================================================

      if (role == 'TEACHER') {
        debugPrint('Finding Teacher ID using User ID: $parsedUserId');

        final teacherService = TeacherService(token);

        final teacherData = await teacherService.getTeacherByUserId(
          parsedUserId,
        );

        debugPrint('Teacher API Response: $teacherData');

        final teacherId = teacherData['id'];

        if (teacherId == null) {
          throw Exception('Teacher profile not found for this user.');
        }

        final parsedTeacherId = int.tryParse(teacherId.toString());

        if (parsedTeacherId == null) {
          throw Exception('Invalid Teacher ID.');
        }

        await AuthStorage.saveTeacherId(parsedTeacherId);

        debugPrint('==========================================');
        debugPrint('       TEACHER ID FOUND');
        debugPrint('==========================================');
        debugPrint('User ID    : $parsedUserId');
        debugPrint('Teacher ID : $parsedTeacherId');
        debugPrint('Username   : $loggedInUsername');
        debugPrint('Role       : $role');
        debugPrint('==========================================');
      }

      // =========================================================
      // SUCCESS
      // =========================================================

      debugPrint('========== LOGIN SUCCESS ==========');
      debugPrint('User ID: $parsedUserId');
      debugPrint('Username: $loggedInUsername');
      debugPrint('Role: $role');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
      );
    }
    // ==========================================================
    // DIO ERROR
    // ==========================================================
    on DioException catch (e) {
      debugPrint('LOGIN DIO ERROR: ${e.response?.data}');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = 'Login failed';

      if (e.response?.data != null) {
        if (e.response!.data is String) {
          message = e.response!.data.toString();
        } else if (e.response!.data is Map &&
            e.response!.data['message'] != null) {
          message = e.response!.data['message'].toString();
        } else if (e.response!.data is Map &&
            e.response!.data['error'] != null) {
          message = e.response!.data['error'].toString();
        }
      }

      _showMessage(message, Colors.red);
    }
    // ==========================================================
    // GENERAL ERROR
    // ==========================================================
    catch (e, stackTrace) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(e.toString().replaceFirst('Exception: ', ''), Colors.red);
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.red
                  ? Icons.error_outline_rounded
                  : Icons.info_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
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
