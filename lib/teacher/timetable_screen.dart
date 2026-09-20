import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:teacher_app/auth/auth_storage.dart';
import 'package:teacher_app/models/teacher_timetable_model.dart';
import 'package:teacher_app/services/teacher_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String selectedDay = "Monday";

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  List<TeacherTimetableModel> timetable = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    // Open today's day by default
    selectedDay = _getTodayDisplayDay();

    _loadTimetable();
  }

  // ============================================================
  // LOAD COMPLETE TEACHER TIMETABLE
  // ============================================================
  Future<void> _loadTimetable() async {
    try {
      final token = await AuthStorage.getToken();
      final userId = await AuthStorage.getUserId();
      final teacherId = await AuthStorage.getTeacherId();

      debugPrint("==========================================");
      debugPrint("           TIMETABLE LOAD");
      debugPrint("==========================================");
      debugPrint("User ID    : $userId");
      debugPrint("Teacher ID : $teacherId");
      debugPrint("Token      : ${token != null && token.isNotEmpty}");
      debugPrint("==========================================");

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage = "Login session expired.";
        });

        return;
      }

      if (teacherId == null) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          errorMessage = "Teacher ID not found.";
        });

        return;
      }

      final teacherService = TeacherService(token);

      debugPrint("Calling timetable API with Teacher ID: $teacherId");

      final data = await teacherService.getTeacherTimetable(teacherId);

      debugPrint("==========================================");
      debugPrint("       API TIMETABLE RESPONSE");
      debugPrint("==========================================");
      debugPrint("Teacher ID : $teacherId");
      debugPrint("Records    : ${data.length}");

      for (final item in data) {
        debugPrint(
          "DAY=${item.dayOfWeek}, "
          "SUBJECT=${item.subjectName}, "
          "CLASS=${item.className}, "
          "SECTION=${item.sectionName}, "
          "START=${item.startTime}, "
          "END=${item.endTime}",
        );
      }

      debugPrint("==========================================");

      data.sort((a, b) {
        final dayCompare = _dayOrder(
          a.dayOfWeek,
        ).compareTo(_dayOrder(b.dayOfWeek));

        if (dayCompare != 0) {
          return dayCompare;
        }

        return a.startTime.compareTo(b.startTime);
      });

      if (!mounted) return;

      setState(() {
        timetable = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e, stackTrace) {
      debugPrint("==========================================");
      debugPrint("FULL TIMETABLE ERROR");
      debugPrint("$e");
      debugPrint("$stackTrace");
      debugPrint("==========================================");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = "Failed to load timetable.";
      });
    }
  }

  // ============================================================
  // GET SELECTED DAY CLASSES
  // ============================================================
  List<TeacherTimetableModel> get selectedDayClasses {
    final backendDay = _convertToBackendDay(selectedDay);

    debugPrint("========== TIMETABLE FILTER ==========");
    debugPrint("Selected Day: $selectedDay");
    debugPrint("Backend Day: $backendDay");
    debugPrint("Total Timetable Records: ${timetable.length}");

    for (final item in timetable) {
      debugPrint(
        "API ITEM => dayOfWeek=[${item.dayOfWeek}], "
        "subject=[${item.subjectName}], "
        "start=[${item.startTime}], "
        "class=[${item.className}]",
      );
    }

    final result = timetable.where((item) {
      final itemDay = item.dayOfWeek.trim().toUpperCase();

      debugPrint(
        "COMPARE => itemDay=[$itemDay] == backendDay=[$backendDay] "
        "=> ${itemDay == backendDay}",
      );

      return itemDay == backendDay;
    }).toList();

    result.sort((a, b) => a.startTime.compareTo(b.startTime));

    debugPrint("Filtered Records: ${result.length}");

    return result;
  }
  // ============================================================
  // TODAY
  // ============================================================

  String _getTodayDisplayDay() {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[DateTime.now().weekday - 1];
  }

  // ============================================================
  // FRONTEND DAY -> BACKEND DAY
  // ============================================================

  String _convertToBackendDay(String day) {
    return day.toUpperCase();
  }

  // ============================================================
  // DAY ORDER
  // ============================================================

  int _dayOrder(String day) {
    const order = {
      "MONDAY": 1,
      "TUESDAY": 2,
      "WEDNESDAY": 3,
      "THURSDAY": 4,
      "FRIDAY": 5,
      "SATURDAY": 6,
      "SUNDAY": 7,
    };

    return order[day.toUpperCase()] ?? 99;
  }

  // ============================================================
  // TIME FORMAT
  // ============================================================

  String _formatTime(String time) {
    try {
      final parts = time.split(':');

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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
        centerTitle: true,

        title: Text(
          "Timetable",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadTimetable,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Weekly Schedule",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            // =====================================================
            // DAY SELECTOR
            // =====================================================
            SizedBox(
              height: 45,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,

                itemBuilder: (context, index) {
                  final day = days[index];

                  final active = selectedDay == day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(right: 10),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: active ? const Color(0xff1565C0) : Colors.white,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        day,

                        style: GoogleFonts.poppins(
                          color: active ? Colors.white : Colors.black87,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // =====================================================
            // TIMETABLE
            // =====================================================
            Expanded(child: _buildTimetableContent()),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIMETABLE CONTENT
  // ============================================================

  Widget _buildTimetableContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),

            const SizedBox(height: 10),

            Text(errorMessage!, style: GoogleFonts.poppins()),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: _loadTimetable,
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    final classes = selectedDayClasses;

    if (classes.isEmpty) {
      return Center(
        child: Text(
          "No classes scheduled for $selectedDay.",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: classes.length,

      itemBuilder: (context, index) {
        return _classCard(classes[index]);
      },
    );
  }

  // ============================================================
  // CLASS CARD
  // ============================================================

  Widget _classCard(TeacherTimetableModel item) {
    final classText = item.sectionName == null || item.sectionName!.isEmpty
        ? item.className
        : '${item.className} - ${item.sectionName}';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),

      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,

            decoration: const BoxDecoration(
              color: Color(0xffE3F2FD),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.schedule,
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
                  item.subjectName,

                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  classText,

                  style: GoogleFonts.poppins(color: Colors.grey.shade700),
                ),

                if (item.roomNumber != null && item.roomNumber!.isNotEmpty)
                  Text(
                    "Room: ${item.roomNumber}",

                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),

          Column(
            children: [
              const Icon(Icons.access_time, color: Color(0xff1565C0)),

              const SizedBox(height: 5),

              Text(
                _formatTime(item.startTime),

                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                _formatTime(item.endTime),

                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
