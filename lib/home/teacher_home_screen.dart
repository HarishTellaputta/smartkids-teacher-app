import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher_app/teacher/student_list_screen.dart';
import 'package:teacher_app/teacher/assignments_screen.dart';
import 'package:teacher_app/teacher/attendance_screen.dart';
import 'package:teacher_app/teacher/timetable_screen.dart';
import 'package:teacher_app/teacher/marks_entry_screen.dart';
import 'package:teacher_app/teacher/my_classes_screen.dart';
import 'package:teacher_app/teacher/teacher_profile_screen.dart';
import 'package:teacher_app/teacher/homework_screen.dart';
import 'package:teacher_app/teacher/my_classes_screen.dart';
import 'package:teacher_app/teacher/homework_screen.dart';
import 'package:teacher_app/teacher/leave_request_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int selectedIndex = 0;
  int _selectedIndexForButtom = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //================ HEADER =================//
              Container(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 35,
                ),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff1565C0), Color(0xff42A5F5)],

                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),

                    bottomRight: Radius.circular(35),
                  ),
                ),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "Good Morning 👋",

                              style: GoogleFonts.poppins(
                                color: Colors.white70,

                                fontSize: 15,
                              ),
                            ),

                            Text(
                              "Mrs. Anitha",

                              style: GoogleFonts.poppins(
                                color: Colors.white,

                                fontSize: 26,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              "Mathematics Teacher",

                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          ],
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TeacherProfileScreen(),
                              ),
                            );
                          },
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xff1565C0),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Attendance Card
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        children: [
                          Container(
                            height: 55,

                            width: 55,

                            decoration: const BoxDecoration(
                              color: Color(0xffE3F2FD),

                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.calendar_month,

                              color: Color(0xff1565C0),
                            ),
                          ),

                          const SizedBox(width: 15),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                "Today's Attendance",

                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                "Present • 09:00 AM",

                                style: GoogleFonts.poppins(
                                  color: Colors.green,

                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      "Quick Actions",

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
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StudentListScreen(),
                              ),
                            );
                          },
                          child: _actionCard(Icons.people, "Students"),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeworkScreen(),
                              ),
                            );
                          },
                          child: _actionCard(Icons.assignment, "Homework"),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AttendanceScreen(),
                              ),
                            );
                          },
                          child: _actionCard(Icons.fact_check, "Attendance"),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TimetableScreen(),
                              ),
                            );
                          },
                          child: _actionCard(Icons.event_note, "Timetable"),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LeaveRequestScreen(),
                              ),
                            );
                          },
                          child: _actionCard(
                            Icons.notifications,
                            "Leave Requests",
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MarksEntryScreen(),
                              ),
                            );
                          },
                          child: _actionCard(Icons.grade, "Marks"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    Text(
                      "Today's Classes",

                      style: GoogleFonts.poppins(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _classCard("Class 6 - A", "Mathematics", "10:00 AM"),

                    _classCard("Class 7 - B", "Algebra", "12:00 PM"),

                    _classCard("Class 8 - A", "Geometry", "02:00 PM"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndexForButtom,

        onTap: (index) {
          setState(() {
            _selectedIndexForButtom = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeacherHomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyClassesScreen()),
            );
          }
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Myclasses"),
        ],
      ),
    );
  }

  Widget _actionCard(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: Color(0xff1565C0), size: 30),

          const SizedBox(height: 8),

          Text(
            title,

            style: GoogleFonts.poppins(
              fontSize: 12,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _classCard(String className, String subject, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xffE3F2FD),

            child: Icon(Icons.school, color: Color(0xff1565C0)),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  className,

                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),

                Text(subject, style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          ),

          Text(
            time,

            style: GoogleFonts.poppins(
              color: Color(0xff1565C0),

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
