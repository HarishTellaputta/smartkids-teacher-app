import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final List<Map<String, String>> exams = [
    {
      "title": "Unit Test - 1",
      "subject": "Mathematics",
      "class": "Class 6 - A",
      "date": "10 Aug 2026",
      "marks": "50 Marks",
      "status": "Upcoming",
    },

    {
      "title": "Quarterly Examination",
      "subject": "Mathematics",
      "class": "Class 7 - B",
      "date": "25 Aug 2026",
      "marks": "100 Marks",
      "status": "Scheduled",
    },

    {
      "title": "Chapter Test",
      "subject": "Algebra",
      "class": "Class 8 - A",
      "date": "15 Aug 2026",
      "marks": "40 Marks",
      "status": "Upcoming",
    },
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
          "Exams",

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
              "Exam Schedule",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: exams.length,

                itemBuilder: (context, index) {
                  return _examCard(exams[index]);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff1565C0),

        onPressed: () {
          _createExam(context);
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: Text(
          "Create Exam",

          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _examCard(Map<String, String> exam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

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
                  Icons.assignment_turned_in,

                  color: Color(0xff1565C0),

                  size: 28,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      exam["title"]!,

                      style: GoogleFonts.poppins(
                        fontSize: 17,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      exam["subject"]!,

                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,

                  vertical: 5,
                ),

                decoration: BoxDecoration(
                  color: Colors.orange.shade50,

                  borderRadius: BorderRadius.circular(12),
                ),

                child: Text(
                  exam["status"]!,

                  style: GoogleFonts.poppins(
                    color: Colors.orange,

                    fontSize: 12,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _row(Icons.school, exam["class"]!),

          _row(Icons.calendar_month, exam["date"]!),

          _row(Icons.grade, exam["marks"]!),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xff1565C0)),

          const SizedBox(width: 10),

          Text(
            text,

            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _createExam(BuildContext context) {
    TextEditingController titleController = TextEditingController();

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,

            right: 20,

            top: 25,

            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                "Create New Exam",

                style: GoogleFonts.poppins(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: titleController,

                decoration: InputDecoration(
                  hintText: "Exam Name",

                  filled: true,

                  fillColor: Colors.grey.shade100,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),

                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1565C0),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),

                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      setState(() {
                        exams.add({
                          "title": titleController.text,

                          "subject": "Mathematics",

                          "class": "Class 6 - A",

                          "date": "20 Aug 2026",

                          "marks": "50 Marks",

                          "status": "Upcoming",
                        });
                      });

                      Navigator.pop(context);
                    }
                  },

                  child: Text(
                    "Create Exam",

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
      },
    );
  }
}
