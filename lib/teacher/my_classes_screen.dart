import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyClassesScreen extends StatelessWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xff1565C0),

        title: Text(
          "My Classes",

          style: GoogleFonts.poppins(
            color: Colors.white,

            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Assigned Classes",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _classCard(
              context,

              "Class 6 - A",

              "Mathematics",

              "42 Students",

              "09:00 AM - 09:45 AM",

              Icons.calculate,
            ),

            _classCard(
              context,

              "Class 7 - B",

              "Mathematics",

              "38 Students",

              "10:00 AM - 10:45 AM",

              Icons.functions,
            ),

            _classCard(
              context,

              "Class 8 - A",

              "Mathematics",

              "45 Students",

              "11:00 AM - 11:45 AM",

              Icons.school,
            ),

            _classCard(
              context,

              "Class 9 - B",

              "Algebra",

              "40 Students",

              "02:00 PM - 02:45 PM",

              Icons.menu_book,
            ),
          ],
        ),
      ),
    );
  }

  Widget _classCard(
    BuildContext context,

    String className,

    String subject,

    String students,

    String time,

    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black12,

            blurRadius: 8,

            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
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

                child: Icon(icon, color: Color(0xff1565C0), size: 30),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      className,

                      style: GoogleFonts.poppins(
                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      subject,

                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,

                  vertical: 6,
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

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _infoTile(Icons.people, students)),

              Expanded(child: _infoTile(Icons.access_time, time)),
            ],
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,

            height: 45,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1565C0),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),

              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Opening $className Students",

                      style: GoogleFonts.poppins(),
                    ),
                  ),
                );
              },

              child: Text(
                "View Students",

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
  }

  Widget _infoTile(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xff1565C0)),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,

            style: GoogleFonts.poppins(
              fontSize: 12,

              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}
