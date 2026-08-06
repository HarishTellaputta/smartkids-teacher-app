import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StartDutyScreen extends StatefulWidget {
  const StartDutyScreen({super.key});

  @override
  State<StartDutyScreen> createState() => _StartDutyScreenState();
}

class _StartDutyScreenState extends State<StartDutyScreen> {
  bool dutyStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Start Duty",

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
            // DRIVER CARD
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1565C0), Color(0xff42A5F5)],
                ),

                borderRadius: BorderRadius.circular(25),
              ),

              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,

                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.directions_bus,

                      size: 55,

                      color: Color(0xff1565C0),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Ramesh Kumar",

                    style: GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "School Bus Driver",

                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _infoCard(Icons.directions_car, "Vehicle Number", "AP 16 AB 4567"),

            _infoCard(Icons.route, "Today's Route", "Vijayawada - Benz Circle"),

            _infoCard(Icons.people, "Students Pickup", "32 Students"),

            _infoCard(Icons.access_time, "Duty Time", "07:00 AM - 04:00 PM"),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  Icon(
                    dutyStarted ? Icons.check_circle : Icons.play_circle_fill,

                    size: 80,

                    color: dutyStarted ? Colors.green : const Color(0xff1565C0),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    dutyStarted ? "Duty Started" : "Ready To Start Duty",

                    style: GoogleFonts.poppins(
                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,

                    height: 55,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dutyStarted
                            ? Colors.red
                            : const Color(0xff1565C0),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      onPressed: () {
                        setState(() {
                          dutyStarted = !dutyStarted;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              dutyStarted
                                  ? "Duty Started Successfully"
                                  : "Duty Ended",
                            ),
                          ),
                        );
                      },

                      child: Text(
                        dutyStarted ? "End Duty" : "Start Duty",

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
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [
          Container(
            height: 50,

            width: 50,

            decoration: const BoxDecoration(
              color: Color(0xffE3F2FD),

              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: Color(0xff1565C0)),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
              ),

              Text(
                value,

                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
