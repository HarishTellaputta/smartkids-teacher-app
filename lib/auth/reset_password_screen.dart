import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/auth/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // ============================================================
  // RESET PASSWORD
  // ============================================================

  Future<void> _resetPassword() async {
    final token = widget.resetToken.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // ------------------------------------------------------------
    // VALIDATION
    // ------------------------------------------------------------

    if (token.isEmpty) {
      _showMessage(
        "Invalid or expired reset request",
        Colors.red,
      );
      return;
    }

    if (password.isEmpty) {
      _showMessage(
        "Please enter new password",
        Colors.red,
      );
      return;
    }

    if (password.length < 8) {
      _showMessage(
        "Password must be at least 8 characters",
        Colors.red,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(
        "Please confirm password",
        Colors.red,
      );
      return;
    }

    if (password != confirmPassword) {
      _showMessage(
        "Passwords do not match",
        Colors.red,
      );
      return;
    }

    // ------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // API CALL
      // ----------------------------------------------------------

      final response = await authService.resetPassword(
        token: token,
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ----------------------------------------------------------
      // SUCCESS
      // ----------------------------------------------------------

      _showMessage(
        response,
        Colors.green,
      );

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return;

      // Go back to login / first screen
      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = "Password reset failed";

      final data = e.response?.data;

      if (data != null) {
        if (data is String) {
          message = data;
        } else if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      }

      _showMessage(
        message,
        Colors.red,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        "Something went wrong",
        Colors.red,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Reset Password",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),

      // ----------------------------------------------------------
      // BODY
      // ----------------------------------------------------------

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Card(
            elevation: 5,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),

            child: Padding(
              padding: const EdgeInsets.all(25),

              child: Column(
                children: [
                  const SizedBox(height: 15),

                  // ------------------------------------------------
                  // ICON
                  // ------------------------------------------------

                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      color: const Color(0xffE3F2FD),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 55,
                      color: Color(0xff1565C0),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // TITLE
                  // ------------------------------------------------

                  Text(
                    "Create New Password",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1F2937),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------------

                  Text(
                    "Create a new password for your account.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // NEW PASSWORD
                  // ------------------------------------------------

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    textInputAction: TextInputAction.next,

                    decoration: InputDecoration(
                      labelText: "New Password",
                      hintText: "Enter new password",

                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xff1565C0),
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },
                      ),

                      filled: true,
                      fillColor: Colors.grey.shade50,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

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

                  const SizedBox(height: 18),

                  // ------------------------------------------------
                  // CONFIRM PASSWORD
                  // ------------------------------------------------

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    textInputAction: TextInputAction.done,

                    onSubmitted: (_) {
                      if (!isLoading) {
                        _resetPassword();
                      }
                    },

                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      hintText: "Re-enter new password",

                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xff1565C0),
                      ),

                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                                !obscureConfirmPassword;
                          });
                        },
                      ),

                      filled: true,
                      fillColor: Colors.grey.shade50,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),

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

                  const SizedBox(height: 12),

                  // ------------------------------------------------
                  // PASSWORD INFO
                  // ------------------------------------------------

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Password must contain at least 8 characters.",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // RESET BUTTON
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : _resetPassword,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xff1565C0),

                        disabledBackgroundColor:
                            Colors.blue.shade200,

                        elevation: 2,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Reset Password",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}