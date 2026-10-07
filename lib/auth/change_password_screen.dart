import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'auth_service.dart';
import 'auth_storage.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  Future<void> _changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      _showMessage(
        'Please enter your current password.',
        Colors.red,
      );
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage(
        'Please enter your new password.',
        Colors.red,
      );
      return;
    }

    if (newPassword.length < 8) {
      _showMessage(
        'New password must be at least 8 characters.',
        Colors.red,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage(
        'Please confirm your new password.',
        Colors.red,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage(
        'New passwords do not match.',
        Colors.red,
      );
      return;
    }

    if (currentPassword == newPassword) {
      _showMessage(
        'New password must be different from current password.',
        Colors.orange,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login session expired. Please login again.',
        );
      }

      final response = await authService.changePassword(
        jwtToken: token,
        currentPassword: currentPassword,
        newPassword: newPassword,
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
        const Duration(milliseconds: 900),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on DioException catch (e) {
      debugPrint(
        'CHANGE PASSWORD DIO ERROR: ${e.response?.data}',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      String message = 'Unable to change password.';

      final data = e.response?.data;

      if (data is String && data.trim().isNotEmpty) {
        message = data;
      } else if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      _showMessage(
        message,
        Colors.red,
      );
    } catch (e) {
      debugPrint(
        'CHANGE PASSWORD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
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
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        leading: IconButton(
          onPressed: isLoading
              ? null
              : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            18,
            18,
            18,
            30,
          ),
          child: Column(
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildPasswordCard(),

              const SizedBox(height: 16),

              _buildSecurityNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff0D47A1),
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(.18),
              ),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure your account',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your password regularly to keep your account protected.',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(.75),
                    fontSize: 10,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xffE7ECF3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.025),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Details',
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Enter your current password and choose a new one.',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 22),

          _passwordField(
            controller: currentPasswordController,
            label: 'Current Password',
            hint: 'Enter current password',
            icon: Icons.lock_outline_rounded,
            obscureText: obscureCurrent,
            onToggle: () {
              setState(() {
                obscureCurrent = !obscureCurrent;
              });
            },
          ),

          const SizedBox(height: 16),

          _passwordField(
            controller: newPasswordController,
            label: 'New Password',
            hint: 'Enter new password',
            icon: Icons.lock_reset_rounded,
            obscureText: obscureNew,
            onToggle: () {
              setState(() {
                obscureNew = !obscureNew;
              });
            },
          ),

          const SizedBox(height: 16),

          _passwordField(
            controller: confirmPasswordController,
            label: 'Confirm New Password',
            hint: 'Re-enter new password',
            icon: Icons.verified_user_outlined,
            obscureText: obscureConfirm,
            onToggle: () {
              setState(() {
                obscureConfirm = !obscureConfirm;
              });
            },
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor:
                    primaryColor.withOpacity(.55),
                foregroundColor: Colors.white,
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
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'Update Password',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          enabled: !isLoading,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              icon,
              color: primaryColor,
              size: 21,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: 20,
              ),
            ),
            filled: true,
            fillColor: const Color(0xffF8FAFD),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xffE5EAF1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xffEAF3FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xffD7E8FF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use a strong password with at least 8 characters. '
              'Avoid using easily guessable information.',
              style: GoogleFonts.poppins(
                color: const Color(0xff31506F),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}