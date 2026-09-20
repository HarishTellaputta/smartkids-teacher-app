import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/section_model.dart';
import '../models/student_model.dart';
import '../services/section_service.dart';
import '../services/student_service.dart';
import 'attendance_screen.dart';

class ClassStudentsScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String subject;

  // false = normal student list
  // true  = open attendance after section selection
  final bool openAttendance;

  const ClassStudentsScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subject,
    this.openAttendance = false,
  });

  @override
  State<ClassStudentsScreen> createState() => _ClassStudentsScreenState();
}

class _ClassStudentsScreenState extends State<ClassStudentsScreen> {
  List<SectionModel> sections = [];
  List<StudentModel> students = [];

  int? selectedSectionId;

  bool isLoadingSections = true;
  bool isLoadingStudents = false;

  String searchQuery = '';

  bool _attendanceOpened = false;

  @override
  void initState() {
    super.initState();
    _loadSections();
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
  // LOAD SECTIONS
  // ============================================================

  Future<void> _loadSections() async {
    try {
      debugPrint('========================================');
      debugPrint('CLASS STUDENTS: START');
      debugPrint('CLASS ID: ${widget.classId}');
      debugPrint('CLASS NAME: ${widget.className}');
      debugPrint('SUBJECT: ${widget.subject}');
      debugPrint('OPEN ATTENDANCE: ${widget.openAttendance}');

      setState(() {
        isLoadingSections = true;
      });

      final token = await _getToken();

      final service = SectionService(token);

      final result = await service.getSectionsByClassId(
        widget.classId,
      );

      debugPrint('Sections received: ${result.length}');

      for (final section in result) {
        debugPrint(
          'SECTION -> ID: ${section.id}, NAME: ${section.name}',
        );
      }

      if (!mounted) return;

      setState(() {
        sections = result;
        isLoadingSections = false;
      });

      if (sections.isNotEmpty) {
        await _loadStudents(sections.first.id);

        // Attendance was selected from Class Workspace.
        // Open attendance automatically for the first section.
        if (widget.openAttendance &&
            !_attendanceOpened &&
            mounted) {
          _attendanceOpened = true;

          await _openAttendanceForSection(
            sections.first,
          );
        }
      }

      debugPrint('CLASS STUDENTS: FINISHED');
      debugPrint('========================================');
    } catch (e) {
      debugPrint(
        'CLASS STUDENTS SECTION ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoadingSections = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load sections: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // LOAD STUDENTS
  // ============================================================

  Future<void> _loadStudents(int sectionId) async {
    try {
      debugPrint('----------------------------------------');
      debugPrint('LOAD STUDENTS START');
      debugPrint('CLASS ID: ${widget.classId}');
      debugPrint('SECTION ID: $sectionId');

      setState(() {
        selectedSectionId = sectionId;
        isLoadingStudents = true;
        students = [];
      });

      final token = await _getToken();

      final studentService = StudentService(token);

      final loadedStudents =
          await studentService.getStudentsBySectionId(
        sectionId,
      );

      debugPrint(
        'Students received: ${loadedStudents.length}',
      );

      for (final student in loadedStudents) {
        debugPrint(
          'STUDENT -> '
          'ID: ${student.id}, '
          'NAME: ${student.name}, '
          'ROLL: ${student.rollNumber}',
        );
      }

      if (!mounted) return;

      setState(() {
        students = loadedStudents;
        isLoadingStudents = false;
      });

      debugPrint(
        'TOTAL STUDENTS LOADED: ${loadedStudents.length}',
      );

      debugPrint('LOAD STUDENTS FINISHED');
      debugPrint('----------------------------------------');
    } catch (e) {
      debugPrint(
        'LOAD STUDENTS ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoadingStudents = false;
        students = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load students: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // OPEN ATTENDANCE
  // ============================================================

  Future<void> _openAttendance() async {
    if (selectedSectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a section first.',
          ),
        ),
      );

      return;
    }

    final selectedSection = sections.firstWhere(
      (section) => section.id == selectedSectionId,
    );

    await _openAttendanceForSection(
      selectedSection,
    );
  }

  // ============================================================
  // OPEN ATTENDANCE FOR SECTION
  // ============================================================

  Future<void> _openAttendanceForSection(
    SectionModel section,
  ) async {
    final teacherId = await AuthStorage.getTeacherId();

    if (teacherId == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Teacher ID not found. Please login again.',
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendanceScreen(
          classId: widget.classId,
          teacherId: teacherId,
          className:
              '${widget.className} - Section ${section.name}',
          sectionId: section.id,
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

      return name.contains(query) ||
          roll.contains(query);
    }).toList();
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
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.className,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.subject,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSectionSelector(),

          if (!widget.openAttendance)
            _buildStudentHeader(),

          Expanded(
            child: _buildStudents(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION SELECTOR
  // ============================================================

  Widget _buildSectionSelector() {
    if (isLoadingSections) {
      return Container(
        height: 70,
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (sections.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Text(
          'No sections found for this class.',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sections',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];

                final isSelected =
                    selectedSectionId == section.id;

                return Padding(
                  padding: const EdgeInsets.only(
                    right: 10,
                  ),
                  child: ChoiceChip(
                    label: Text(
                      'Section ${section.name}',
                    ),
                    selected: isSelected,
                    onSelected: (_) async {
                      await _loadStudents(
                        section.id,
                      );

                      // In attendance mode, selecting
                      // another section opens its attendance.
                      if (widget.openAttendance &&
                          mounted) {
                        await _openAttendanceForSection(
                          section,
                        );
                      }
                    },
                    selectedColor:
                        const Color(0xff1565C0),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade800,
                    ),
                    backgroundColor:
                        const Color(0xffF1F4F8),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xff1565C0)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              },
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Students',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE3F2FD),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  '${students.length} Students',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff1565C0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // SEARCH
          TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name or roll number',
              hintStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 20,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: const Color(0xffF5F8FC),
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STUDENTS LIST
  // ============================================================

  Widget _buildStudents() {
    if (isLoadingStudents) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (selectedSectionId == null) {
      return Center(
        child: Text(
          'Select a section',
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final visibleStudents = filteredStudents;

    if (visibleStudents.isEmpty) {
      return RefreshIndicator(
        onRefresh: () {
          return _loadStudents(
            selectedSectionId!,
          );
        },
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.45,
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 55,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    searchQuery.isEmpty
                        ? 'No students found'
                        : 'No matching students',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    searchQuery.isEmpty
                        ? 'No students are assigned to this section.'
                        : 'Try another name or roll number.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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

    return RefreshIndicator(
      onRefresh: () {
        return _loadStudents(
          selectedSectionId!,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          20,
        ),
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: visibleStudents.length,
        itemBuilder: (context, index) {
          final student = visibleStudents[index];

          return _buildStudentCard(
            student,
            index,
          );
        },
      ),
    );
  }

  // ============================================================
  // STUDENT CARD
  // ============================================================

  Widget _buildStudentCard(
    StudentModel student,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ROLL NUMBER
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xffE3F2FD),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: Text(
              student.rollNumber.isNotEmpty
                  ? student.rollNumber
                  : '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xff1565C0),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // NAME
          Expanded(
            child: Text(
              student.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          // SERIAL NUMBER
          Text(
            '#${index + 1}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}