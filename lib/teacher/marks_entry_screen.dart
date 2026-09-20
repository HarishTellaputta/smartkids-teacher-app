import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/exam_result_model.dart';
import '../models/exam_schedule_model.dart';
import '../models/student_model.dart';
import '../services/examination_service.dart';
import '../services/student_service.dart';

class MarksEntryScreen extends StatefulWidget {
  final ExamScheduleModel schedule;

  const MarksEntryScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<MarksEntryScreen> createState() =>
      _MarksEntryScreenState();
}

class _MarksEntryScreenState
    extends State<MarksEntryScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  String? _errorMessage;

  List<StudentModel> _students = [];
  List<ExamResultModel> _results = [];

  final Map<int, TextEditingController> _markControllers = {};
  final Map<int, TextEditingController> _remarkControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login token not found. Please login again.',
        );
      }

      final sectionId = widget.schedule.sectionId;

      if (sectionId == null) {
        throw Exception(
          'Section is not assigned to this exam schedule.',
        );
      }

      debugPrint('========================================');
      debugPrint('MARKS ENTRY LOAD');
      debugPrint('Schedule ID: ${widget.schedule.id}');
      debugPrint('Class ID: ${widget.schedule.classId}');
      debugPrint('Section ID: $sectionId');
      debugPrint('Subject ID: ${widget.schedule.subjectId}');
      debugPrint('Max Marks: ${widget.schedule.maxMarks}');
      debugPrint('========================================');

      final studentService = StudentService(token);
      final examinationService = ExaminationService(token);

      final responses = await Future.wait([
        studentService.getStudentsBySectionId(sectionId),
        examinationService.getResults(
          scheduleId: widget.schedule.id,
        ),
      ]);

      final students =
          responses[0] as List<StudentModel>;

      final results =
          responses[1] as List<ExamResultModel>;

      debugPrint(
        'Students loaded: ${students.length}',
      );

      debugPrint(
        'Existing results: ${results.length}',
      );

      _disposeControllers();

      for (final student in students) {
        final existingResult =
            _findResultForStudent(
          student.id,
          results,
        );

        _markControllers[student.id] =
            TextEditingController(
          text: existingResult == null
              ? ''
              : existingResult.marksObtained.toString(),
        );

        _remarkControllers[student.id] =
            TextEditingController(
          text: existingResult?.remarks ?? '',
        );
      }

      if (!mounted) return;

      setState(() {
        _students = students;
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'MARKS ENTRY LOAD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _disposeControllers() {
    for (final controller in _markControllers.values) {
      controller.dispose();
    }

    for (final controller in _remarkControllers.values) {
      controller.dispose();
    }

    _markControllers.clear();
    _remarkControllers.clear();
  }

  // ============================================================
  // RESULTS
  // ============================================================

  ExamResultModel? _findResultForStudent(
    int studentId,
    List<ExamResultModel> results,
  ) {
    for (final result in results) {
      if (result.studentId == studentId) {
        return result;
      }
    }

    return null;
  }

  ExamResultModel? _existingResult(
    int studentId,
  ) {
    return _findResultForStudent(
      studentId,
      _results,
    );
  }

  // ============================================================
  // SAVE MARKS
  // ============================================================

  Future<void> _saveMarks() async {
    if (_isSaving) return;

    final maxMarks = widget.schedule.maxMarks;

    if (maxMarks <= 0) {
      _showMessage(
        'Maximum marks is invalid.',
        Colors.red,
      );
      return;
    }

    final newStudents = <StudentModel>[];
    final markValues = <int, int>{};

    for (final student in _students) {
      final existingResult =
          _existingResult(student.id);

      // Existing marks cannot be updated yet.
      if (existingResult != null) {
        continue;
      }

      final controller =
          _markControllers[student.id];

      final text =
          controller?.text.trim() ?? '';

      // Empty marks are allowed.
      if (text.isEmpty) {
        continue;
      }

      final marks = int.tryParse(text);

      if (marks == null) {
        _showMessage(
          'Invalid marks for ${student.name}.',
          Colors.red,
        );
        return;
      }

      if (marks < 0 || marks > maxMarks) {
        _showMessage(
          '${student.name}: Marks must be between 0 and $maxMarks.',
          Colors.red,
        );
        return;
      }

      newStudents.add(student);
      markValues[student.id] = marks;
    }

    if (newStudents.isEmpty) {
      if (_results.isNotEmpty) {
        _showMessage(
          'All entered marks are already saved.',
          Colors.orange,
        );
      } else {
        _showMessage(
          'Please enter marks for at least one student.',
          Colors.orange,
        );
      }
      return;
    }

    final confirmed =
        await _confirmSave(newStudents.length);

    if (!confirmed) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final token = await AuthStorage.getToken();
      final teacherId =
          await AuthStorage.getTeacherId();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login token not found.',
        );
      }

      if (teacherId == null) {
        throw Exception(
          'Teacher ID not found.',
        );
      }

      debugPrint('========================================');
      debugPrint('SAVE EXAM MARKS');
      debugPrint('Teacher ID: $teacherId');
      debugPrint(
        'Schedule ID: ${widget.schedule.id}',
      );
      debugPrint(
        'Students to save: ${newStudents.length}',
      );
      debugPrint('========================================');

      final service = ExaminationService(token);

      int successCount = 0;

      for (final student in newStudents) {
        final marks =
            markValues[student.id]!;

        final remark =
            _remarkControllers[student.id]
                ?.text
                .trim();

        await service.enterMarks(
          examScheduleId:
              widget.schedule.id,
          studentId:
              student.id,
          teacherId:
              teacherId,
          marksObtained:
              marks,
          maxMarks:
              maxMarks,
          remarks:
              remark == null || remark.isEmpty
                  ? null
                  : remark,
          status: 'SUBMITTED',
        );

        successCount++;
      }

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        '$successCount mark${successCount == 1 ? '' : 's'} saved successfully.',
        Colors.green,
      );

      await _loadData();
    } catch (e) {
      debugPrint(
        'SAVE MARKS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        'Failed to save marks: $e',
        Colors.red,
      );
    }
  }

  Future<bool> _confirmSave(int count) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Save Marks?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'You are about to save marks for $count student${count == 1 ? '' : 's'}.',
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff1565C0),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    return result ?? false;
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
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Marks Entry',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _isLoading ||
                  _errorMessage != null ||
                  _students.isEmpty
              ? null
              : _buildSaveButton(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_students.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 180),
            _emptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          110,
        ),
        children: [
          _examHeader(),
          const SizedBox(height: 16),
          _infoCard(),
          const SizedBox(height: 18),
          _existingMarksBanner(),
          const SizedBox(height: 18),
          Text(
            'Students',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Enter marks out of ${widget.schedule.maxMarks}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ..._students.asMap().entries.map(
            (entry) => _studentMarkCard(
              entry.key,
              entry.value,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _examHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            widget.schedule.examinationName ??
                'Exam',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.schedule.subjectName ??
                'Subject',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.schedule.className ?? 'Class'}'
            '${widget.schedule.sectionName != null ? ' - ${widget.schedule.sectionName}' : ''}',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _infoItem(
              Icons.calendar_month,
              'Date',
              _formatDate(
                widget.schedule.examDate,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _infoItem(
              Icons.grade,
              'Maximum',
              '${widget.schedule.maxMarks}',
            ),
          ),
          Container(
            width: 1,
            height: 45,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _infoItem(
              Icons.people,
              'Students',
              '${_students.length}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xff1565C0),
          size: 21,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EXISTING MARKS BANNER
  // ============================================================

  Widget _existingMarksBanner() {
    if (_results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffE3F2FD),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.blue.shade100,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Color(0xff1565C0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No marks have been entered yet.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xff455A64),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffE8F5E9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_results.length} student result${_results.length == 1 ? '' : 's'} already saved. Existing marks cannot be changed until the backend update API is added.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentMarkCard(
    int index,
    StudentModel student,
  ) {
    final result =
        _existingResult(student.id);

    final marksController =
        _markControllers[student.id];

    final remarkController =
        _remarkControllers[student.id];

    final hasExistingMarks =
        result != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: hasExistingMarks
            ? Border.all(
                color: Colors.green.shade100,
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor:
                    const Color(0xffE3F2FD),
                child: Text(
                  student.rollNumber?.toString() ??
                      '${index + 1}',
                  style: GoogleFonts.poppins(
                    color: const Color(0xff1565C0),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasExistingMarks
                          ? 'Marks already saved'
                          : 'Marks not entered',
                      style: GoogleFonts.poppins(
                        color: hasExistingMarks
                            ? Colors.green
                            : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              SizedBox(
                width: 82,
                child: TextField(
                  controller: marksController,
                  enabled: !hasExistingMarks,
                  keyboardType:
                      TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText:
                        '/${widget.schedule.maxMarks}',
                    suffixStyle:
                        GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                    filled: true,
                    fillColor: hasExistingMarks
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (hasExistingMarks) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                _resultChip(
                  'Marks',
                  '${result.marksObtained}/${result.maxMarks ?? widget.schedule.maxMarks}',
                ),
                const SizedBox(width: 8),
                _resultChip(
                  'Grade',
                  result.grade ?? '-',
                ),
                const SizedBox(width: 8),
                _resultChip(
                  '%',
                  result.percentage != null
                      ? result.percentage!
                          .toStringAsFixed(1)
                      : '-',
                ),
              ],
            ),
          ],

          if (!hasExistingMarks) ...[
            const SizedBox(height: 10),

            TextField(
              controller: remarkController,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: 'Remarks (optional)',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _resultChip(
    String title,
    String value,
  ) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffE8F5E9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$title: $value',
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Colors.green.shade700,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          10,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xff1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(17),
              ),
            ),
            onPressed:
                _isSaving ? null : _saveMarks,
            child: _isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Save Marks',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 65,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            'No students found',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No students are assigned to this exam schedule section.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            Text(
              'Unable to load marks',
              textAlign: TextAlign.center,
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
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xff1565C0),
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
  // HELPERS
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}