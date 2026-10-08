import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/attendance_model.dart';
import '../models/student_model.dart';
import '../services/attendance_service.dart';
import '../services/student_service.dart';

class AttendanceScreen extends StatefulWidget {
  final int classId;
  final int teacherId;
  final String className;
  final int sectionId;
  final String sectionName;

  const AttendanceScreen({
    super.key,
    required this.classId,
    required this.teacherId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  // ============================================================
  // DATA
  // ============================================================

  List<StudentModel> students = [];

  // true  = PRESENT
  // false = ABSENT
  final Map<int, bool> attendance = {};

  // Existing attendance for TODAY,
  // but ONLY for the currently assigned section.
  List<AttendanceModel> existingAttendance = [];

  bool isLoading = true;
  bool isSaving = false;

  // Attendance was already submitted for today.
  bool attendanceMarkedToday = false;

  bool attendanceChanged = false;

  // Stores today's originally saved attendance.
  // studentId -> true(PRESENT) / false(ABSENT)
  final Map<int, bool> originalAttendance = {};
  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    debugPrint('========================================');
    debugPrint('ATTENDANCE SCREEN INITIALIZED');
    debugPrint('CLASS ID    : ${widget.classId}');
    debugPrint('CLASS NAME  : ${widget.className}');
    debugPrint('SECTION ID  : ${widget.sectionId}');
    debugPrint('SECTION NAME: ${widget.sectionName}');
    debugPrint('TEACHER ID  : ${widget.teacherId}');
    debugPrint('========================================');

    _loadStudents();
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
          isLoading = true;
          errorMessage = null;
        });
      }

      debugPrint('========================================');
      debugPrint('ATTENDANCE: LOADING SECTION STUDENTS');
      debugPrint('CLASS ID   : ${widget.classId}');
      debugPrint('SECTION ID : ${widget.sectionId}');
      debugPrint('TEACHER ID : ${widget.teacherId}');
      debugPrint('========================================');

      final token = await _getToken();

      final studentService = StudentService(token);

      // IMPORTANT:
      // We intentionally use SECTION API.
      //
      // This means:
      // Section A -> Section A students only
      // Section B -> Section B students only
      //
      // Teacher cannot switch sections from this screen.
      final loadedStudents = await studentService.getStudentsBySectionId(
        widget.sectionId,
      );

      debugPrint(
        'Students received for Section '
        '${widget.sectionName}: ${loadedStudents.length}',
      );

      for (final student in loadedStudents) {
        debugPrint(
          'SECTION STUDENT -> '
          'ID: ${student.id}, '
          'NAME: ${student.name}, '
          'ROLL: ${student.rollNumber}, '
          'SECTION ID: ${student.sectionId}',
        );
      }

      if (!mounted) return;

      setState(() {
        students = loadedStudents;

        attendance.clear();
        originalAttendance.clear();

        // Before today's attendance is loaded,
        // default everyone to PRESENT.
        for (final student in students) {
          attendance[student.id] = true;
        }

        attendanceMarkedToday = false;
        attendanceChanged = false;
      });

      // Load today's saved attendance.
      await _loadTodayAttendance();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('TOTAL SECTION STUDENTS: ${students.length}');

      debugPrint('ATTENDANCE: FINISHED');
      debugPrint('========================================');
    } catch (e) {
      debugPrint('ATTENDANCE STUDENT ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // LOAD TODAY ATTENDANCE
  // ============================================================

  Future<void> _loadTodayAttendance() async {
    try {
      final token = await _getToken();

      final service = AttendanceService(token);

      final today = DateTime.now().toIso8601String().split('T').first;

      debugPrint('========================================');

      debugPrint(
        'Loading attendance for class '
        '${widget.classId} on $today',
      );

      final result = await service.getClassAttendance(
        classId: widget.classId,
        date: today,
      );

      debugPrint(
        'Total class attendance records received: '
        '${result.length}',
      );

      // ========================================================
      // IMPORTANT
      // ========================================================
      //
      // Backend endpoint is class-level.
      //
      // Therefore it may return:
      //
      // Section A -> students
      // Section B -> students
      // Section C -> students
      //
      // We MUST filter it to the currently assigned section.
      //
      // This prevents Section B attendance from affecting
      // Section A screen.
      // ========================================================

      final sectionStudentIds = students.map((student) => student.id).toSet();

      final sectionAttendance = result
          .where((record) => sectionStudentIds.contains(record.studentId))
          .toList();

      debugPrint(
        'Current Section ${widget.sectionName} '
        'attendance records: '
        '${sectionAttendance.length}',
      );

      if (!mounted) return;

      setState(() {
        existingAttendance = sectionAttendance;

        attendanceMarkedToday = sectionAttendance.isNotEmpty;

        attendanceChanged = false;

        originalAttendance.clear();

        // Apply saved attendance.
        for (final record in sectionAttendance) {
          final isPresent = record.status.toUpperCase() == 'PRESENT';

          attendance[record.studentId] = isPresent;

          // Save original state so we can detect
          // whether teacher actually changed anything.
          originalAttendance[record.studentId] = isPresent;
        }
      });

      debugPrint(
        'Today attendance applied for Section '
        '${widget.sectionName}',
      );

      debugPrint('========================================');
    } catch (e) {
      debugPrint('Error loading today attendance: $e');

      if (!mounted) return;

      setState(() {
        existingAttendance = [];
        attendanceMarkedToday = false;
        attendanceChanged = false;
        originalAttendance.clear();
      });
    }
  }

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<void> _saveAttendance() async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students found for this section.')),
      );

      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      final token = await _getToken();

      final service = AttendanceService(token);

      final teacherId = widget.teacherId;

      final today = DateTime.now().toIso8601String().split('T').first;

      // ========================================================
      // EXISTING RECORDS
      // ========================================================

      final Map<int, AttendanceModel> existingByStudent = {
        for (final record in existingAttendance) record.studentId: record,
      };

      // ========================================================
      // NEW RECORDS
      // ========================================================

      final List<Map<String, dynamic>> newRecords = [];

      // ========================================================
      // UPDATED RECORDS
      // ========================================================

      final List<AttendanceModel> recordsToUpdate = [];

      // ========================================================
      // PROCESS CURRENT SECTION STUDENTS ONLY
      // ========================================================

      for (final student in students) {
        final isPresent = attendance[student.id] ?? true;

        final status = isPresent ? 'PRESENT' : 'ABSENT';

        final existing = existingByStudent[student.id];

        // ------------------------------------------------------
        // NEW RECORD
        // ------------------------------------------------------

        if (existing == null) {
          newRecords.add({
            'studentId': student.id,
            'status': status,
            'remarks': '',
          });
        }
        // ------------------------------------------------------
        // UPDATE EXISTING RECORD
        // ------------------------------------------------------
        else if (existing.status != status) {
          recordsToUpdate.add(
            AttendanceModel(
              id: existing.id,
              studentId: student.id,
              classId: widget.classId,
              teacherId: teacherId,
              attendanceDate: today,
              status: status,
              remarks: '',
            ),
          );
        }
      }

      debugPrint('========================================');

      debugPrint('Saving attendance');

      debugPrint('Class ID: ${widget.classId}');

      debugPrint('Section ID: ${widget.sectionId}');

      debugPrint('Section Name: ${widget.sectionName}');

      debugPrint('New records: ${newRecords.length}');

      debugPrint(
        'Records to update: '
        '${recordsToUpdate.length}',
      );

      debugPrint('========================================');

      // ========================================================
      // BULK CREATE
      // ========================================================

      if (newRecords.isNotEmpty) {
        await service.markBulkAttendance(
          classId: widget.classId,
          teacherId: teacherId,
          attendanceDate: today,
          attendanceRecords: newRecords,
        );
      }

      // ========================================================
      // UPDATE EXISTING
      // ========================================================

      for (final record in recordsToUpdate) {
        if (record.id == null) {
          continue;
        }

        await service.updateAttendance(
          attendanceId: record.id!,
          teacherId: teacherId,
          status: record.status,
          remarks: record.remarks ?? '',
        );
      }

      // ========================================================
      // RELOAD
      // ========================================================

      attendanceMarkedToday = true;
      attendanceChanged = false;

      await _loadTodayAttendance();

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),

            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 22),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,

                  decoration: BoxDecoration(
                    color: const Color(0xffE8F5E9),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'Attendance Saved!',
                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff172033),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Section ${widget.sectionName} attendance '
                  'has been marked successfully.',
                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 45,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1565C0),

                      foregroundColor: Colors.white,

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      'Done',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Save attendance error: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save attendance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final presentCount = students
        .where((student) => attendance[student.id] == true)
        .length;

    final absentCount = students.length - presentCount;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
        centerTitle: true,

        title: Text(
          'Attendance',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff1565C0)),
            )
          : errorMessage != null
          ? _buildError()
          : _buildAttendance(presentCount, absentCount),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: Colors.red,
            ),

            const SizedBox(height: 14),

            Text(
              'Unable to load students',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadStudents,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565C0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ATTENDANCE UI
  // ============================================================

  Widget _buildAttendance(int presentCount, int absentCount) {
    return Column(
      children: [
        // ========================================================
        // HEADER
        // ========================================================

        Container(
          width: double.infinity,

          margin: const EdgeInsets.fromLTRB(14, 14, 14, 8),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ==================================================
              // CLASS + SECTION
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,

                    decoration: BoxDecoration(
                      color: const Color(0xffE3F2FD),
                      borderRadius: BorderRadius.circular(11),
                    ),

                    child: const Icon(
                      Icons.groups_rounded,
                      color: Color(0xff1565C0),
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 11),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          widget.className,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff1565C0),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 12,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              'Section ${widget.sectionName}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // STUDENT COUNT
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffF5F8FC),
                      borderRadius: BorderRadius.circular(9),
                    ),

                    child: Text(
                      '${students.length} Students',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Divider(height: 1),

              const SizedBox(height: 11),

              // ==================================================
              // DATE + COUNTS
              // ==================================================
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 15,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 7),

                        Text(
                          _todayDate(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _countBadge('$presentCount Present', Colors.green),

                  const SizedBox(width: 6),

                  _countBadge('$absentCount Absent', Colors.red),
                ],
              ),
            ],
          ),
        ),

        // ========================================================
        // SMALL HEADER
        // ========================================================
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),

          child: Row(
            children: [
              Text(
                'Roll No',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(width: 32),

              Text(
                'Student Name',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(),

              Text(
                'Present',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // STUDENTS
        // ========================================================
        Expanded(
          child: students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'No students found',
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'No students are assigned to '
                        'Section ${widget.sectionName}.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xff1565C0),
                  onRefresh: _loadStudents,

                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),

                    itemCount: students.length,

                    itemBuilder: (context, index) {
                      final student = students[index];

                      final isPresent = attendance[student.id] ?? true;

                      return _buildStudentRow(student, isPresent);
                    },
                  ),
                ),
        ),

        // ========================================================
        // MARK ATTENDANCE BUTTON
        // ========================================================
        // ========================================================
        // MARK ATTENDANCE BUTTON
        // ========================================================
        if (!attendanceMarkedToday || attendanceChanged)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),

            color: Colors.white,

            child: SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton(
                onPressed: isSaving ? null : _saveAttendance,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),

                  disabledBackgroundColor: Colors.grey.shade400,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),

                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,

                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 20,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            'Mark Attendance',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  void _checkAttendanceChanged() {
    bool changed = false;

    for (final student in students) {
      final current = attendance[student.id] ?? true;

      final original = originalAttendance[student.id] ?? true;

      if (current != original) {
        changed = true;
        break;
      }
    }

    setState(() {
      attendanceChanged = changed;
    });
  }
  // ============================================================
  // STUDENT ROW
  // ============================================================

  Widget _buildStudentRow(StudentModel student, bool isPresent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: Colors.grey.shade200),
      ),

      child: Row(
        children: [
          // ======================================================
          // ROLL NUMBER
          // ======================================================

          Container(
            width: 42,
            height: 36,

            alignment: Alignment.center,

            decoration: BoxDecoration(
              color: const Color(0xffE3F2FD),

              borderRadius: BorderRadius.circular(9),
            ),

            child: Text(
              student.rollNumber.isNotEmpty ? student.rollNumber : '-',

              style: GoogleFonts.poppins(
                color: const Color(0xff1565C0),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // NAME
          // ======================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  student.name,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'Roll No: ${student.rollNumber.isNotEmpty ? student.rollNumber : '-'}',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ======================================================
          // ON / OFF
          // ======================================================
          Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                isPresent ? 'PRESENT' : 'ABSENT',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isPresent ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(width: 3),

              Switch(
                value: isPresent,

                onChanged: (value) {
                  setState(() {
                    attendance[student.id] = value;
                  });

                  _checkAttendanceChanged();
                },

                activeColor: const Color(0xff1565C0),

                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COUNT BADGE
  // ============================================================

  Widget _countBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),

      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  String _todayDate() {
    final now = DateTime.now();

    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }
}
