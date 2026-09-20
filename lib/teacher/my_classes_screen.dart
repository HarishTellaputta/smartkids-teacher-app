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
  List<TeacherAssignmentModel> assignments = [];
  final Map<int, ClassModel> classDetails = {};

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

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

      // -----------------------------------------
      // GET LOGIN TOKEN
      // -----------------------------------------
      final token = await AuthStorage.getToken();

      debugPrint('TOKEN EXISTS: ${token != null && token.isNotEmpty}');

      if (token == null || token.isEmpty) {
        throw Exception('Login token not found. Please login again.');
      }

      // -----------------------------------------
      // GET LOGGED-IN TEACHER ID
      // -----------------------------------------
      final teacherId = await AuthStorage.getTeacherId();

      debugPrint('TEACHER ID FROM STORAGE: $teacherId');

      if (teacherId == null) {
        throw Exception('Teacher ID not found. Please login again.');
      }

      if (teacherId <= 0) {
        throw Exception('Invalid Teacher ID. Please login again.');
      }

      debugPrint('Using Teacher ID: $teacherId');
      debugPrint('Calling TeacherService...');

      // -----------------------------------------
      // SERVICES
      // -----------------------------------------
      final teacherService = TeacherService(token);
      final classService = ClassService(token);

      // -----------------------------------------
      // GET TEACHER ASSIGNMENTS
      // -----------------------------------------
      final result = await teacherService.getTeacherAssignments(teacherId);

      debugPrint('Teacher assignments received: ${result.length}');

      for (final assignment in result) {
        debugPrint(
          'ASSIGNMENT -> '
          'Class ID: ${assignment.classId}, '
          'Subject: ${assignment.subject}',
        );
      }

      // -----------------------------------------
      // LOAD CLASS DETAILS
      // -----------------------------------------
      final Map<int, ClassModel> loadedClasses = {};

      for (final assignment in result) {
        try {
          debugPrint(
            'Calling ClassService for class ID: '
            '${assignment.classId}',
          );

          final classData = await classService.getClassById(assignment.classId);

          debugPrint(
            'CLASS RECEIVED -> '
            'ID: ${classData.id}, '
            'Name: ${classData.name}',
          );

          loadedClasses[assignment.classId] = classData;
        } catch (e) {
          debugPrint('Class ${assignment.classId} load failed: $e');
        }
      }

      // -----------------------------------------
      // UPDATE UI
      // -----------------------------------------
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

  String _getClassName(TeacherAssignmentModel assignment) {
    final classData = classDetails[assignment.classId];

    if (classData != null && classData.name.isNotEmpty) {
      return classData.name;
    }

    return 'Class ${assignment.classId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff1565C0),

        title: Text(
          "My Classes",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(Icons.error_outline, size: 55, color: Colors.red),

              const SizedBox(height: 15),

              Text(
                "Unable to load classes",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loadClasses,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (assignments.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadClasses,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.35),

            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "No classes assigned",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
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
      onRefresh: _loadClasses,

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(20),

        children: [
          Text(
            "Assigned Classes",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            "${assignments.length} subject assignment${assignments.length == 1 ? '' : 's'}",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 15),

          ...assignments.map((assignment) => _classCard(context, assignment)),
        ],
      ),
    );
  }

  Widget _classCard(BuildContext context, TeacherAssignmentModel assignment) {
    final className = _getClassName(assignment);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 55,
                width: 55,

                decoration: const BoxDecoration(
                  color: Color(0xffE3F2FD),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.school,
                  color: Color(0xff1565C0),
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      className,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      assignment.subject,
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  "Active",
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _infoTile(
                  Icons.class_,
                  "Class ID: ${assignment.classId}",
                ),
              ),

              Expanded(child: _infoTile(Icons.menu_book, assignment.subject)),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 45,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565C0),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassWorkspaceScreen(
                      classId: assignment.classId,
                      className: className,
                      subject: assignment.subject,
                      students: "Students",
                    ),
                  ),
                );
              },

              child: Text(
                "View Students",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xff1565C0)),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
