import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/teacher/parent_chat_screen.dart';
import 'package:teacher_app/teacher/student_profile_screen.dart';
import '../auth/auth_storage.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../services/attendance_service.dart';
import '../services/student_service.dart';

import 'class_students_screen.dart';
import '../teacher/homework_screen.dart';
import '../teacher/exams_screen.dart';

class ClassWorkspaceScreen extends StatefulWidget {
  final int classId;
  final String className;

  // ============================================================
  // SUBJECT
  // ============================================================

  final int subjectId;
  final String subject;

  // ============================================================
  // ASSIGNED SECTION
  // ============================================================

  final int sectionId;
  final String sectionName;

  const ClassWorkspaceScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subject,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<ClassWorkspaceScreen> createState() => _ClassWorkspaceScreenState();
}

class _ClassWorkspaceScreenState extends State<ClassWorkspaceScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  // ============================================================
  // COUNTS
  // ============================================================

  int studentCount = 0;
  int presentCount = 0;
  int absentCount = 0;

  bool isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadWorkspaceData();
  }

  // ============================================================
  // LOAD WORKSPACE DATA
  // ============================================================

  Future<void> _loadWorkspaceData() async {
    try {
      if (mounted) {
        setState(() {
          isLoadingCounts = true;
        });
      }

      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found.');
      }

      // ==========================================================
      // LOAD ONLY ASSIGNED SECTION STUDENTS
      // ==========================================================

      final studentService = StudentService(token);

      final students = await studentService.getStudentsBySectionId(
        widget.sectionId,
      );

      // ==========================================================
      // LOAD TODAY ATTENDANCE
      // ==========================================================

      final attendanceService = AttendanceService(token);

      final today = DateTime.now().toIso8601String().split('T').first;

      final attendance = await attendanceService.getClassAttendance(
        classId: widget.classId,
        date: today,
      );

      // ==========================================================
      // ONLY STUDENTS FROM THIS ASSIGNED SECTION
      // ==========================================================

      final sectionStudentIds = students.map((student) => student.id).toSet();

      final sectionAttendance = attendance.where((record) {
        return sectionStudentIds.contains(record.studentId);
      }).toList();

      // ==========================================================
      // COUNT
      // ==========================================================

      final present = sectionAttendance
          .where((record) => record.status == 'PRESENT')
          .length;

      final absent = sectionAttendance
          .where((record) => record.status == 'ABSENT')
          .length;

      if (!mounted) return;

      setState(() {
        studentCount = students.length;
        presentCount = present;
        absentCount = absent;
        isLoadingCounts = false;
      });
    } catch (e) {
      debugPrint('CLASS WORKSPACE COUNT ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingCounts = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ==========================================================
      // APP BAR
      // ==========================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        centerTitle: false,
        titleSpacing: 0,

        title: Text(
          'Class Workspace',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xffF1F6FC),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: primaryColor,
              size: 22,
            ),
          ),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================
      body: RefreshIndicator(
        onRefresh: _loadWorkspaceData,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),

          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              _buildHeader(),

              const SizedBox(height: 26),

              _buildSectionHeading(
                title: 'Class Overview',
                subtitle: 'Quick summary of this class',
              ),

              const SizedBox(height: 14),

              _buildOverview(),

              const SizedBox(height: 28),

              _buildSectionHeading(
                title: 'Class Tools',
                subtitle: 'Manage your classroom activities',
              ),

              const SizedBox(height: 14),

              _buildTools(context),

              const SizedBox(height: 26),

              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff0D47A1), Color(0xff1565C0), Color(0xff42A5F5)],
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),

                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      widget.className,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white70,
                          size: 15,
                        ),

                        const SizedBox(width: 5),

                        Expanded(
                          child: Text(
                            widget.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ======================================================
          // ASSIGNED SECTION
          // ======================================================
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.groups_rounded,
                      color: Colors.white,
                      size: 17,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      'Section ${widget.sectionName}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 9,
                ),

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 17,
                    ),

                    const SizedBox(width: 7),

                    Text(
                      isLoadingCounts ? 'Loading...' : '$studentCount Students',

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
  // SECTION HEADING
  // ============================================================

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,

          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview() {
    return Row(
      children: [
        Expanded(
          child: _overviewCard(
            icon: Icons.people_alt_rounded,

            value: isLoadingCounts ? '...' : '$studentCount',

            title: 'Students',

            color: primaryColor,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _overviewCard(
            icon: Icons.fact_check_rounded,

            value: isLoadingCounts ? '...' : '$presentCount/$studentCount',

            title: 'Today Attendance',

            color: const Color(0xff2E7D32),
          ),
        ),
      ],
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String value,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: const Color(0xffE7EDF5)),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(icon, color: color, size: 21),
              ),

              const Spacer(),

              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 12,
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            value,

            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            title,

            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLASS TOOLS
  // ============================================================

  Widget _buildTools(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),

      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,

      childAspectRatio: 0.92,

      children: [
        _toolCard(context, Icons.people_alt_rounded, 'Students'),

        _toolCard(context, Icons.fact_check_rounded, 'Attendance'),

        _toolCard(context, Icons.assignment_rounded, 'Homework'),

        _toolCard(context, Icons.grade_rounded, 'Marks'),

        _toolCard(context, Icons.chat_rounded, 'Chat'),

        _toolCard(
          context,
          Icons.emoji_events_rounded,
          'Achievements',
          enabled: false,
        ),
      ],
    );
  }

  Widget _toolCard(
    BuildContext context,
    IconData icon,
    String title, {
    bool enabled = true,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: enabled
            ? () => _handleToolTap(context, title)
            : () => _showComingSoon(context, title),

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: enabled
                  ? const Color(0xffE5EAF1)
                  : const Color(0xffEEF1F4),
            ),

            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xff1565C0).withOpacity(0.035),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ICON
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  gradient: enabled
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xffE3F2FD), Color(0xffBBDEFB)],
                        )
                      : null,

                  color: enabled ? null : const Color(0xffF3F4F6),

                  borderRadius: BorderRadius.circular(16),
                ),

                child: Icon(
                  icon,
                  size: 24,
                  color: enabled ? primaryColor : Colors.grey.shade400,
                ),
              ),

              const SizedBox(height: 10),

              // TITLE
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled ? textColor : Colors.grey.shade500,
                ),
              ),

              // COMING SOON
              if (!enabled) ...[
                const SizedBox(height: 3),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xffF4F5F7),
                    borderRadius: BorderRadius.circular(6),
                  ),

                  child: Text(
                    'Coming Soon',
                    style: GoogleFonts.poppins(
                      fontSize: 7,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOOL NAVIGATION
  // ============================================================

  void _handleToolTap(BuildContext context, String title) {
    // ==========================================================
    // STUDENTS
    // ==========================================================

    if (title == 'Students') {
      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => ClassStudentsScreen(
            classId: widget.classId,
            className: widget.className,
            subject: widget.subject,

            sectionId: widget.sectionId,
            sectionName: widget.sectionName,

            openAttendance: false,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // ATTENDANCE
    // ==========================================================

    if (title == 'Attendance') {
      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => ClassStudentsScreen(
            classId: widget.classId,
            className: widget.className,
            subject: widget.subject,

            sectionId: widget.sectionId,
            sectionName: widget.sectionName,

            openAttendance: true,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // HOMEWORK
    // ==========================================================

    if (title == 'Homework') {
      Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) => HomeworkScreen(
            classId: widget.classId,
            className: widget.className,

            subjectId: widget.subjectId,
            subject: widget.subject,

            sectionId: widget.sectionId,
            sectionName: widget.sectionName,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // MARKS
    // ==========================================================

    if (title == 'Marks') {
      Navigator.push(
        context,

        MaterialPageRoute(builder: (_) => const ExamsScreen()),
      );

      return;
    }

    // ==========================================================
    // CHAT
    // ==========================================================

    if (title == 'Chat') {
      Navigator.push(
        context,

        MaterialPageRoute(builder: (_) => const ParentChatScreen()),
      );

      return;
    }

    _showComingSoon(context, title);
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$title will be available soon.',

          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
        ),

        behavior: SnackBarBehavior.floating,

        backgroundColor: textColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xffEAF4FF), Color(0xffF5F9FF)],
        ),

        borderRadius: BorderRadius.circular(19),

        border: Border.all(color: const Color(0xffD8EAFB)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.lock_outline_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Assigned Section',

                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'You are managing ${widget.className} • ${widget.subject} • Section ${widget.sectionName}. Only students and activities assigned to this section are available here.',

                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: const Color(0xff526170),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
