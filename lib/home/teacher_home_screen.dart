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
import 'package:teacher_app/teacher/dashboard/teacher_dashboard_screen.dart';
import 'package:teacher_app/teacher/class_workspace_screen.dart';
import 'dart:async';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int selectedIndex = 0;
  int _selectedIndexForButtom = 0;
  final PageController _pageController = PageController();

  final List<String> banners = [
    "https://picsum.photos/800/300?random=1",
    "https://picsum.photos/800/300?random=2",
    "https://picsum.photos/800/300?random=3",
    "https://picsum.photos/800/300?random=4",
  ];
  int currentPage = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        currentPage++;

        if (currentPage >= banners.length) {
          currentPage = 0;
        }

        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.white,
        centerTitle: true,

        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TeacherProfileScreen()),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"),
            ),
          ),
        ),

        title: const Text(
          "SmartKids",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => const NotificationsScreen(),
                    //   ),
                    // );
                  },
                  icon: const Icon(Icons.notifications, color: Colors.blue),
                ),

                Positioned(
                  right: 5,
                  top: 8,
                  child: Container(
                    height: 18,
                    width: 18,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "3",
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //================ HEADER =================//
              // Container(
              //   padding: const EdgeInsets.only(
              //     left: 20,
              //     right: 20,
              //     top: 30,
              //     bottom: 35,
              //   ),

              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //       colors: [Color(0xff1565C0), Color(0xff42A5F5)],

              //       begin: Alignment.topLeft,

              //       end: Alignment.bottomRight,
              //     ),

              //     borderRadius: BorderRadius.only(
              //       bottomLeft: Radius.circular(35),

              //       bottomRight: Radius.circular(35),
              //     ),
              //   ),

              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,

              //         children: [
              //           Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,

              //             children: [
              //               Text(
              //                 "Good Morning 👋",

              //                 style: GoogleFonts.poppins(
              //                   color: Colors.white70,

              //                   fontSize: 15,
              //                 ),
              //               ),

              //               Text(
              //                 "Mrs. Anitha",

              //                 style: GoogleFonts.poppins(
              //                   color: Colors.white,

              //                   fontSize: 26,

              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),

              //               Text(
              //                 "Mathematics Teacher",

              //                 style: GoogleFonts.poppins(color: Colors.white70),
              //               ),
              //             ],
              //           ),

              //           GestureDetector(
              //             onTap: () {
              //               Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (_) => const TeacherProfileScreen(),
              //                 ),
              //               );
              //             },
              //             child: const CircleAvatar(
              //               radius: 30,
              //               backgroundColor: Colors.white,
              //               child: Icon(
              //                 Icons.person,
              //                 size: 40,
              //                 color: Color(0xff1565C0),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
             
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(banners[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Today's Birthdays",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // SizedBox(
                    //   height: 95,
                    //   child: ListView(
                    //     scrollDirection: Axis.horizontal,
                    //     children: [
                    //       _birthdayStory(
                    //         "Rahul",
                    //         "assets/images/students/rahul.jpg",
                    //       ),
                    //       _birthdayStory(
                    //         "Sneha",
                    //         "assets/images/students/sneha.jpg",
                    //       ),
                    //       _birthdayStory(
                    //         "Arjun",
                    //         "assets/images/students/arjun.jpg",
                    //       ),
                    //       _birthdayStory(
                    //         "Anjali",
                    //         "assets/images/students/anjali.jpg",
                    //       ),
                    //       _birthdayStory(
                    //         "Vikram",
                    //         "assets/images/students/vikram.jpg",
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _birthdayStory(
                            "Keerthi",
                            "https://i.pravatar.cc/150?img=45",
                          ),

                          _birthdayStory(
                            "Rahul",
                            "https://i.pravatar.cc/150?img=12",
                          ),

                          _birthdayStory(
                            "Ananya",
                            "https://i.pravatar.cc/150?img=32",
                          ),

                          _birthdayStory(
                            "Arjun",
                            "https://i.pravatar.cc/150?img=60",
                          ),
                          _birthdayStory(
                            "vijay",
                            "https://i.pravatar.cc/150?img=12",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => const MarksEntryScreen(),
                            //   ),
                            // );
                          },
                          child: _actionCard(Icons.grade, "Birthdays"),
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => const MarksEntryScreen(),
                            //   ),
                            // );
                          },
                          child: _actionCard(Icons.grade, "Achievements"),
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
                          child: _actionCard(Icons.grade, "Announcements"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    const SizedBox(height: 25),

                    Text(
                      "Today's Classes",

                      style: GoogleFonts.poppins(
                        fontSize: 22,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _classCard(
                      context,
                      "Class 6 - A",
                      "Mathematics",
                      "10:00 AM",
                      "42",
                    ),

                    _classCard(
                      context,
                      "Class 7 - B",
                      "Algebra",
                      "12:00 PM",
                      "38",
                    ),

                    _classCard(
                      context,
                      "Class 8 - A",
                      "Geometry",
                      "02:00 PM",
                      "45",
                    ),

                    const SizedBox(height: 25),

                    // _dashboardStats(),
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

  Widget _birthdayStory(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink, width: 3),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(imageUrl),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 60,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _classCard(
    BuildContext context,
    String className,
    String subject,
    String time,
    String students,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClassWorkspaceScreen(
              className: className,
              subject: subject,
              students: students,
            ),
          ),
        );
      },

      child: Container(
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
      ),
    );
  }
}
