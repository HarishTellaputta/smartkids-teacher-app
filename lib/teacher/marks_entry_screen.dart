import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  String selectedClass = "Class 6 - A";

  String selectedSubject = "Mathematics";

  final List<Map<String, dynamic>> students = [
    {"name": "Rahul Kumar", "roll": "01", "marks": ""},

    {"name": "Anjali Sharma", "roll": "02", "marks": ""},

    {"name": "Vikram Reddy", "roll": "03", "marks": ""},

    {"name": "Sneha Patel", "roll": "04", "marks": ""},

    {"name": "Arjun Kumar", "roll": "05", "marks": ""},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Marks Entry",

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
            // FILTER CARD
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedClass,

                    decoration: _inputDecoration("Select Class"),

                    items:
                        [
                          "Class 6 - A",
                          "Class 7 - B",
                          "Class 8 - A",
                          "Class 9 - B",
                        ].map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedClass = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: selectedSubject,

                    decoration: _inputDecoration("Select Subject"),

                    items: ["Mathematics", "Science", "English", "Social"].map((
                      e,
                    ) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedSubject = value!;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: students.length,

                itemBuilder: (context, index) {
                  return _studentMarkCard(index);
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
                    const SnackBar(content: Text("Marks Saved Successfully")),
                  );
                },

                child: Text(
                  "Save Marks",

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

  Widget _studentMarkCard(int index) {
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

                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),

                Text(
                  "Grade: ${_getGrade(student["marks"])}",

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 70,

            child: TextField(
              keyboardType: TextInputType.number,

              textAlign: TextAlign.center,

              onChanged: (value) {
                students[index]["marks"] = value;

                setState(() {});
              },

              decoration: InputDecoration(
                hintText: "0",

                filled: true,

                fillColor: Colors.grey.shade100,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGrade(String marks) {
    if (marks.isEmpty) {
      return "-";
    }

    int score = int.tryParse(marks) ?? 0;

    if (score >= 90) {
      return "A+";
    } else if (score >= 75) {
      return "A";
    } else if (score >= 60) {
      return "B";
    } else if (score >= 40) {
      return "C";
    }

    return "Fail";
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,

      filled: true,

      fillColor: Colors.grey.shade100,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: BorderSide.none,
      ),
    );
  }
}
