import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/teacher/exam_schedule_screen.dart';

import '../auth/auth_storage.dart';
import '../models/examination_model.dart';
import '../models/exam_schedule_model.dart';
import '../services/examination_service.dart';

import 'package:teacher_app/models/exam_schedule_model.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() =>
      _ExamsScreenState();
}

class _ExamsScreenState
    extends State<ExamsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<ExaminationModel> _exams = [];
  List<ExamScheduleModel> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token =
          await AuthStorage.getToken();

      final teacherId =
          await AuthStorage.getTeacherId();

      if (token == null ||
          token.isEmpty) {
        throw Exception(
          'Login token not found.',
        );
      }

      if (teacherId == null) {
        throw Exception(
          'Teacher ID not found.',
        );
      }

      final service =
          ExaminationService(token);

      final exams =
          await service.getExaminations();

      final allSchedules =
          await service.getSchedules();

      /*
       * Teacher App should only display
       * schedules assigned to the logged-in
       * teacher.
       *
       * subjectTeacherId = Teacher.id
       */
      final teacherSchedules =
          allSchedules.where((schedule) {
        return schedule.subjectTeacherId ==
            teacherId;
      }).toList();

      teacherSchedules.sort((a, b) {
        final dateA =
            a.examDate ?? DateTime(9999);

        final dateB =
            b.examDate ?? DateTime(9999);

        return dateA.compareTo(dateB);
      });

      if (!mounted) return;

      setState(() {
        _exams = exams;
        _schedules = teacherSchedules;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'EXAMS SCREEN ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            e.toString();
      });
    }
  }

  List<ExamScheduleModel>
      _schedulesForExam(
    int examinationId,
  ) {
    return _schedules
        .where(
          (schedule) =>
              schedule.examinationId ==
              examinationId,
        )
        .toList();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor:
            const Color(0xff1565C0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Exams',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_exams.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadExams,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(
              height: 180,
            ),
            _emptyState(
              Icons.assignment_outlined,
              'No exams available',
              'There are no examinations available for your school.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadExams,
      child: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          Text(
            'Examination Schedule',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_schedules.length} schedule${_schedules.length == 1 ? '' : 's'} assigned to you',
            style: GoogleFonts.poppins(
              color:
                  Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          ..._exams.map(
            (exam) =>
                _examCard(exam),
          ),
        ],
      ),
    );
  }

  Widget _examCard(
    ExaminationModel exam,
  ) {
    final schedules =
        _schedulesForExam(exam.id);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xffE3F2FD),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .assignment_turned_in,
                  color:
                      Color(0xff1565C0),
                  size: 28,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      exam.name,
                      style:
                          GoogleFonts
                              .poppins(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      exam.examType,
                      style:
                          GoogleFonts
                              .poppins(
                        color: Colors
                            .grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(
                exam.status,
              ),
            ],
          ),

          if (exam.description !=
                  null &&
              exam.description!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            Text(
              exam.description!,
              style:
                  GoogleFonts.poppins(
                color: Colors
                    .grey.shade700,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 18,
                color:
                    Color(0xff1565C0),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                exam.year?.toString() ??
                    'Year not available',
                style:
                    GoogleFonts.poppins(
                  color: Colors
                      .grey.shade700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${schedules.length} subject${schedules.length == 1 ? '' : 's'}',
                style:
                    GoogleFonts.poppins(
                  color:
                      const Color(
                    0xff1565C0,
                  ),
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          if (schedules.isEmpty)
            Container(
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: Text(
                'No schedule assigned to you for this examination.',
                style:
                    GoogleFonts.poppins(
                  color: Colors
                      .grey.shade600,
                  fontSize: 12,
                ),
              ),
            )
          else
            ...schedules.map(
              (schedule) =>
                  _scheduleTile(
                schedule,
              ),
            ),
        ],
      ),
    );
  }

  Widget _scheduleTile(
    ExamScheduleModel schedule,
  ) {
    return InkWell(
      borderRadius:
          BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ExamScheduleScreen(
              schedule: schedule,
            ),
          ),
        );
      },
      child: Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              const Color(0xffF5F8FC),
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color:
                Colors.blue.shade100,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.menu_book,
              color:
                  Color(0xff1565C0),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    schedule.subjectName!,
                    style:
                        GoogleFonts
                            .poppins(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '${schedule.className}${schedule.sectionName != null ? ' - ${schedule.sectionName}' : ''}',
                    style:
                        GoogleFonts
                            .poppins(
                      fontSize: 12,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    '${_formatDate(schedule.examDate)} • ${schedule.maxMarks} Marks',
                    style:
                        GoogleFonts
                            .poppins(
                      fontSize: 12,
                      color:
                          const Color(
                        0xff1565C0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons
                  .arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(
    String? status,
  ) {
    final text =
        status == null ||
                status.trim().isEmpty
            ? 'Scheduled'
            : status;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
            Colors.orange.shade50,
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.orange,
          fontSize: 11,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  Widget _emptyState(
    IconData icon,
    String title,
    String message,
  ) {
    return Padding(
      padding:
          const EdgeInsets.all(25),
      child: Column(
        children: [
          Icon(
            icon,
            size: 65,
            color:
                Colors.grey.shade400,
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                GoogleFonts.poppins(
              fontSize: 18,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                GoogleFonts.poppins(
              fontSize: 13,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .cloud_off_outlined,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              'Unable to load exams',
              style:
                  GoogleFonts.poppins(
                fontSize: 18,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              _errorMessage ??
                  'Unknown error',
              textAlign:
                  TextAlign.center,
              style:
                  GoogleFonts.poppins(
                fontSize: 12,
                color: Colors
                    .grey.shade600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed:
                  _loadExams,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xff1565C0,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(
    DateTime? date,
  ) {
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