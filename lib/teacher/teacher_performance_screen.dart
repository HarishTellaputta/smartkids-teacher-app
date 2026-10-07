import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/teacher_performance_model.dart';
import '../services/teacher_performance_service.dart';

class TeacherPerformanceScreen extends StatefulWidget {
  const TeacherPerformanceScreen({super.key});

  @override
  State<TeacherPerformanceScreen> createState() =>
      _TeacherPerformanceScreenState();
}

class _TeacherPerformanceScreenState extends State<TeacherPerformanceScreen> {
  List<TeacherPerformanceModel> _performances = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  // ============================================================
  // LOAD PERFORMANCE
  // ============================================================

  Future<void> _loadPerformance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception('Login session expired. Please login again.');
      }

      final service = TeacherPerformanceService(token);

      final data = await service.getMyPerformance();

      if (!mounted) return;

      setState(() {
        _performances = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // CALCULATIONS
  // ============================================================

  double get _overallPercentage {
    if (_performances.isEmpty) return 0;

    double totalWeightedMarks = 0;
    double totalWeightedMaxMarks = 0;

    for (final item in _performances) {
      if (item.assessedCount > 0 && item.maxMarks > 0) {
        totalWeightedMarks += item.averageMarks * item.assessedCount;

        totalWeightedMaxMarks += item.maxMarks * item.assessedCount;
      }
    }

    if (totalWeightedMaxMarks == 0) return 0;

    return (totalWeightedMarks / totalWeightedMaxMarks) * 100;
  }

  int get _totalStudents {
    int total = 0;

    for (final item in _performances) {
      total += item.studentCount;
    }

    return total;
  }

  int get _totalAssessed {
    int total = 0;

    for (final item in _performances) {
      total += item.assessedCount;
    }

    return total;
  }

  String get _overallLabel {
    final percentage = _overallPercentage;

    if (percentage >= 90) return 'Excellent';
    if (percentage >= 75) return 'Very Good';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Needs Improvement';

    return 'Needs Attention';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'My Performance',
          style: TextStyle(
            color: Color(0xFF172033),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF172033)),
      ),
      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_performances.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadPerformance,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        children: [
          _buildOverallCard(),

          const SizedBox(height: 18),

          _buildSummarySection(),

          const SizedBox(height: 24),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Class & Subject Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF172033),
                  ),
                ),
              ),
              Text(
                '${_performances.length} records',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7A8498),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ..._performances.map(
            (performance) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildPerformanceCard(performance),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERALL CARD
  // ============================================================

  Widget _buildOverallCard() {
    final percentage = _overallPercentage;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF263A9F), Color(0xFF5267D9)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF263A9F).withOpacity(0.22),
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
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Performance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Based on your latest examinations',
                      style: TextStyle(color: Color(0xFFDCE2FF), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _overallLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummarySection() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.menu_book_rounded,
            title: 'Subjects',
            value: '${_performances.length}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.groups_rounded,
            title: 'Students',
            value: '$_totalStudents',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            icon: Icons.fact_check_rounded,
            title: 'Assessed',
            value: '$_totalAssessed',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EBF2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF5267D9), size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF172033),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF7A8498),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE CARD
  // ============================================================

  Widget _buildPerformanceCard(TeacherPerformanceModel performance) {
    final percentage = performance.performancePercentage.clamp(0.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EBF2)),
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
          // =====================================================
          // CLASS + SUBJECT
          // =====================================================

          Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Color(0xFF5267D9),
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performance.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Class ${performance.className}'
                      '${performance.sectionName != null && performance.sectionName!.isNotEmpty ? ' • Section ${performance.sectionName}' : ''}',
                      style: const TextStyle(
                        color: Color(0xFF7A8498),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: _performanceBackground(percentage.toDouble()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _performanceColor(percentage.toDouble()),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // =====================================================
          // EXAM
          // =====================================================
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_rounded,
                  size: 19,
                  color: Color(0xFF7A8498),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    performance.latestExamName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (performance.examDate != null)
                  Text(
                    _formatDate(performance.examDate!),
                    style: const TextStyle(
                      color: Color(0xFF7A8498),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 17),

          // =====================================================
          // MARKS
          // =====================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Average Marks',
                style: TextStyle(
                  color: Color(0xFF7A8498),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${performance.averageMarks.toStringAsFixed(1)}'
                ' / ${performance.maxMarks}',
                style: const TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFE9ECF3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _performanceColor(percentage.toDouble()),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // =====================================================
          // STUDENTS
          // =====================================================
          Row(
            children: [
              Expanded(
                child: _miniInfo(
                  Icons.groups_rounded,
                  'Students',
                  '${performance.studentCount}',
                ),
              ),
              Expanded(
                child: _miniInfo(
                  Icons.check_circle_rounded,
                  'Assessed',
                  '${performance.assessedCount}',
                ),
              ),
              Expanded(
                child: _miniInfo(
                  Icons.percent_rounded,
                  'Score',
                  '${percentage.toStringAsFixed(1)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MINI INFO
  // ============================================================

  Widget _miniInfo(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 17, color: const Color(0xFF8A94A8)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF9AA3B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Color(0xFFE05252),
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Unable to load performance',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF7A8498), fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadPerformance,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5267D9),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadPerformance,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.35),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Color(0xFF5267D9),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'No Performance Data',
                    style: TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Performance will appear here once exam results are available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF7A8498), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COLORS
  // ============================================================

  Color _performanceColor(double percentage) {
    if (percentage >= 75) {
      return const Color(0xFF20A36A);
    }

    if (percentage >= 50) {
      return const Color(0xFFE49A22);
    }

    return const Color(0xFFE05252);
  }

  Color _performanceBackground(double percentage) {
    if (percentage >= 75) {
      return const Color(0xFFEAF8F1);
    }

    if (percentage >= 50) {
      return const Color(0xFFFFF6E6);
    }

    return const Color(0xFFFFEEEE);
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
