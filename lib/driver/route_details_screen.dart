import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RouteDetailsScreen extends StatelessWidget {
  const RouteDetailsScreen({super.key});

  final List<Map<String, String>> stops = const [
    {
      "stop": "Benz Circle",
      "time": "07:15 AM",
      "students": "8 Students",
      "status": "Completed",
    },

    {
      "stop": "Ramavarappadu",
      "time": "07:30 AM",
      "students": "6 Students",
      "status": "Completed",
    },

    {
      "stop": "Auto Nagar",
      "time": "07:45 AM",
      "students": "10 Students",
      "status": "Upcoming",
    },

    {
      "stop": "Gunadala",
      "time": "08:00 AM",
      "students": "8 Students",
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
          "Route Details",

          style: GoogleFonts.poppins(
            color: Colors.white,

            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ROUTE HEADER
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                ),

                borderRadius: BorderRadius.circular(25),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Morning School Route",

                    style: GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Driver: Ramesh Kumar",

                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),

                  Text(
                    "Vehicle: AP 16 AB 4567",

                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Route Summary",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(child: _summaryCard(Icons.people, "32", "Students")),

                const SizedBox(width: 12),

                Expanded(child: _summaryCard(Icons.location_on, "4", "Stops")),

                const SizedBox(width: 12),

                Expanded(child: _summaryCard(Icons.timer, "45", "Minutes")),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              "Pickup Stops",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: stops.length,

              itemBuilder: (context, index) {
                return _stopCard(stops[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(IconData icon, String value, String title) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        children: [
          Icon(icon, color: const Color(0xff1565C0)),

          const SizedBox(height: 8),

          Text(
            value,

            style: GoogleFonts.poppins(
              fontSize: 20,

              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,

            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _stopCard(Map<String, String> stop, int index) {
    bool completed = stop["status"] == "Completed";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 22,

                backgroundColor: completed
                    ? Colors.green.shade100
                    : Colors.orange.shade100,

                child: Icon(
                  completed ? Icons.check : Icons.location_on,

                  color: completed ? Colors.green : Colors.orange,
                ),
              ),

              if (index != stops.length - 1)
                Container(height: 35, width: 2, color: Colors.grey.shade300),
            ],
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  stop["stop"]!,

                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,

                    fontSize: 16,
                  ),
                ),

                Text(
                  stop["time"]!,

                  style: GoogleFonts.poppins(color: Colors.grey),
                ),

                Text(
                  stop["students"]!,

                  style: GoogleFonts.poppins(color: const Color(0xff1565C0)),
                ),
              ],
            ),
          ),

          Text(
            stop["status"]!,

            style: GoogleFonts.poppins(
              color: completed ? Colors.green : Colors.orange,

              fontWeight: FontWeight.w600,

              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
