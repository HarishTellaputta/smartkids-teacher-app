import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentListScreen extends StatefulWidget {
  final String className;
  final String subject;
  final String students;

  const StudentListScreen({
    super.key,
    required this.className,    
    required this.subject,
    required this.students,     
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  final List<Map<String, String>> students = [
    {
      "name": "Rahul Kumar",
      "roll": "01",
      "father": "Ramesh Kumar",
      "phone": "9876543210",
    },

    {
      "name": "Anjali Sharma",
      "roll": "02",
      "father": "Suresh Sharma",
      "phone": "9876543211",
    },

    {
      "name": "Vikram Reddy",
      "roll": "03",
      "father": "Ravi Reddy",
      "phone": "9876543212",
    },

    {
      "name": "Sneha Patel",
      "roll": "04",
      "father": "Mahesh Patel",
      "phone": "9876543213",
    },

    {
      "name": "Arjun Kumar",
      "roll": "05",
      "father": "Kiran Kumar",
      "phone": "9876543214",
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredStudents = students.where((student) {
      return student["name"]!.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xff1565C0),

        centerTitle: true,

        title: Text(
          "Students",

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
            // CLASS HEADER
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                ),

                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.className,

                    style: GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "${widget.subject} • ${widget.students} Students",

                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SEARCH BOX
            TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },

              decoration: InputDecoration(
                hintText: "Search student...",

                prefixIcon: const Icon(Icons.search, color: Color(0xff1565C0)),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: filteredStudents.length,

                itemBuilder: (context, index) {
                  var student = filteredStudents[index];

                  return _studentCard(context, student);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentCard(BuildContext context, Map<String, String> student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),

      child: Row(
        children: [
          CircleAvatar(
            radius: 28,

            backgroundColor: const Color(0xffE3F2FD),

            child: Text(
              student["roll"]!,

              style: GoogleFonts.poppins(
                color: const Color(0xff1565C0),

                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  student["name"]!,

                  style: GoogleFonts.poppins(
                    fontSize: 17,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  "Parent: ${student["father"]}",

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),

                Text(
                  "Mobile: ${student["phone"]}",

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios,

              size: 18,

              color: Color(0xff1565C0),
            ),

            onPressed: () {
              showModalBottomSheet(
                context: context,

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),

                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(25),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        const CircleAvatar(
                          radius: 35,

                          child: Icon(Icons.person, size: 40),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          student["name"]!,

                          style: GoogleFonts.poppins(
                            fontSize: 22,

                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Text(
                          "Roll No: ${student["roll"]}",

                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          "Attendance: 95%",

                          style: GoogleFonts.poppins(
                            color: Colors.green,

                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
