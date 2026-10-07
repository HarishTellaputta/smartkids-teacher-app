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
  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  bool _isLoading = true;
  String? _errorMessage;

  List<ExamResultModel> _results = [];

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  // ============================================================
  // LOAD RESULTS
  // ============================================================

  Future<void> _loadResults() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Exam Details',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadResults,
            icon: const Icon(
              Icons.refresh_rounded,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildMarksButton(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadResults,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          10,
          18,
          25,
        ),
        children: [
          _buildHeaderCard(),

          const SizedBox(height: 18),

          _buildQuickStats(),

          const SizedBox(height: 22),

          _buildSectionHeader(
            'Exam Information',
            'Schedule and examination details',
            Icons.info_outline_rounded,
          ),

          const SizedBox(height: 11),

          _buildDetailsCard(),

          const SizedBox(height: 22),

          _buildSectionHeader(
            'Marks Overview',
            'Current marks entry status',
            Icons.analytics_outlined,
          ),

          const SizedBox(height: 11),

          _buildMarksSummary(),

          const SizedBox(height: 22),

          _buildSectionHeader(
            'Student Results',
            'Marks already entered for this exam',
            Icons.groups_rounded,
          ),

          const SizedBox(height: 11),

          _buildExistingResults(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeaderCard() {
    final schedule = widget.schedule;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff0D47A1),
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -55,
            bottom: -75,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
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
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          schedule.subjectName ?? 'Subject',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          schedule.examinationName ??
                              'Examination',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color:
                                Colors.white.withOpacity(0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _headerChip(
                      Icons.calendar_today_rounded,
                      _formatDate(schedule.examDate),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _headerChip(
                      Icons.access_time_rounded,
                      schedule.startTime ??
                          'Time unavailable',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK STATS
  // ============================================================

  Widget _buildQuickStats() {
    final schedule = widget.schedule;

    return Row(
      children: [
        Expanded(
          child: _quickStat(
            icon: Icons.timer_outlined,
            title: 'Duration',
            value: '${schedule.duration} min',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStat(
            icon: Icons.score_outlined,
            title: 'Max Marks',
            value: '${schedule.maxMarks}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickStat(
            icon: Icons.people_outline_rounded,
            title: 'Results',
            value: '${_results.length}',
          ),
        ),
      ],
    );
  }

  Widget _quickStat({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 8,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xffEAF3FF),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
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
  // DETAILS CARD
  // ============================================================

  Widget _buildDetailsCard() {
    final schedule = widget.schedule;

    return _premiumCard(
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
              isLast: true,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // MARKS SUMMARY
  // ============================================================

  Widget _buildMarksSummary() {
    final totalStudents = _results.length;

    return _premiumCard(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      totalStudents == 0
                          ? 'No marks entered yet'
                          : '$totalStudents student${totalStudents == 1 ? '' : 's'} completed',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalStudents == 0
                          ? 'Start entering student marks'
                          : 'Results are available below',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _summaryBox(
                  'Students',
                  '$totalStudents',
                  Icons.people_outline_rounded,
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

  // ============================================================
  // EXISTING RESULTS
  // ============================================================

  Widget _buildExistingResults() {
    if (_results.isEmpty) {
      return _premiumCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 22,
          ),
          child: Column(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'No Results Yet',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Student marks entered for this exam\nwill appear here.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  height: 1.5,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _premiumCard(
      child: Column(
        children: _results
            .map(
              (result) => _resultTile(result),
            )
            .toList(),
      ),
    );
  }

  // ============================================================
  // RESULT TILE
  // ============================================================

  Widget _resultTile(
    ExamResultModel result,
  ) {
    final marks =
        result.marksObtained ?? 0;

    final maxMarks =
        result.maxMarks ??
            widget.schedule.maxMarks;

    double percentage = 0;

    if (maxMarks > 0) {
      percentage =
          (marks / maxMarks) * 100;
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xffEDF0F5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xffE3F2FD),
                  Color(0xffBBDEFB),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials(result.studentName),
                style: GoogleFonts.poppins(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
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
                  result.studentName ?? 'Student',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: textColor,
                  ),
                ),
                if (result.studentRollNumber != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 2),
                    child: Text(
                      'Roll No: ${result.studentRollNumber}',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value:
                        (percentage / 100)
                            .clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor:
                        Colors.grey.shade200,
                    color: percentage >= 40
                        ? const Color(0xff22C55E)
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Text(
                '$marks/$maxMarks',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: Colors.grey.shade600,
                ),
              ),
              if (result.grade != null &&
                  result.grade!
                      .trim()
                      .isNotEmpty)
                Container(
                  margin:
                      const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffEAF7EE),
                    borderRadius:
                        BorderRadius.circular(7),
                  ),
                  child: Text(
                    result.grade!,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color:
                          const Color(0xff16803C),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM MARKS BUTTON
  // ============================================================

  Widget _buildMarksButton() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _openMarksEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 17,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _results.isEmpty
                      ? 'Enter Marks'
                      : 'Manage Marks',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 7),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATE TO MARKS
  // ============================================================

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

  // ============================================================
  // PREMIUM CARD
  // ============================================================

  Widget _premiumCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xffEEF1F5),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xffF0F6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY BOX
  // ============================================================

  Widget _summaryBox(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffEDF0F5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: primaryColor,
            ),
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
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
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
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
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
          const SizedBox(height: 17),
          Text(
            'Loading exam details...',
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xffffeeee),
                borderRadius: BorderRadius.circular(27),
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 38,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Unable to load exam details',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _loadResults,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
                label: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
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
  // INITIALS
  // ============================================================

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'S';
    }

    final parts =
        name.trim().split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  // ============================================================
  // DATE
  // ============================================================

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