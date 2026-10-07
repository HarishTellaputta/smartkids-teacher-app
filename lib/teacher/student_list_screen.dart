import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_model.dart';
import '../services/student_service.dart';
import 'student_profile_screen.dart';

class StudentListScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String subject;

  const StudentListScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController searchController = TextEditingController();

  List<StudentModel> students = [];
  List<StudentModel> filteredStudents = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD REAL STUDENTS
  // ============================================================

  Future<void> _loadStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Use your existing JWT key.
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final service = StudentService(token);

      final result = await service.getStudentsByClassId(widget.classId);

      if (!mounted) return;

      setState(() {
        students = result;
        filteredStudents = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load students.';
      });
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _searchStudents(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredStudents = students;
        return;
      }

      filteredStudents = students.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.rollNumber.toLowerCase().contains(query) ||
            student.admissionNo.toLowerCase().contains(query);
      }).toList();
    });
  }

  // ============================================================
  // OPEN PROFILE
  // ============================================================

  void _openStudentProfile(StudentModel student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentProfileScreen(
          studentId: student.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xff172033),
          ),
          onPressed: () => Navigator.pop(context),
        ),

        title: Text(
          'Students',
          style: GoogleFonts.poppins(
            color: const Color(0xff172033),
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadStudents,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Color(0xff1565C0),
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadStudents,

        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),

              sliver: SliverToBoxAdapter(
                child: _buildClassHeader(),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),

              sliver: SliverToBoxAdapter(
                child: _buildSearchBox(),
              ),
            ),

            if (isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildLoading(),
              )
            else if (errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildError(),
              )
            else if (filteredStudents.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmpty(),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),

                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final student = filteredStudents[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _studentCard(student),
                      );
                    },

                    childCount: filteredStudents.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CLASS HEADER
  // ============================================================

  Widget _buildClassHeader() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: const Color(0xff1565C0).withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(17),
            ),

            child: const Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  widget.className,

                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.subject,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    '${students.length} Students',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
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
  // SEARCH
  // ============================================================

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),

        border: Border.all(
          color: const Color(0xffE5EAF1),
        ),
      ),

      child: TextField(
        controller: searchController,

        onChanged: _searchStudents,

        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        decoration: InputDecoration(
          hintText: 'Search by name, roll number...',

          hintStyle: GoogleFonts.poppins(
            color: const Color(0xff9AA4B2),
            fontSize: 13,
          ),

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xff1565C0),
          ),

          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    _searchStudents('');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xff8A94A3),
                  ),
                )
              : null,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _studentCard(StudentModel student) {
    final initials = _getInitials(student.name);

    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),

        onTap: () => _openStudentProfile(student),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            border: Border.all(
              color: const Color(0xffE8EDF4),
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffE3F2FD),
                      Color(0xffBBDEFB),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(17),
                ),

                alignment: Alignment.center,

                child: Text(
                  initials,

                  style: GoogleFonts.poppins(
                    color: const Color(0xff1565C0),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      student.name.isEmpty
                          ? 'Student'
                          : student.name,

                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: GoogleFonts.poppins(
                        color: const Color(0xff172033),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 14,
                          color: Color(0xff7A8697),
                        ),

                        const SizedBox(width: 5),

                        Text(
                          'Roll No: ${student.rollNumber}',
                          style: GoogleFonts.poppins(
                            color: const Color(0xff7A8697),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      'Admission No: ${student.admissionNo}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xff9AA4B2),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xff1565C0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xff1565C0),
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
              width: 70,
              height: 70,

              decoration: BoxDecoration(
                color: const Color(0xffffebee),
                borderRadius: BorderRadius.circular(22),
              ),

              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 34,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to load students',

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Please check your connection and try again.',

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: const Color(0xff7A8697),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _loadStudents,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565C0),
                foregroundColor: Colors.white,
                elevation: 0,
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
                color: const Color(0xffEAF3FF),
                borderRadius: BorderRadius.circular(24),
              ),

              child: const Icon(
                Icons.groups_outlined,
                color: Color(0xff1565C0),
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              searchController.text.isEmpty
                  ? 'No students found'
                  : 'No matching students',

              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              searchController.text.isEmpty
                  ? 'There are no students available for this class.'
                  : 'Try searching with another name or roll number.',

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: const Color(0xff7A8697),
                fontSize: 12.5,
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

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return 'S';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}