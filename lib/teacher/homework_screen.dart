import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final List<Map<String, String>> homeworkList = [
    {
      "class": "Class 6 - A",
      "subject": "Mathematics",
      "title": "Solve Chapter 5 Problems",
      "date": "Due: 08 Aug 2026",
    },

    {
      "class": "Class 7 - B",
      "subject": "Mathematics",
      "title": "Complete Algebra Exercise",
      "date": "Due: 10 Aug 2026",
    },

    {
      "class": "Class 8 - A",
      "subject": "Mathematics",
      "title": "Geometry Worksheet",
      "date": "Due: 12 Aug 2026",
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
          "Homework",

          style: GoogleFonts.poppins(
            color: Colors.white,

            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),

            onPressed: () {
              _showAddHomework(context);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Assigned Homework",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount: homeworkList.length,

                itemBuilder: (context, index) {
                  var homework = homeworkList[index];

                  return _homeworkCard(homework);
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xff1565C0),

        onPressed: () {
          _showAddHomework(context);
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: Text(
          "Add Homework",

          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _homeworkCard(Map<String, String> homework) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      homework["title"]!,

                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    Text(
                      homework["subject"]!,

                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                homework["class"]!,

                style: GoogleFonts.poppins(
                  color: const Color(0xff1565C0),

                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                homework["date"]!,

                style: GoogleFonts.poppins(
                  color: Colors.redAccent,

                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddHomework(BuildContext context) {
    final titleController = TextEditingController();

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

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                "Create Homework",

                style: GoogleFonts.poppins(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: titleController,

                decoration: InputDecoration(
                  hintText: "Homework Title",

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
                        homeworkList.add({
                          "class": "Class 6 - A",

                          "subject": "Mathematics",

                          "title": titleController.text,

                          "date": "Due: 15 Aug 2026",
                        });
                      });

                      Navigator.pop(context);
                    }
                  },

                  child: Text(
                    "Publish Homework",

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
