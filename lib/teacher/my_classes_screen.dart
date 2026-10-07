import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/class_model.dart';
import '../models/teacher_assignment_model.dart';
import '../services/class_service.dart';
import '../services/teacher_service.dart';
import 'class_workspace_screen.dart';

class MyClassesScreen extends StatefulWidget {
  const MyClassesScreen({super.key});

  @override
  State<MyClassesScreen> createState() => _MyClassesScreenState();
}

class _MyClassesScreenState extends State<MyClassesScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  List<TeacherAssignmentModel> assignments = [];
  final Map<int, ClassModel> classDetails = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  // ============================================================
  // LOAD CLASSES
  // ============================================================

  Future<void> _loadClasses() async {
    try {
      debugPrint('========================================');
      debugPrint('MY CLASSES: START LOADING');

      if (mounted) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
      }

      // ----------------------------------------------------------
      // TOKEN
      // ----------------------------------------------------------

      final token = await AuthStorage.getToken();

      debugPrint('TOKEN EXISTS: ${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found. Please login again.');
      }

      // ----------------------------------------------------------
      // TEACHER ID
      // ----------------------------------------------------------

      final teacherId = await AuthStorage.getTeacherId();

      debugPrint('TEACHER ID FROM STORAGE: $teacherId');

      if (teacherId == null) {
        throw Exception('Teacher ID not found. Please login again.');
      }

      if (teacherId <= 0) {
        throw Exception('Invalid Teacher ID. Please login again.');
      }

      // ----------------------------------------------------------
      // SERVICES
      // ----------------------------------------------------------

      final teacherService = TeacherService(token);
      final classService = ClassService(token);

      // ----------------------------------------------------------
      // TEACHER ASSIGNMENTS
      // ----------------------------------------------------------

      final result = await teacherService.getTeacherAssignments(teacherId);

      debugPrint('Teacher assignments received: ${result.length}');

      // ----------------------------------------------------------
      // LOAD CLASS DETAILS
      // ----------------------------------------------------------

      final Map<int, ClassModel> loadedClasses = {};

      for (final assignment in result) {
        try {
          final classData = await classService.getClassById(assignment.classId);

          loadedClasses[assignment.classId] = classData;
        } catch (e) {
          debugPrint('Class ${assignment.classId} load failed: $e');
        }
      }

      // ----------------------------------------------------------
      // UPDATE UI
      // ----------------------------------------------------------

      if (!mounted) return;

      setState(() {
        assignments = result;

        classDetails
          ..clear()
          ..addAll(loadedClasses);

        isLoading = false;
      });

      debugPrint(
        'MY CLASSES FINISHED. '
        'Classes loaded: ${loadedClasses.length}',
      );

      debugPrint('========================================');
    } catch (e) {
      debugPrint('MY CLASSES ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  // ============================================================
  // CLASS NAME
  // ============================================================

  String _getClassName(TeacherAssignmentModel assignment) {
    final classData = classDetails[assignment.classId];

    if (classData != null && classData.name.isNotEmpty) {
      return classData.name;
    }

    return 'Class ${assignment.classId}';
  }

  // ============================================================
  // UNIQUE CLASSES
  // ============================================================

  int get _uniqueClassCount {
    return assignments.map((e) => e.classId).toSet().length;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: textColor),
        ),

        title: Text(
          'My Classes',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),

            decoration: BoxDecoration(
              color: const Color(0xffF1F6FC),
              borderRadius: BorderRadius.circular(12),
            ),

            child: IconButton(
              onPressed: _loadClasses,

              icon: const Icon(
                Icons.refresh_rounded,
                color: primaryColor,
                size: 21,
              ),
            ),
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoading();
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (assignments.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadClasses,

      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),

            sliver: SliverToBoxAdapter(child: _buildSummaryHeader()),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 10),

            sliver: SliverToBoxAdapter(child: _buildSectionHeader()),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),

            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final assignment = assignments[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _classCard(context, assignment, index),
                );
              }, childCount: assignments.length),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY HEADER
  // ============================================================

  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(21),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      'Teaching Dashboard',

                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      'Manage your assigned classes',

                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _summaryStat(
                  icon: Icons.groups_rounded,
                  value: _uniqueClassCount.toString(),
                  label: 'Classes',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _summaryStat(
                  icon: Icons.menu_book_rounded,
                  value: assignments.length.toString(),
                  label: 'Subjects',
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _summaryStat(
                  icon: Icons.verified_rounded,
                  value: 'Active',
                  label: 'Status',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 19),

          const SizedBox(height: 6),

          Text(
            value,

            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            label,

            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.75),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'Assigned Classes',

                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                'Your teaching assignments',

                style: GoogleFonts.poppins(
                  color: const Color(0xff8993A2),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

          decoration: BoxDecoration(
            color: const Color(0xffEAF3FF),
            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            '${assignments.length} assignments',

            style: GoogleFonts.poppins(
              color: primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CLASS CARD
  // ============================================================

  Widget _classCard(
    BuildContext context,
    TeacherAssignmentModel assignment,
    int index,
  ) {
    final className = _getClassName(assignment);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(23),

      child: InkWell(
        borderRadius: BorderRadius.circular(23),

        onTap: () {
          _openClassWorkspace(context, assignment, className);
        },

        child: Container(
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),

            border: Border.all(color: const Color(0xffE5EAF1)),
          ),

          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // CLASS ICON
                  // ==================================================

                  Container(
                    width: 55,
                    height: 55,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xffE3F2FD), Color(0xffBBDEFB)],

                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),

                      borderRadius: BorderRadius.circular(17),
                    ),

                    child: const Icon(
                      Icons.class_rounded,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 13),

                  // ==================================================
                  // CLASS DETAILS
                  // ==================================================
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          className,

                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: GoogleFonts.poppins(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // SUBJECT
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_outlined,
                              size: 14,
                              color: Color(0xff7B8797),
                            ),

                            const SizedBox(width: 5),

                            Expanded(
                              child: Text(
                                assignment.subject.isNotEmpty
                                    ? assignment.subject
                                    : 'Subject not available',

                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,

                                style: GoogleFonts.poppins(
                                  color: const Color(0xff7B8797),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        // SECTION BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: const Color(0xffEAF3FF),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,

                            children: [
                              const Icon(
                                Icons.groups_rounded,
                                size: 13,
                                color: primaryColor,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                'Section ${assignment.sectionName ?? '-'}',

                                style: GoogleFonts.poppins(
                                  color: primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ==================================================
                  // STATUS
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),

                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Container(
                          width: 6,
                          height: 6,

                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          'Active',

                          style: GoogleFonts.poppins(
                            color: Colors.green.shade700,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DETAILS
              // ==================================================
              Container(
                padding: const EdgeInsets.all(12),

                decoration: BoxDecoration(
                  color: const Color(0xffF7F9FC),
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: _detailItem(
                        icon: Icons.tag_rounded,
                        label: 'Class ID',
                        value: assignment.classId.toString(),
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 34,
                      color: const Color(0xffE3E8EF),
                    ),

                    Expanded(
                      child: _detailItem(
                        icon: Icons.groups_rounded,
                        label: 'Section',
                        value: assignment.sectionName ?? '-',
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 34,
                      color: const Color(0xffE3E8EF),
                    ),

                    Expanded(
                      child: _detailItem(
                        icon: Icons.subject_rounded,
                        label: 'Subject',
                        value: assignment.subject,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // OPEN WORKSPACE BUTTON
              // ==================================================
              SizedBox(
                width: double.infinity,
                height: 46,

                child: ElevatedButton(
                  onPressed: () {
                    _openClassWorkspace(context, assignment, className);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        'Open Class Workspace',

                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(width: 7),

                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL ITEM
  // ============================================================

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, size: 16, color: primaryColor),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: GoogleFonts.poppins(
                  color: const Color(0xff929BA8),
                  fontSize: 9.5,
                ),
              ),

              const SizedBox(height: 1),

              Text(
                value,

                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // OPEN WORKSPACE
  // ============================================================

  void _openClassWorkspace(
    BuildContext context,
    TeacherAssignmentModel assignment,
    String className,
  ) {
    // ----------------------------------------------------------
    // SECTION VALIDATION
    // ----------------------------------------------------------

    if (assignment.sectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Section is not assigned for this teaching assignment.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // SUBJECT VALIDATION
    // ----------------------------------------------------------

    if (assignment.subjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subject is not properly assigned for this teaching assignment.',
          ),
        ),
      );

      return;
    }

    // ----------------------------------------------------------
    // OPEN CLASS WORKSPACE
    // ----------------------------------------------------------

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClassWorkspaceScreen(
          classId: assignment.classId,
          className: className,
          subjectId: assignment.subjectId!,
          subject: assignment.subject,
          sectionId: assignment.sectionId!,
          sectionName: assignment.sectionName ?? '',
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            width: 65,
            height: 65,

            decoration: BoxDecoration(
              color: const Color(0xffEAF3FF),
              borderRadius: BorderRadius.circular(20),
            ),

            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: primaryColor,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Loading your classes...',

            style: GoogleFonts.poppins(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Please wait a moment',

            style: GoogleFonts.poppins(
              color: const Color(0xff8A94A3),
              fontSize: 11,
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
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration: BoxDecoration(
                color: const Color(0xffffebee),
                borderRadius: BorderRadius.circular(24),
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to load classes',

              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              errorMessage ?? 'Something went wrong.',

              textAlign: TextAlign.center,

              maxLines: 3,
              overflow: TextOverflow.ellipsis,

              style: GoogleFonts.poppins(
                color: const Color(0xff7A8697),
                fontSize: 11.5,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadClasses,

              icon: const Icon(Icons.refresh_rounded, size: 18),

              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadClasses,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.28),

          Center(
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,

                  decoration: BoxDecoration(
                    color: const Color(0xffEAF3FF),
                    borderRadius: BorderRadius.circular(26),
                  ),

                  child: const Icon(
                    Icons.school_outlined,
                    color: primaryColor,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  'No classes assigned',

                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Your assigned classes will appear here.',

                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    color: const Color(0xff8993A2),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Pull down to refresh',

                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
