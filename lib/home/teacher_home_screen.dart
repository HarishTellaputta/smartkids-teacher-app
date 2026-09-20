import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:teacher_app/auth/auth_storage.dart';
import 'package:teacher_app/models/teacher_timetable_model.dart';
import 'package:teacher_app/services/teacher_service.dart';

import 'package:teacher_app/teacher/timetable_screen.dart';
import 'package:teacher_app/teacher/my_classes_screen.dart';
import 'package:teacher_app/teacher/teacher_profile_screen.dart';
import 'package:teacher_app/teacher/leave_request_screen.dart';
import 'package:teacher_app/teacher/class_workspace_screen.dart';
import 'package:teacher_app/teacher/exams_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color backgroundColor = Color(0xffF5F8FC);

  int _selectedIndex = 0;

  String teacherName = 'Teacher';

  List<TeacherTimetableModel> todayClasses = [];
  bool isLoadingTodayClasses = true;

  @override
  void initState() {
    super.initState();
    _loadTeacherName();
    _loadTodayClasses();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_selectedIndex == 1) {
      return const MyClassesScreen();
    }

    if (_selectedIndex == 2) {
      return const TeacherProfileScreen();
    }

    return _buildHome();
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadTodayClasses();
        await _loadTeacherName();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            const SizedBox(height: 24),

            _buildTodaySummary(),

            const SizedBox(height: 28),

            _buildSectionTitle(
              title: 'Quick Access',
              subtitle: 'Manage your daily activities',
            ),

            const SizedBox(height: 14),

            _buildQuickActions(),

            const SizedBox(height: 30),

            _buildSectionTitle(
              title: "Today's Classes",
              subtitle: 'Your scheduled classes for today',
            ),

            const SizedBox(height: 14),

            _buildTodayClasses(),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xffE3F2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person,
              color: primaryColor,
              size: 28,
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                teacherName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff172033),
                ),
              ),
            ],
          ),
        ),

        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xffE7ECF3),
            ),
          ),
          child: IconButton(
            onPressed: () {
              // Notifications can be connected later.
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: primaryColor,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TODAY SUMMARY
  // ============================================================

  Widget _buildTodaySummary() {
    final count = todayClasses.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Overview",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isLoadingTodayClasses
                      ? 'Loading your classes...'
                      : count == 0
                          ? 'No classes scheduled today'
                          : '$count ${count == 1 ? 'class' : 'classes'} scheduled today',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (!isLoadingTodayClasses)
            Text(
              '$count',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: const Color(0xff172033),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.65,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _quickActionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Timetable',
          subtitle: 'View schedule',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TimetableScreen(),
              ),
            );
          },
        ),

        _quickActionCard(
          icon: Icons.menu_book_rounded,
          title: 'Exams',
          subtitle: 'Exams & marks',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ExamsScreen(),
              ),
            );
          },
        ),

        _quickActionCard(
          icon: Icons.class_rounded,
          title: 'My Classes',
          subtitle: 'Students & classes',
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
        ),

        _quickActionCard(
          icon: Icons.event_available_rounded,
          title: 'Leave Request',
          subtitle: 'Apply for leave',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LeaveRequestScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xffE8EDF4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xffE3F2FD),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff172033),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TODAY'S CLASSES
  // ============================================================

  Widget _buildTodayClasses() {
    if (isLoadingTodayClasses) {
      return _buildLoadingCard();
    }

    if (todayClasses.isEmpty) {
      return _buildEmptyClassesCard();
    }

    return Column(
      children: todayClasses.map((item) {
        final className = _buildClassName(item);

        return _todayClassCard(
          item: item,
          className: className,
        );
      }).toList(),
    );
  }

  Widget _todayClassCard({
    required TeacherTimetableModel item,
    required String className,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassWorkspaceScreen(
                  classId: item.classId,
                  className: className,
                  subject: item.subjectName,
                  students: '-',
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  width: 62,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xffE3F2FD),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _formatTime(item.startTime),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.access_time_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subjectName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff172033),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            size: 15,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              className,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING CARD
  // ============================================================

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: primaryColor,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY CLASSES
  // ============================================================

  Widget _buildEmptyClassesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: Colors.grey,
              size: 28,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'No classes today',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xff172033),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'You have no scheduled classes for today.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation() {
    return NavigationBar(
      height: 72,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xffE3F2FD),
      elevation: 8,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(
            Icons.home_rounded,
            color: primaryColor,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.class_outlined),
          selectedIcon: const Icon(
            Icons.class_rounded,
            color: primaryColor,
          ),
          label: 'My Classes',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline_rounded),
          selectedIcon: const Icon(
            Icons.person_rounded,
            color: primaryColor,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  // ============================================================
  // LOAD TEACHER NAME
  // ============================================================

  Future<void> _loadTeacherName() async {
    try {
      final username = await AuthStorage.getTeacherUsername();

      if (!mounted) return;

      if (username != null && username.trim().isNotEmpty) {
        setState(() {
          teacherName = username.trim();
        });
      }
    } catch (e) {
      debugPrint('TEACHER NAME ERROR: $e');
    }
  }

  // ============================================================
  // LOAD TODAY CLASSES
  // ============================================================

  Future<void> _loadTodayClasses() async {
    try {
      if (mounted) {
        setState(() {
          isLoadingTodayClasses = true;
        });
      }

      final token = await AuthStorage.getToken();
      final teacherId = await AuthStorage.getTeacherId();

      if (token == null ||
          token.isEmpty ||
          teacherId == null) {
        if (!mounted) return;

        setState(() {
          todayClasses = [];
          isLoadingTodayClasses = false;
        });

        return;
      }

      final teacherService = TeacherService(token);

      final timetable =
          await teacherService.getTodayTimetable(teacherId);

      timetable.sort(
        (a, b) => a.startTime.compareTo(b.startTime),
      );

      if (!mounted) return;

      setState(() {
        todayClasses = timetable;
        isLoadingTodayClasses = false;
      });
    } catch (e) {
      debugPrint('TODAY CLASSES ERROR: $e');

      if (!mounted) return;

      setState(() {
        todayClasses = [];
        isLoadingTodayClasses = false;
      });
    }
  }

  // ============================================================
  // CLASS NAME
  // ============================================================

  String _buildClassName(TeacherTimetableModel item) {
    if (item.sectionName == null ||
        item.sectionName!.trim().isEmpty) {
      return item.className;
    }

    return '${item.className} - ${item.sectionName}';
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(String time) {
    try {
      final parts = time.split(':');

      if (parts.length < 2) {
        return time;
      }

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

      hour = hour % 12;

      if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  // ============================================================
  // GREETING
  // ============================================================

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning 👋';
    }

    if (hour < 17) {
      return 'Good Afternoon 👋';
    }

    return 'Good Evening 👋';
  }
}