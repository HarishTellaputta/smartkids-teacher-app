import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../auth/login_screen.dart';
import '../auth/auth_service.dart';
import '../services/teacher_service.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool _isLoading = true;
  bool _isLoggingOut = false;

  String? _errorMessage;

  Map<String, dynamic>? _teacher;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  // ============================================================
  // LOAD TEACHER PROFILE
  // ============================================================

  Future<void> _loadTeacherProfile() async {
    try {
      debugPrint('========================================');
      debugPrint('TEACHER PROFILE: START');

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // --------------------------------------------------------
      // GET TOKEN
      // --------------------------------------------------------

      final token = await AuthStorage.getToken();

      debugPrint('TOKEN EXISTS: ${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found. Please login again.');
      }

      // --------------------------------------------------------
      // GET USER ID
      // --------------------------------------------------------

      final userId = await AuthStorage.getUserId();

      debugPrint('USER ID FROM STORAGE: $userId');

      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      if (userId <= 0) {
        throw Exception('Invalid User ID. Please login again.');
      }

      // --------------------------------------------------------
      // GET TEACHER PROFILE
      // --------------------------------------------------------

      debugPrint('Calling GET /teachers/by-user/$userId');

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
  // TEACHER NAME
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

  // ============================================================
  // DESIGNATION
  // ============================================================

  String get _designation {
    return _value('designation', fallback: 'Teacher');
  }

  // ============================================================
  // EMPLOYEE ID
  // ============================================================

  String get _employeeId {
    return _value('employeeId', fallback: 'Not assigned');
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
      debugPrint('TOKEN EXISTS: ${token != null && token.isNotEmpty}');

      // --------------------------------------------------------
      // BACKEND LOGOUT
      // --------------------------------------------------------

      if (token != null && token.isNotEmpty) {
        try {
          final authService = AuthService();

          final message = await authService.logout(jwtToken: token);

          debugPrint('LOGOUT API SUCCESS');
          debugPrint('MESSAGE: $message');
        } catch (e) {
          // Backend logout failure should not prevent
          // local logout.
          debugPrint('LOGOUT API ERROR: $e');
        }
      } else {
        debugPrint('NO TOKEN FOUND');
      }

      // --------------------------------------------------------
      // CLEAR LOCAL AUTH DATA
      // --------------------------------------------------------

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

      // Make sure local data is cleared.
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

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            "Logout",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),

          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.poppins(fontSize: 14),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              onPressed: () {
                Navigator.pop(dialogContext);
                _logout();
              },

              child: Text(
                "Logout",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // ERROR SCREEN
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.person_off_outlined, size: 60, color: Colors.red),

            const SizedBox(height: 15),

            Text(
              "Unable to load profile",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadTeacherProfile,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565C0),
                foregroundColor: Colors.white,
              ),

              child: Text(
                "Retry",
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Teacher Profile",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildError()
          : _buildProfile(),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfile() {
    return RefreshIndicator(
      onRefresh: _loadTeacherProfile,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ==================================================
            // PROFILE HEADER
            // ==================================================

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                ),

                borderRadius: BorderRadius.circular(25),
              ),

              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,

                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.person,
                      size: 65,
                      color: Color(0xff1565C0),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _teacherName,

                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    _designation,

                    textAlign: TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      "Employee ID : $_employeeId",

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // PERSONAL INFORMATION
            // ==================================================
            _sectionTitle("Personal Information"),

            _profileCard(
              Icons.phone,
              "Mobile Number",
              _value('phone', fallback: 'Not available'),
            ),

            _profileCard(
              Icons.email,
              "Email",
              _value('email', fallback: 'Not available'),
            ),

            _profileCard(
              Icons.location_on,
              "Address",
              _value('address', fallback: 'Not available'),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // PROFESSIONAL DETAILS
            // ==================================================
            _sectionTitle("Professional Details"),

            _profileCard(
              Icons.school,
              "Qualification",
              _value('qualification', fallback: 'Not available'),
            ),

            _profileCard(Icons.work, "Designation", _designation),

            _profileCard(
              Icons.calendar_today,
              "Joining Date",
              _value('joiningDate', fallback: 'Not available'),
            ),

            _profileCard(
              Icons.person_outline,
              "Gender",
              _value('gender', fallback: 'Not available'),
            ),

            _profileCard(
              Icons.verified_user,
              "Status",
              _value('status', fallback: 'Not available'),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // EDIT PROFILE
            // ==================================================
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Edit Profile will be available soon."),
                    ),
                  );
                },

                child: Text(
                  "Edit Profile",

                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // MENU
            // ==================================================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  _menuItem(Icons.settings, "Settings"),

                  _menuItem(Icons.help_outline, "Help & Support"),

                  _menuItem(
                    Icons.logout,
                    "Logout",
                    logout: true,
                    onTap: _showLogoutConfirmation,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),

        child: Text(
          title,

          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE CARD
  // ============================================================

  Widget _profileCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,

            decoration: const BoxDecoration(
              color: Color(0xffE3F2FD),
              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: const Color(0xff1565C0)),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget _menuItem(
    IconData icon,
    String title, {
    bool logout = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,

      leading: Icon(icon, color: logout ? Colors.red : const Color(0xff1565C0)),

      title: Text(
        title,

        style: GoogleFonts.poppins(
          color: logout ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: _isLoggingOut && logout
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
