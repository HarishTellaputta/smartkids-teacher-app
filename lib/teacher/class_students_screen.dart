import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/student_model.dart';
import '../services/student_service.dart';
import 'attendance_screen.dart';
import '../teacher/student_profile_screen.dart';

class ClassStudentsScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String subject;
  final bool openAttendance;

  // Assigned section only.
  final int sectionId;
  final String sectionName;

  const ClassStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
    required this.openAttendance,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<ClassStudentsScreen> createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  List<StudentModel> students = [];

  bool isLoadingStudents = true;

  String searchQuery = '';

  bool _attendanceOpened = false;

  @override
  void initState() {
    super.initState();

    _initializeScreen();
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _initializeScreen() async {
    debugPrint('========================================');
    debugPrint('CLASS STUDENTS SCREEN');
    debugPrint('CLASS ID    : ${widget.classId}');
    debugPrint('CLASS NAME  : ${widget.className}');
    debugPrint('SUBJECT     : ${widget.subject}');
    debugPrint('SECTION ID  : ${widget.sectionId}');
    debugPrint('SECTION NAME: ${widget.sectionName}');
    debugPrint('OPEN ATTENDANCE: ${widget.openAttendance}');
    debugPrint('========================================');

    await _loadStudents();

    // If this screen was opened specifically for Attendance,
    // automatically open Attendance for the SAME assigned section.
    if (widget.openAttendance && !_attendanceOpened && mounted) {
      _attendanceOpened = true;

      await _openAttendance();
    }
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String> _getToken() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Login token not found. Please login again.');
    }

    return token;
  }

  // ============================================================
  // LOAD STUDENTS
  // ============================================================

  Future<void> _loadStudents() async {
    try {
      if (mounted) {
        setState(() {
          isLoadingStudents = true;
          students = [];
          searchQuery = '';
        });
      }

      debugPrint('----------------------------------------');
      debugPrint('LOAD ASSIGNED SECTION STUDENTS');
      debugPrint('CLASS ID   : ${widget.classId}');
      debugPrint('SECTION ID : ${widget.sectionId}');
      debugPrint('SECTION    : ${widget.sectionName}');
      debugPrint('----------------------------------------');

      final token = await _getToken();

      final studentService = StudentService(token);

      // ========================================================
      // IMPORTANT
      // ========================================================
      //
      // We intentionally DO NOT call:
      //
      // getStudentsByClassId(widget.classId)
      //
      // because that could return students from every section.
      //
      // We use the exact assigned section ID.
      // ========================================================

      final loadedStudents = await studentService.getStudentsBySectionId(
        widget.sectionId,
      );

      debugPrint(
        'Students received for Section '
        '${widget.sectionName}: ${loadedStudents.length}',
      );

      for (final student in loadedStudents) {
        debugPrint(
          'STUDENT -> '
          'ID: ${student.id}, '
          'NAME: ${student.name}, '
          'ROLL: ${student.rollNumber}, '
          'SECTION ID: ${student.sectionId}',
        );
      }

      if (!mounted) return;

      setState(() {
        students = loadedStudents;
        isLoadingStudents = false;
      });

      debugPrint(
        'TOTAL STUDENTS IN SECTION '
        '${widget.sectionName}: ${loadedStudents.length}',
      );

      debugPrint('LOAD STUDENTS FINISHED');
      debugPrint('----------------------------------------');
    } catch (e) {
      debugPrint('LOAD ASSIGNED SECTION STUDENTS ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoadingStudents = false;
        students = [];
      });

      _showMessage('Failed to load students.', isError: true);
    }
  }

  // ============================================================
  // OPEN ATTENDANCE
  // ============================================================

  Future<void> _openAttendance() async {
    final teacherId = await AuthStorage.getTeacherId();

    if (teacherId == null) {
      if (!mounted) return;

      _showMessage('Teacher ID not found. Please login again.', isError: true);

      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          classId: widget.classId,
          teacherId: teacherId,

          // Class name only.
          // AttendanceScreen itself will show:
          // Class 6 • Section A
          className: widget.className,

          // Exact assigned section.
          sectionId: widget.sectionId,
          sectionName: widget.sectionName,
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  List<StudentModel> get filteredStudents {
    if (searchQuery.trim().isEmpty) {
      return students;
    }

    final query = searchQuery.trim().toLowerCase();

    return students.where((student) {
      final name = student.name.toLowerCase();

      final roll = student.rollNumber.toLowerCase();

      final admissionNo = student.admissionNo.toLowerCase();

      return name.contains(query) ||
          roll.contains(query) ||
          admissionNo.contains(query);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: _buildAppBar(),

      body: Column(
        children: [
          _buildTopSummary(),

          // NO SECTION SELECTOR HERE.
          //
          // Teacher is already assigned to:
          // Section ${widget.sectionName}
          if (!widget.openAttendance) _buildStudentHeader(),

          Expanded(child: _buildStudents()),
        ],
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 4,

      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 19,
          color: textColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.className,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            '${widget.subject} • Section ${widget.sectionName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade600,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      actions: [
        if (widget.openAttendance)
          Padding(
            padding: const EdgeInsets.only(right: 12),

            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),

              decoration: BoxDecoration(
                color: const Color(0xffEAF3FF),
                borderRadius: BorderRadius.circular(11),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    color: primaryColor,
                    size: 15,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    'Attendance',
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // TOP SUMMARY
  // ============================================================

  Widget _buildTopSummary() {
    return Container(
      width: double.infinity,

      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff0D47A1), Color(0xff1565C0), Color(0xff42A5F5)],
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          // ======================================================
          // ICON
          // ======================================================

          Container(
            width: 49,
            height: 49,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),

            child: Icon(
              widget.openAttendance
                  ? Icons.fact_check_rounded
                  : Icons.groups_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // TEXT
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.openAttendance ? 'Attendance' : 'Class Students',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Section ${widget.sectionName}',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.82),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  widget.openAttendance
                      ? 'Attendance for assigned section'
                      : 'Students in assigned section',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),

          // ======================================================
          // STUDENT COUNT
          // ======================================================
          _summaryBadge(
            '${students.length}',
            students.length == 1 ? 'Student' : 'Students',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY BADGE
  // ============================================================

  Widget _summaryBadge(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.72),
              fontSize: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT HEADER
  // ============================================================

  Widget _buildStudentHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 7),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.people_alt_outlined,
                  color: primaryColor,
                  size: 19,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Students',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),

                    Text(
                      'Section ${widget.sectionName} students',
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // ==================================================
              // STUDENT COUNT
              // ==================================================
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Text(
                  '${students.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          // ======================================================
          // SEARCH
          // ======================================================
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },

            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),

            decoration: InputDecoration(
              hintText: 'Search student name or roll number',

              hintStyle: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),

              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: primaryColor,
              ),

              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded, size: 17),
                    )
                  : null,

              filled: true,
              fillColor: Colors.white,

              contentPadding: const EdgeInsets.symmetric(vertical: 11),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffE5EAF0)),
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffE5EAF0)),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: primaryColor, width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENTS
  // ============================================================

  Widget _buildStudents() {
    if (isLoadingStudents) {
      return _buildStudentsLoading();
    }

    final visibleStudents = filteredStudents;

    if (visibleStudents.isEmpty) {
      return _buildEmptyStudents();
    }

    return RefreshIndicator(
      color: primaryColor,

      onRefresh: _loadStudents,

      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 25),

        physics: const AlwaysScrollableScrollPhysics(),

        itemCount: visibleStudents.length,

        itemBuilder: (context, index) {
          final student = visibleStudents[index];

          return _buildStudentCard(student, index);
        },
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(StudentModel student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        child: InkWell(
          borderRadius: BorderRadius.circular(17),

          // ======================================================
          // OPEN STUDENT PROFILE
          // ======================================================
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudentProfileScreen(studentId: student.id),
              ),
            );
          },

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(17),

              border: Border.all(color: const Color(0xffE9EEF4)),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Row(
              children: [
                // ==================================================
                // SERIAL
                // ==================================================

                Container(
                  width: 26,
                  height: 26,

                  decoration: BoxDecoration(
                    color: const Color(0xffF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  alignment: Alignment.center,

                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                const SizedBox(width: 9),

                // ==================================================
                // ROLL NUMBER
                // ==================================================
                Container(
                  width: 44,
                  height: 44,

                  alignment: Alignment.center,

                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xffEAF3FF), Color(0xffDCEEFF)],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(13)),
                  ),

                  child: Text(
                    student.rollNumber.isNotEmpty ? student.rollNumber : '-',

                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // ==================================================
                // STUDENT INFO
                // ==================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,

                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 11,
                            color: Colors.grey.shade500,
                          ),

                          const SizedBox(width: 4),

                          Expanded(
                            child: Text(
                              student.rollNumber.isNotEmpty
                                  ? 'Roll No: ${student.rollNumber}'
                                  : 'Roll number unavailable',

                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: GoogleFonts.poppins(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // ARROW
                // ==================================================
                Container(
                  width: 31,
                  height: 31,

                  decoration: BoxDecoration(
                    color: const Color(0xffF5F8FC),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildStudentsLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 65,
            height: 65,

            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(22),
            ),

            child: const Padding(
              padding: EdgeInsets.all(19),

              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Loading Section ${widget.sectionName} students...',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STUDENTS
  // ============================================================

  Widget _buildEmptyStudents() {
    return RefreshIndicator(
      color: primaryColor,

      onRefresh: _loadStudents,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  width: 76,
                  height: 76,

                  decoration: BoxDecoration(
                    color: const Color(0xffEEF3F8),
                    borderRadius: BorderRadius.circular(25),
                  ),

                  child: Icon(
                    searchQuery.isEmpty
                        ? Icons.people_outline_rounded
                        : Icons.search_off_rounded,
                    size: 36,
                    color: Colors.grey.shade500,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  searchQuery.isEmpty
                      ? 'No Students Found'
                      : 'No Matching Students',

                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  searchQuery.isEmpty
                      ? 'No students are assigned to Section ${widget.sectionName}.'
                      : 'Try another name or roll number.',

                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
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
  // SNACKBAR
  // ============================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        backgroundColor: isError ? const Color(0xffD32F2F) : textColor,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,

              color: Colors.white,

              size: 19,
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
