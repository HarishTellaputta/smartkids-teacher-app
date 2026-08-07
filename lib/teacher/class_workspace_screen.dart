import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/teacher/student_list_screen.dart';

class ClassWorkspaceScreen extends StatelessWidget {
  final String className;
  final String subject;
  final String students;

  const ClassWorkspaceScreen({
    super.key,
    required this.className,
    required this.subject,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        centerTitle: true,
        title: Text(
          className,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    className,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "$subject • $students Students",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Class Workspace",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
              children: [
                _summaryCard(Icons.people, "Students", students, Colors.blue),
                _summaryCard(
                  Icons.fact_check,
                  "Attendance",
                  "40/42",
                  Colors.green,
                ),
                _summaryCard(Icons.cake, "Birthdays", "1 Today", Colors.pink),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              "Class Tools",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _toolCard(Icons.people, "Students", context),
                _toolCard(Icons.fact_check, "Attendance", context),
                _toolCard(Icons.assignment, "Homework", context),
                _toolCard(Icons.grade, "Marks", context),
                _toolCard(Icons.chat, "Chat", context),
                _toolCard(Icons.emoji_events, "Achievements", context)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _toolCard(IconData icon, String title, BuildContext context) {
    return InkWell(
      onTap: () {
        if (title == "Students") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentListScreen(
                className: className,
                subject: subject,
                students: students,
              ),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xff1565C0), size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
