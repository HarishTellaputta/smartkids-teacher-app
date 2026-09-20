import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/auth/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {

  final tokenController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController =
      TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> _resetPassword() async {
    final token = tokenController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword =
        confirmPasswordController.text.trim();

    if (token.isEmpty) {
      _showMessage(
        "Please enter reset token",
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

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await authService.resetPassword(
        token: token,
        newPassword: password,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        response,
        Colors.green,
      );

      await Future.delayed(
        const Duration(seconds: 1),
      );

      if (!mounted) return;

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

      if (e.response?.data != null) {
        if (e.response!.data is String) {
          message = e.response!.data;
        } else if (e.response!.data['message'] != null) {
          message = e.response!.data['message'];
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

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const SizedBox(height: 15),

                const Icon(
                  Icons.password_rounded,
                  size: 75,
                  color: Color(0xff1565C0),
                ),

                const SizedBox(height: 15),

                Text(
                  "Create New Password",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                TextField(
                  controller: tokenController,
                  decoration: InputDecoration(
                    labelText: "Reset Token",
                    prefixIcon: const Icon(
                      Icons.key_rounded,
                      color: Color(0xff1565C0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: "New Password",
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xff1565C0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller:
                      confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xff1565C0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword =
                              !obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed:
                        isLoading ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff1565C0),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(18),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tokenController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}