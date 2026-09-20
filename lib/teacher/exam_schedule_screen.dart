import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/exam_schedule_model.dart';
import '../models/exam_result_model.dart';
import '../services/examination_service.dart';
import 'marks_entry_screen.dart';

class ExamScheduleScreen extends StatefulWidget {
  final ExamScheduleModel schedule;

  const ExamScheduleScreen({
    super.key,
    required this.schedule,
  });

  @override
  State<ExamScheduleScreen> createState() =>
      _ExamScheduleScreenState();
}

class _ExamScheduleScreenState
    extends State<ExamScheduleScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<ExamResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found.');
      }

      final service = ExaminationService(token);

      final results = await service.getResults(
        scheduleId: widget.schedule.id,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'EXAM SCHEDULE SCREEN ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedule = widget.schedule;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Exam Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildMarksButton(),
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

    return RefreshIndicator(
      onRefresh: _loadResults,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 18),
          _buildDetailsCard(),
          const SizedBox(height: 18),
          _buildMarksSummary(),
          const SizedBox(height: 18),
          _buildExistingResults(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final schedule = widget.schedule;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1565C0),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu_book_rounded,
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
                  schedule.subjectName ?? 'Subject',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule.examinationName ?? 'Examination',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final schedule = widget.schedule;

    return _card(
      title: 'Exam Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _detailRow(
            Icons.class_outlined,
            'Class',
            '${schedule.className ?? 'Class'}'
                '${schedule.sectionName != null ? ' - ${schedule.sectionName}' : ''}',
          ),
          _detailRow(
            Icons.calendar_month_outlined,
            'Exam Date',
            _formatDate(schedule.examDate),
          ),
          _detailRow(
            Icons.access_time_outlined,
            'Start Time',
            schedule.startTime ?? 'Not available',
          ),
          _detailRow(
            Icons.timer_outlined,
            'Duration',
            '${schedule.duration} minutes',
          ),
          _detailRow(
            Icons.score_outlined,
            'Maximum Marks',
            '${schedule.maxMarks}',
          ),
          _detailRow(
            Icons.category_outlined,
            'Exam Type',
            schedule.examType.isEmpty
                ? 'Not available'
                : schedule.examType,
          ),
          if (schedule.roomNumber != null &&
              schedule.roomNumber!.trim().isNotEmpty)
            _detailRow(
              Icons.meeting_room_outlined,
              'Room',
              schedule.roomNumber!,
            ),
        ],
      ),
    );
  }

  Widget _buildMarksSummary() {
    final totalStudents = _results.length;

    return _card(
      title: 'Marks Entry',
      icon: Icons.edit_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            totalStudents == 0
                ? 'No marks have been entered yet.'
                : '$totalStudents student result${totalStudents == 1 ? '' : 's'} already entered.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryBox(
                  'Results',
                  '$totalStudents',
                  Icons.people_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryBox(
                  'Max Marks',
                  '${widget.schedule.maxMarks}',
                  Icons.score_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExistingResults() {
    if (_results.isEmpty) {
      return _card(
        title: 'Existing Results',
        icon: Icons.assignment_outlined,
        child: Text(
          'No student marks entered for this exam yet.',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return _card(
      title: 'Existing Results',
      icon: Icons.assignment_turned_in_outlined,
      child: Column(
        children: _results
            .map(
              (result) => _resultTile(result),
            )
            .toList(),
      ),
    );
  }

  Widget _resultTile(ExamResultModel result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF5F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: const Color(0xffE3F2FD),
            child: Text(
              _initials(result.studentName),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.studentName ?? 'Student',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (result.studentRollNumber != null)
                  Text(
                    'Roll No: ${result.studentRollNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${result.marksObtained}/${result.maxMarks ?? widget.schedule.maxMarks}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff1565C0),
                ),
              ),
              if (result.grade != null &&
                  result.grade!.trim().isNotEmpty)
                Text(
                  result.grade!,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarksButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          10,
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _openMarksEntry,
            icon: const Icon(
              Icons.edit_rounded,
            ),
            label: Text(
              _results.isEmpty
                  ? 'Enter Marks'
                  : 'Manage Marks',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xff1565C0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openMarksEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MarksEntryScreen(
          schedule: widget.schedule,
        ),
      ),
    ).then((_) {
      _loadResults();
    });
  }

  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xff1565C0),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryBox(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF5F8FC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xff1565C0),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
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
              'Unable to load exam details',
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
              onPressed: _loadResults,
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

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'S';
    }

    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Date not available';
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
}