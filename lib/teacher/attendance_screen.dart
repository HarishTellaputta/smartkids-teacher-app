import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String selectedClass = "Class 6 - A";

  final List<Map<String, dynamic>> students = [
    {"name": "Rahul Kumar", "roll": "01", "present": true},

    {"name": "Anjali Sharma", "roll": "02", "present": true},

    {"name": "Vikram Reddy", "roll": "03", "present": false},

    {"name": "Sneha Patel", "roll": "04", "present": true},

    {"name": "Arjun Kumar", "roll": "05", "present": false},

    {"name": "Priya Singh", "roll": "06", "present": true},
  ];

  @override
  Widget build(BuildContext context) {
    int presentCount = students
        .where((student) => student["present"] == true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Attendance",

          style: GoogleFonts.poppins(
            color: Colors.white,

            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // CLASS SELECT CARD
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Select Class",

                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedClass,

                    decoration: InputDecoration(
                      filled: true,

                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    items:
                        [
                          "Class 6 - A",
                          "Class 7 - B",
                          "Class 8 - A",
                          "Class 9 - B",
                        ].map((item) {
                          return DropdownMenuItem(
                            value: item,

                            child: Text(item),
                          );
                        }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedClass = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Today: 04 Aug 2026",

                        style: GoogleFonts.poppins(
                          color: Colors.grey,

                          fontSize: 13,
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,

                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.green.shade50,

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Text(
                          "$presentCount/${students.length} Present",

                          style: GoogleFonts.poppins(
                            color: Colors.green,

                            fontSize: 12,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: students.length,

                itemBuilder: (context, index) {
                  var student = students[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xffE3F2FD),

                          child: Text(
                            student["roll"],

                            style: const TextStyle(color: Color(0xff1565C0)),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                student["name"],

                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                "Roll No: ${student["roll"]}",

                                style: GoogleFonts.poppins(
                                  color: Colors.grey,

                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Switch(
                          activeColor: const Color(0xff1565C0),

                          value: student["present"],

                          onChanged: (value) {
                            setState(() {
                              student["present"] = value;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1565C0),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Attendance Saved Successfully"),
                    ),
                  );
                },

                child: Text(
                  "Save Attendance",

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontSize: 17,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
