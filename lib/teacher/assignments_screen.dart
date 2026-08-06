import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final List<Map<String, String>> assignments = [
    {
      "title": "Chapter 5 Exercise",
      "subject": "Mathematics",
      "class": "Class 6 - A",
      "due": "08 Aug 2026",
      "submitted": "35/42",
    },

    {
      "title": "Algebra Practice",
      "subject": "Mathematics",
      "class": "Class 7 - B",
      "due": "10 Aug 2026",
      "submitted": "28/38",
    },

    {
      "title": "Geometry Worksheet",
      "subject": "Mathematics",
      "class": "Class 8 - A",
      "due": "12 Aug 2026",
      "submitted": "40/45",
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
          "Assignments",

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
              "My Assignments",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: assignments.length,

                itemBuilder: (context, index) {
                  return _assignmentCard(assignments[index]);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff1565C0),

        onPressed: () {
          _showCreateAssignment(context);
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: Text(
          "New Assignment",

          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _assignmentCard(Map<String, String> item) {
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
                height: 50,

                width: 50,

                decoration: const BoxDecoration(
                  color: Color(0xffE3F2FD),

                  shape: BoxShape.circle,
                ),

                child: const Icon(Icons.assignment, color: Color(0xff1565C0)),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  item["title"]!,

                  style: GoogleFonts.poppins(
                    fontSize: 17,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,

                  vertical: 5,
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

          const SizedBox(height: 18),

          _detailRow(Icons.school, item["class"]!),

          _detailRow(Icons.menu_book, item["subject"]!),

          _detailRow(Icons.calendar_month, "Due Date: ${item["due"]}"),

          _detailRow(Icons.people, "Submitted: ${item["submitted"]}"),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
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

  void _showCreateAssignment(BuildContext context) {
    TextEditingController controller = TextEditingController();

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
                "Create Assignment",

                style: GoogleFonts.poppins(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: controller,

                decoration: InputDecoration(
                  hintText: "Assignment title",

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
                    if (controller.text.isNotEmpty) {
                      setState(() {
                        assignments.add({
                          "title": controller.text,

                          "subject": "Mathematics",

                          "class": "Class 6 - A",

                          "due": "15 Aug 2026",

                          "submitted": "0/42",
                        });
                      });

                      Navigator.pop(context);
                    }
                  },

                  child: Text(
                    "Publish",

                    style: GoogleFonts.poppins(color: Colors.white),
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
