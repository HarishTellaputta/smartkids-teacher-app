import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveTripScreen extends StatefulWidget {
  const LiveTripScreen({super.key});

  @override
  State<LiveTripScreen> createState() => _LiveTripScreenState();
}

class _LiveTripScreenState extends State<LiveTripScreen> {
  final List<Map<String, dynamic>> students = [
    {"name": "Rahul Kumar", "stop": "Benz Circle", "picked": true},

    {"name": "Anjali Sharma", "stop": "Ramavarappadu", "picked": true},

    {"name": "Vikram Reddy", "stop": "Auto Nagar", "picked": false},

    {"name": "Sneha Patel", "stop": "Gunadala", "picked": false},

    {"name": "Arjun Kumar", "stop": "Patamata", "picked": false},
  ];

  @override
  Widget build(BuildContext context) {
    int completed = students.where((e) => e["picked"]).length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Live Trip",

          style: GoogleFonts.poppins(
            color: Colors.white,

            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // LIVE MAP PLACEHOLDER
            Container(
              height: 220,

              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xffDDEEFF),

                borderRadius: BorderRadius.circular(25),
              ),

              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.map, size: 90, color: Color(0xff1565C0)),
                  ),

                  Positioned(
                    top: 15,

                    right: 15,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,

                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.green,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        "LIVE",

                        style: GoogleFonts.poppins(
                          color: Colors.white,

                          fontWeight: FontWeight.bold,

                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TRIP STATUS
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Pickup Progress",

                        style: GoogleFonts.poppins(
                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "$completed/${students.length}",

                        style: GoogleFonts.poppins(
                          color: const Color(0xff1565C0),

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  LinearProgressIndicator(
                    value: completed / students.length,

                    minHeight: 10,

                    borderRadius: BorderRadius.circular(10),

                    backgroundColor: Colors.grey.shade200,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                "Student Pickup List",

                style: GoogleFonts.poppins(
                  fontSize: 22,

                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: students.length,

              itemBuilder: (context, index) {
                return _studentCard(index);
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                icon: const Icon(Icons.warning, color: Colors.white),

                label: Text(
                  "Emergency Alert",

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontSize: 17,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Emergency Alert Sent")),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _studentCard(int index) {
    var student = students[index];

    bool picked = student["picked"];

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
            backgroundColor: picked
                ? Colors.green.shade100
                : Colors.orange.shade100,

            child: Icon(
              picked ? Icons.check : Icons.person,

              color: picked ? Colors.green : Colors.orange,
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
                  student["stop"],

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: picked ? Colors.green : const Color(0xff1565C0),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            onPressed: () {
              setState(() {
                student["picked"] = !student["picked"];
              });
            },

            child: Text(
              picked ? "Picked" : "Pickup",

              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
