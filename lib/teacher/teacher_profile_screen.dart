import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../auth/login_screen.dart';
import '../auth/auth_service.dart';
import '../services/teacher_service.dart';
import '../auth/change_password_screen.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  bool _isLoading = true;
  bool _isLoggingOut = false;

  String? _errorMessage;
  Map<String, dynamic>? _teacher;

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadTeacherProfile() async {
    try {
      debugPrint('========================================');
      debugPrint('TEACHER PROFILE: START');

      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final token = await AuthStorage.getToken();

      debugPrint('TOKEN EXISTS: ${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found. Please login again.');
      }

      final userId = await AuthStorage.getUserId();

      debugPrint('USER ID FROM STORAGE: $userId');

      if (userId == null || userId <= 0) {
        throw Exception('User ID not found. Please login again.');
      }

      final teacherService = TeacherService(token);

      final teacherData = await teacherService.getTeacherByUserId(userId);

      debugPrint('TEACHER PROFILE RECEIVED: $teacherData');

      if (!mounted) return;

      setState(() {
        _teacher = Map<String, dynamic>.from(teacherData);
        _isLoading = false;
      });

      debugPrint('TEACHER PROFILE: FINISHED');
      debugPrint('========================================');
    } catch (e) {
      debugPrint('TEACHER PROFILE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // SAFE VALUE
  // ============================================================

  String _value(String key, {String fallback = 'Not available'}) {
    final value = _teacher?[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  // ============================================================
  // GETTERS
  // ============================================================

  String get _teacherName {
    final name = _value('name', fallback: '');

    if (name.isNotEmpty) {
      return name;
    }

    final username = _value('username', fallback: '');

    if (username.isNotEmpty) {
      return username;
    }

    return 'Teacher';
  }

  String get _designation {
    return _value('designation', fallback: 'Teacher');
  }

  String get _employeeId {
    return _value('employeeId', fallback: 'Not assigned');
  }

  String get _initials {
    final name = _teacherName.trim();

    if (name.isEmpty || name == 'Teacher') {
      return 'T';
    }

    final parts = name.split(' ').where((e) => e.trim().isNotEmpty).toList();

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final token = await AuthStorage.getToken();

      debugPrint('========================================');
      debugPrint('TEACHER LOGOUT START');

      if (token != null && token.isNotEmpty) {
        try {
          final authService = AuthService();

          final message = await authService.logout(jwtToken: token);

          debugPrint('LOGOUT API SUCCESS: $message');
        } catch (e) {
          debugPrint('LOGOUT API ERROR: $e');
        }
      }

      await AuthStorage.clearToken();

      debugPrint('LOCAL AUTH DATA CLEARED');
      debugPrint('TEACHER LOGOUT FINISHED');
      debugPrint('========================================');

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('LOGOUT ERROR: $e');

      try {
        await AuthStorage.clearToken();
      } catch (clearError) {
        debugPrint('CLEAR LOGIN DATA ERROR: $clearError');
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutConfirmation() {
    if (_isLoggingOut) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xffffeeee),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Logout from account?',
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'You will need to login again to access your teacher account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xffffeeee),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.person_off_outlined,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load profile',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _loadTeacherProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadTeacherProfile,
            icon: const Icon(Icons.refresh_rounded, color: textColor, size: 22),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? _buildLoading()
          : _errorMessage != null
          ? _buildError()
          : _buildProfile(),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xffE8F1FF),
              borderRadius: BorderRadius.circular(23),
            ),
            child: const Padding(
              padding: EdgeInsets.all(21),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Loading profile...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfile() {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadTeacherProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Personal Information',
              'Your contact and personal details',
              Icons.person_outline_rounded,
            ),

            const SizedBox(height: 12),

            _buildInformationCard([
              _InfoItem(
                icon: Icons.phone_rounded,
                title: 'Mobile Number',
                value: _value('phone', fallback: 'Not available'),
              ),
              _InfoItem(
                icon: Icons.email_rounded,
                title: 'Email Address',
                value: _value('email', fallback: 'Not available'),
              ),
              _InfoItem(
                icon: Icons.location_on_rounded,
                title: 'Address',
                value: _value('address', fallback: 'Not available'),
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),

            _buildSectionTitle(
              'Professional Details',
              'Your role and employment information',
              Icons.work_outline_rounded,
            ),

            const SizedBox(height: 12),

            _buildInformationCard([
              _InfoItem(
                icon: Icons.school_rounded,
                title: 'Qualification',
                value: _value('qualification', fallback: 'Not available'),
              ),
              _InfoItem(
                icon: Icons.badge_rounded,
                title: 'Designation',
                value: _designation,
              ),
              _InfoItem(
                icon: Icons.calendar_month_rounded,
                title: 'Joining Date',
                value: _value('joiningDate', fallback: 'Not available'),
              ),
              _InfoItem(
                icon: Icons.wc_rounded,
                title: 'Gender',
                value: _value('gender', fallback: 'Not available'),
              ),
              _InfoItem(
                icon: Icons.verified_rounded,
                title: 'Status',
                value: _value('status', fallback: 'Not available'),
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),

            _buildAccountSection(),

            const SizedBox(height: 24),

            _buildLogoutButton(),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Teacher App',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff0D47A1), Color(0xff1565C0), Color(0xff42A5F5)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Container(
              width: 135,
              height: 135,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -65,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 94,
                    height: 94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 15,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xffE3F2FD), Color(0xffBBDEFB)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: GoogleFonts.poppins(
                              color: primaryColor,
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color(0xff22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Text(
                _teacherName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                _designation,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 17),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Employee ID  •  $_employeeId',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffE8F1FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInformationCard(List<_InfoItem> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: items.map((item) => _buildInfoRow(item)).toList(),
      ),
    );
  }

  Widget _buildInfoRow(_InfoItem item) {
    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        border: item.isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xffEEF1F5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT SECTION
  // ============================================================

  Widget _buildAccountSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffE8EDF4)),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              );
            },
          ),

          _buildMenuItem(
            icon: Icons.edit_note_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your profile information',
            onTap: () {
              _showComingSoon('Edit Profile will be available soon.');
            },
          ),

          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage your app preferences',
            onTap: () {
              _showComingSoon('Settings will be available soon.');
            },
          ),

          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'Get help when you need it',
            onTap: () {
              _showComingSoon('Help & Support will be available soon.');
            },
            isLast: true,
          ),
        ],
      ),
    );
  }
  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xffEEF1F5))),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xffF0F6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: _isLoggingOut ? null : _showLogoutConfirmation,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xfffff5f5),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xffffdddd)),
        ),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: const Color(0xffffe8e8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sign out from your teacher account',
                    style: GoogleFonts.poppins(
                      color: Colors.red.shade300,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            _isLoggingOut
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.red,
                  ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white),
        ),
      ),
    );
  }
}

// ============================================================
// INFO MODEL
// ============================================================

class _InfoItem {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });
}
