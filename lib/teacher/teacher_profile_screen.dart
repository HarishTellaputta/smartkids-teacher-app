import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),

        elevation: 0,

        centerTitle: true,

        title: Text(
          "Teacher Profile",

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
                    "Mrs. Anitha Sharma",

                    style: GoogleFonts.poppins(
                      color: Colors.white,

                      fontSize: 24,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Mathematics Teacher",

                    style: GoogleFonts.poppins(
                      color: Colors.white70,

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 15),

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
                      "Employee ID : TCH1024",

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

            _sectionTitle("Personal Information"),

            _profileCard(Icons.phone, "Mobile Number", "+91 9876543210"),

            _profileCard(Icons.email, "Email", "anitha@smartkids.com"),

            _profileCard(
              Icons.location_on,

              "Address",

              "Vijayawada, Andhra Pradesh",
            ),

            const SizedBox(height: 20),

            _sectionTitle("Professional Details"),

            _profileCard(
              Icons.school,

              "Qualification",

              "M.Sc Mathematics, B.Ed",
            ),

            _profileCard(
              Icons.work,

              "Experience",

              "6 Years Teaching Experience",
            ),

            _profileCard(Icons.menu_book, "Subjects", "Mathematics, Algebra"),

            _profileCard(Icons.class_, "Classes", "6-A, 7-B, 8-A, 9-B"),

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

                  _menuItem(Icons.help_outline, "Help & Support"),

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
