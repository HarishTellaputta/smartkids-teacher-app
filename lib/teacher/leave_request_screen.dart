import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String selectedLeaveType = "Casual Leave";

  final TextEditingController reasonController = TextEditingController();

  final List<Map<String, String>> leaveHistory = [
    {"type": "Medical Leave", "date": "15 Jul 2026", "status": "Approved"},

    {"type": "Casual Leave", "date": "20 Jun 2026", "status": "Rejected"},
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
          "Leave Request",

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
            // APPLY LEAVE CARD
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Apply New Leave",

                    style: GoogleFonts.poppins(
                      fontSize: 22,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Leave Type",

                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedLeaveType,

                    decoration: _inputDecoration(),

                    items:
                        [
                          "Casual Leave",

                          "Medical Leave",

                          "Emergency Leave",

                          "Personal Leave",
                        ].map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedLeaveType = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "From Date",

                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  _dateBox("Select Start Date", Icons.calendar_today),

                  const SizedBox(height: 15),

                  Text(
                    "To Date",

                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  _dateBox("Select End Date", Icons.event),

                  const SizedBox(height: 20),

                  TextField(
                    controller: reasonController,

                    maxLines: 3,

                    decoration: _inputDecoration().copyWith(
                      hintText: "Reason for leave",
                    ),
                  ),

                  const SizedBox(height: 20),

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

                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Leave Request Submitted"),
                          ),
                        );
                      },

                      child: Text(
                        "Submit Request",

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

            const SizedBox(height: 25),

            Text(
              "Leave History",

              style: GoogleFonts.poppins(
                fontSize: 22,

                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            ListView.builder(
              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              itemCount: leaveHistory.length,

              itemBuilder: (context, index) {
                var leave = leaveHistory[index];

                return _leaveCard(leave);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBox(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          Icon(icon, color: const Color(0xff1565C0)),

          const SizedBox(width: 12),

          Text(text, style: GoogleFonts.poppins(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _leaveCard(Map<String, String> leave) {
    bool approved = leave["status"] == "Approved";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(18),

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

            child: const Icon(Icons.event_note, color: Color(0xff1565C0)),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  leave["type"]!,

                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),

                Text(
                  leave["date"]!,

                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          Text(
            leave["status"]!,

            style: GoogleFonts.poppins(
              color: approved ? Colors.green : Colors.red,

              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,

      fillColor: Colors.grey.shade100,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),

        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    reasonController.dispose();

    super.dispose();
  }
}
