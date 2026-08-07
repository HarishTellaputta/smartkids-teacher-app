import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Teacher Dashboard",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _teacherCard(),

            const SizedBox(height: 20),

            _summaryGrid(),

            const SizedBox(height: 25),

            _todaySchedule(),

            const SizedBox(height: 25),

            _quickActions(),

            const SizedBox(height: 25),

            _recentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _teacherCard() {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff1565C0), Color(0xff42A5F5)],
        ),

        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,

            backgroundColor: Colors.white,

            child: Icon(Icons.person, size: 40, color: Color(0xff1565C0)),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  "Good Morning 👋",

                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                Text(
                  "Mrs. Anitha Sharma",

                  style: GoogleFonts.poppins(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),

                Text(
                  "Mathematics Teacher",

                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid() {
    return GridView.count(
      crossAxisCount: 2,

      physics: const NeverScrollableScrollPhysics(),

      shrinkWrap: true,

      mainAxisSpacing: 15,

      crossAxisSpacing: 15,

      childAspectRatio: 1.35,

      children: [
        _summaryCard(Icons.class_, "Today's Classes", "5", Colors.blue),

        _summaryCard(Icons.people, "Students", "165", Colors.green),

        _summaryCard(Icons.assignment, "Homework", "8", Colors.orange),

        _summaryCard(Icons.event_busy, "Leave", "2", Colors.red),
      ],
    );
  }

  Widget _summaryCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.1),

            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,

              fontSize: 22,
            ),
          ),

          Text(
            title,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _todaySchedule() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          "Today's Schedule",

          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        _scheduleTile("09:00 AM", "Class 6 - A", "Mathematics"),

        _scheduleTile("10:00 AM", "Class 7 - B", "Algebra"),

        _scheduleTile("11:00 AM", "Class 8 - A", "Geometry"),
      ],
    );
  }

  Widget _scheduleTile(String time, String className, String subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xffE3F2FD),

          child: Text(
            time.substring(0, 2),
            style: const TextStyle(
              color: Color(0xff1565C0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          subject,

          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(className),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _quickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          "Quick Actions",

          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        Wrap(
          spacing: 12,

          runSpacing: 12,

          children: [
            _actionButton(Icons.assignment, "Homework"),

            _actionButton(Icons.fact_check, "Attendance"),

            _actionButton(Icons.grade, "Marks"),

            _actionButton(Icons.chat, "Parents"),

            _actionButton(Icons.campaign, "Notice"),

            _actionButton(Icons.menu_book, "Materials"),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String title) {
    return Container(
      width: 105,

      padding: const EdgeInsets.symmetric(vertical: 18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),

      child: Column(
        children: [
          Icon(icon, size: 30, color: const Color(0xff1565C0)),

          const SizedBox(height: 8),

          Text(
            title,

            style: GoogleFonts.poppins(
              fontSize: 12,

              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text(
          "Recent Activity",

          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 15),

        _activityTile("Rahul submitted homework"),

        _activityTile("Parent sent a new message"),

        _activityTile("Principal published a circular"),

        _activityTile("Marks uploaded successfully"),
      ],
    );
  }

  Widget _activityTile(String text) {
    return ListTile(
      contentPadding: EdgeInsets.zero,

      leading: const CircleAvatar(
        radius: 15,

        backgroundColor: Color(0xffE8F5E9),

        child: Icon(Icons.check, size: 18, color: Colors.green),
      ),

      title: Text(text, style: GoogleFonts.poppins()),
    );
  }
}
