import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/teacher/parent_chat_screen.dart';

import 'class_students_screen.dart';
import '../teacher/homework_screen.dart';
import '../teacher/exams_screen.dart';


class ClassWorkspaceScreen extends StatelessWidget {
  final int classId;
  final String className;
  final String subject;
  final String students;

  const ClassWorkspaceScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Class Workspace',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 18),

            Text(
              'Overview',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _overviewCard(
                    icon: Icons.people_alt_rounded,
                    value: students,
                    title: 'Students',
                    color: const Color(0xff1565C0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _overviewCard(
                    icon: Icons.fact_check_rounded,
                    value: 'Today',
                    title: 'Attendance',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _overviewCard(
                    icon: Icons.cake_rounded,
                    value: 'Today',
                    title: 'Birthdays',
                    color: Colors.pink,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Text(
              'Class Tools',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
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
            ),

            const SizedBox(height: 22),

            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLASS HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff1565C0), Color(0xff42A5F5)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '$students Students',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
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
  // OVERVIEW CARD
  // ============================================================

  Widget _overviewCard({
    required IconData icon,
    required String value,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(height: 7),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOOL CARD
  // ============================================================

  Widget _toolCard(
    BuildContext context,
    IconData icon,
    String title, {
    bool enabled = true,
  }) {
    return Material(
      color: enabled ? Colors.white : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
      elevation: enabled ? 2 : 0,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled
            ? () => _handleToolTap(context, title)
            : () => _showComingSoon(context, title),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xffE3F2FD)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? const Color(0xff1565C0)
                      : Colors.grey.shade500,
                  size: 23,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: enabled ? Colors.grey.shade800 : Colors.grey.shade500,
                ),
              ),

              if (!enabled) ...[
                const SizedBox(height: 2),
                Text(
                  'Soon',
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    color: Colors.grey.shade500,
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
    // ----------------------------------------------------------
    // STUDENTS
    // ----------------------------------------------------------

    if (title == 'Students') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassStudentsScreen(
            classId: classId,
            className: className,
            subject: subject,
            openAttendance: false,
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // ATTENDANCE
    // ----------------------------------------------------------

    if (title == 'Attendance') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClassStudentsScreen(
            classId: classId,
            className: className,
            subject: subject,
            openAttendance: true,
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // HOMEWORK
    // ----------------------------------------------------------

    if (title == 'Homework') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeworkScreen(
            classId: classId,
            className: className,
            subject: subject,
          ),
        ),
      );
      return;
    }

    // ----------------------------------------------------------
    // MARKS
    // ----------------------------------------------------------

    if (title == 'Marks') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExamsScreen()),
      );
      return;
    }

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
          style: GoogleFonts.poppins(),
        ),
        behavior: SnackBarBehavior.floating,
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
        color: const Color(0xffE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xff1565C0),
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Use the class tools above to manage students, attendance, homework and examination marks.',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xff455A64),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
