import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  ];

  final Map<String, List<Map<String, String>>> timetable = {
    "Monday": [
      {"time": "09:00 AM", "class": "Class 6 - A", "subject": "Mathematics"},

      {"time": "10:00 AM", "class": "Class 7 - B", "subject": "Algebra"},

      {"time": "12:00 PM", "class": "Class 8 - A", "subject": "Geometry"},

      {"time": "02:00 PM", "class": "Class 9 - B", "subject": "Mathematics"},
    ],

    "Tuesday": [
      {"time": "09:00 AM", "class": "Class 6 - A", "subject": "Mathematics"},

      {"time": "11:00 AM", "class": "Class 8 - A", "subject": "Statistics"},

      {"time": "01:00 PM", "class": "Class 7 - B", "subject": "Practice"},
    ],

    "Wednesday": [
      {"time": "10:00 AM", "class": "Class 9 - B", "subject": "Algebra"},

      {"time": "12:00 PM", "class": "Class 6 - A", "subject": "Revision"},
    ],

    "Thursday": [
      {"time": "09:30 AM", "class": "Class 7 - B", "subject": "Mathematics"},

      {"time": "02:00 PM", "class": "Class 8 - A", "subject": "Geometry"},
    ],

    "Friday": [
      {"time": "10:00 AM", "class": "Class 6 - A", "subject": "Test"},

      {"time": "12:00 PM", "class": "Class 9 - B", "subject": "Mathematics"},
    ],

    "Saturday": [
      {"time": "09:00 AM", "class": "Class 8 - A", "subject": "Doubt Session"},
    ],
  };

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

            SizedBox(
              height: 45,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,

                itemCount: days.length,

                itemBuilder: (context, index) {
                  String day = days[index];

                  bool active = selectedDay == day;

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

            Expanded(
              child: ListView.builder(
                itemCount: timetable[selectedDay]!.length,

                itemBuilder: (context, index) {
                  var item = timetable[selectedDay]![index];

                  return _classCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
                  item["subject"]!,

                  style: GoogleFonts.poppins(
                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  item["class"]!,

                  style: GoogleFonts.poppins(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          Column(
            children: [
              const Icon(Icons.access_time, color: Color(0xff1565C0)),

              const SizedBox(height: 5),

              Text(
                item["time"]!,

                style: GoogleFonts.poppins(
                  fontSize: 12,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
