import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/auth/auth_service.dart';
import 'package:teacher_app/auth/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        "Please enter your email",
        Colors.red,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // ----------------------------------------------------------
      // CALL FORGOT PASSWORD API
      // ----------------------------------------------------------

      final resetToken = await authService.forgotPassword(
        email: email,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      // ----------------------------------------------------------
      // TOKEN CHECK
      // ----------------------------------------------------------

      if (resetToken.trim().isEmpty) {
        _showMessage(
          "Reset token was not received",
          Colors.red,
        );
        return;
      }

      // ----------------------------------------------------------
      // OPEN RESET PASSWORD SCREEN
      // ----------------------------------------------------------

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            resetToken: resetToken,
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = "Unable to process request";

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
          "Forgot Password",
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
                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // ICON
                  // ------------------------------------------------

                  Container(
                    width: 95,
                    height: 95,
                    decoration: const BoxDecoration(
                      color: Color(0xffE3F2FD),
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
                    "Forgot Password?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff1F2937),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ------------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------------

                  Text(
                    "Enter your registered email address to reset your password.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ------------------------------------------------
                  // EMAIL
                  // ------------------------------------------------

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,

                    onSubmitted: (_) {
                      if (!isLoading) {
                        _forgotPassword();
                      }
                    },

                    decoration: InputDecoration(
                      labelText: "Email Address",
                      hintText: "Enter your registered email",

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xff1565C0),
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

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // SEND BUTTON
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                          isLoading ? null : _forgotPassword,

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
                              "Send Reset Request",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
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
    emailController.dispose();
    super.dispose();
  }
}