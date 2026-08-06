import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Driver Profile",

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
            // PROFILE HEADER
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
                    radius: 50,

                    backgroundColor: Colors.white,

                    child: Icon(
                      Icons.person,

                      size: 65,

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

                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,

                      vertical: 7,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white24,

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      "Employee ID : DRV1025",

                      style: GoogleFonts.poppins(
                        color: Colors.white,

                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _sectionTitle("Personal Details"),

            _profileCard(Icons.phone, "Mobile Number", "+91 9876543210"),

            _profileCard(Icons.email, "Email", "ramesh@smartkids.com"),

            _profileCard(
              Icons.location_on,

              "Address",

              "Vijayawada, Andhra Pradesh",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Driver Information"),

            _profileCard(Icons.badge, "Driving License", "AP162026789"),

            _profileCard(Icons.work, "Experience", "8 Years Experience"),

            _profileCard(Icons.calendar_month, "Joining Date", "15 June 2018"),

            const SizedBox(height: 20),

            _sectionTitle("Vehicle Details"),

            _profileCard(
              Icons.directions_bus,

              "Vehicle Number",

              "AP 16 AB 4567",
            ),

            _profileCard(
              Icons.confirmation_number,

              "Vehicle Type",

              "School Bus",
            ),

            _profileCard(Icons.people, "Capacity", "45 Students"),

            const SizedBox(height: 25),

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

                onPressed: () {},

                child: Text(
                  "Edit Profile",

                  style: GoogleFonts.poppins(
                    color: Colors.white,

                    fontSize: 17,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [
                  _menuItem(Icons.settings, "Settings"),

                  _menuItem(Icons.support_agent, "Help & Support"),

                  _menuItem(Icons.logout, "Logout", logout: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),

        child: Text(
          title,

          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _profileCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          Container(
            height: 45,

            width: 45,

            decoration: const BoxDecoration(
              color: Color(0xffE3F2FD),

              shape: BoxShape.circle,
            ),

            child: Icon(icon, color: Color(0xff1565C0)),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {bool logout = false}) {
    return ListTile(
      leading: Icon(icon, color: logout ? Colors.red : const Color(0xff1565C0)),

      title: Text(
        title,

        style: GoogleFonts.poppins(
          color: logout ? Colors.red : Colors.black87,

          fontWeight: FontWeight.w500,
        ),
      ),

      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}
