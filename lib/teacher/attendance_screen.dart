
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

  const AttendanceScreen({
    super.key,
    required this.classId,
    required this.teacherId,
    required this.className,
    required this.sectionId,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<StudentModel> students = [];

  // true  = PRESENT
  // false = ABSENT
  final Map<int, bool> attendance = {};

  // Already saved attendance for today
  List<AttendanceModel> existingAttendance = [];

  bool isLoading = true;
  bool isSaving = false;

  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  // ============================================================
  // TOKEN
  // ============================================================

  Future<String> _getToken() async {
    final token = await AuthStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Login token not found. Please login again.',
      );
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
      debugPrint('ATTENDANCE: START');
      debugPrint('CLASS ID: ${widget.classId}');
      debugPrint('SECTION ID: ${widget.sectionId}');
      debugPrint('TEACHER ID: ${widget.teacherId}');

      final token = await _getToken();

      debugPrint(
        'Loading students using section API...',
      );

      final studentService = StudentService(token);

      final loadedStudents =
          await studentService.getStudentsBySectionId(
        widget.sectionId,
      );

      debugPrint(
        'Students received: ${loadedStudents.length}',
      );

      for (final student in loadedStudents) {
        debugPrint(
          'ATTENDANCE STUDENT -> '
          'ID: ${student.id}, '
          'NAME: ${student.name}, '
          'ROLL: ${student.rollNumber}',
        );
      }

      if (!mounted) return;

      setState(() {
        students = loadedStudents;

        attendance.clear();

        // Default every student to PRESENT.
        for (final student in students) {
          attendance[student.id] = true;
        }
      });

      // Load today's existing attendance.
      await _loadTodayAttendance();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint(
        'TOTAL ATTENDANCE STUDENTS: ${students.length}',
      );

      debugPrint('ATTENDANCE: FINISHED');
      debugPrint('========================================');
    } catch (e) {
      debugPrint(
        'ATTENDANCE STUDENT ERROR: $e',
      );

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

      final today =
          DateTime.now().toIso8601String().split('T').first;

      debugPrint(
        'Loading attendance for class '
        '${widget.classId} on $today',
      );

      final result =
          await service.getClassAttendance(
        classId: widget.classId,
        date: today,
      );

      if (!mounted) return;

      setState(() {
        existingAttendance = result;

        // Apply saved attendance.
        for (final record in result) {
          attendance[record.studentId] =
              record.status == 'PRESENT';
        }
      });

      debugPrint(
        'Existing attendance records: '
        '${result.length}',
      );
    } catch (e) {
      debugPrint(
        'Error loading today attendance: $e',
      );

      // If attendance is not marked yet,
      // don't block the screen.
      existingAttendance = [];
    }
  }

  // ============================================================
  // SAVE ATTENDANCE
  // ============================================================

  Future<void> _saveAttendance() async {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No students found.'),
        ),
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

      final today =
          DateTime.now().toIso8601String().split('T').first;

      // Existing records mapped by student ID.
      final Map<int, AttendanceModel> existingByStudent = {
        for (final record in existingAttendance)
          record.studentId: record,
      };

      // New attendance records.
      final List<Map<String, dynamic>> newRecords = [];

      // Existing records whose status changed.
      final List<AttendanceModel> recordsToUpdate = [];

      for (final student in students) {
        final isPresent =
            attendance[student.id] ?? true;

        final status =
            isPresent ? 'PRESENT' : 'ABSENT';

        final existing =
            existingByStudent[student.id];

        // --------------------------------------------------------
        // NEW RECORD
        // --------------------------------------------------------

        if (existing == null) {
          newRecords.add({
            'studentId': student.id,
            'status': status,
            'remarks': '',
          });
        }

        // --------------------------------------------------------
        // UPDATE EXISTING RECORD
        // --------------------------------------------------------

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

      debugPrint(
        'New attendance records: '
        '${newRecords.length}',
      );

      debugPrint(
        'Attendance records to update: '
        '${recordsToUpdate.length}',
      );

      // ==========================================================
      // BULK CREATE
      // ==========================================================

      if (newRecords.isNotEmpty) {
        await service.markBulkAttendance(
          classId: widget.classId,
          teacherId: teacherId,
          attendanceDate: today,
          attendanceRecords: newRecords,
        );
      }

      // ==========================================================
      // UPDATE EXISTING
      // ==========================================================

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

      // Reload today's attendance.
      await _loadTodayAttendance();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Attendance Marked Successfully',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint(
        'Save attendance error: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save attendance: $e',
          ),
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
        .where(
          (student) =>
              attendance[student.id] == true,
        )
        .length;

    final absentCount =
        students.length - presentCount;

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
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? _buildError()
              : _buildAttendance(
                  presentCount,
                  absentCount,
                ),
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
          mainAxisAlignment:
              MainAxisAlignment.center,

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
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _loadStudents,
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

  Widget _buildAttendance(
    int presentCount,
    int absentCount,
  ) {
    return Column(
      children: [

        // ========================================================
        // HEADER
        // ========================================================

        Container(
          width: double.infinity,

          margin: const EdgeInsets.fromLTRB(
            14,
            14,
            14,
            8,
          ),

          padding: const EdgeInsets.all(14),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(16),

            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              // Class name
              Text(
                widget.className,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1565C0),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  // Today
                  Expanded(
                    child: Row(
                      children: [

                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 7),

                        Text(
                          _todayDate(),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Present
                  _countBadge(
                    '$presentCount Present',
                    Colors.green,
                  ),

                  const SizedBox(width: 6),

                  // Absent
                  _countBadge(
                    '$absentCount Absent',
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),

        // ========================================================
        // SMALL INSTRUCTION
        // ========================================================

        Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            4,
            18,
            8,
          ),

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
                  child: Text(
                    'No students found',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadStudents,

                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(
                      14,
                      0,
                      14,
                      14,
                    ),

                    itemCount:
                        students.length,

                    itemBuilder:
                        (context, index) {
                      final student =
                          students[index];

                      final isPresent =
                          attendance[
                                  student.id] ??
                              true;

                      return _buildStudentRow(
                        student,
                        isPresent,
                      );
                    },
                  ),
                ),
        ),

        // ========================================================
        // MARK ATTENDANCE BUTTON
        // ========================================================

        Container(
          padding: const EdgeInsets.fromLTRB(
            14,
            10,
            14,
            14,
          ),

          color: Colors.white,

          child: SizedBox(
            width: double.infinity,
            height: 50,

            child: ElevatedButton(
              onPressed:
                  isSaving
                      ? null
                      : _saveAttendance,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff1565C0),

                disabledBackgroundColor:
                    Colors.grey.shade400,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(13),
                ),
              ),

              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,

                      child:
                          CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Mark Attendance',
                      style:
                          GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STUDENT ROW
  // ============================================================

  Widget _buildStudentRow(
    StudentModel student,
    bool isPresent,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 7,
      ),

      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(12),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
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

              borderRadius:
                  BorderRadius.circular(9),
            ),

            child: Text(
              student.rollNumber.isNotEmpty
                  ? student.rollNumber
                  : '-',

              style: GoogleFonts.poppins(
                color:
                    const Color(0xff1565C0),
                fontSize: 12,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ======================================================
          // NAME
          // ======================================================

          Expanded(
            child: Text(
              student.name,

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // ======================================================
          // ON / OFF
          // ======================================================

          Row(
            mainAxisSize:
                MainAxisSize.min,

            children: [

              Text(
                isPresent ? 'ON' : 'OFF',

                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight:
                      FontWeight.w600,

                  color: isPresent
                      ? Colors.green
                      : Colors.red,
                ),
              ),

              const SizedBox(width: 3),

              Switch(
                value: isPresent,

                onChanged: (value) {
                  setState(() {
                    attendance[
                            student.id] =
                        value;
                  });
                },

                activeColor:
                    const Color(0xff1565C0),

                materialTapTargetSize:
                    MaterialTapTargetSize
                        .shrinkWrap,
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

  Widget _countBadge(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
          fontWeight:
              FontWeight.w600,
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
