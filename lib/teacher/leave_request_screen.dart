import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  final List<LeaveRequest> leaveRequests = [
    LeaveRequest(
      studentName: "Rahul Kumar",
      className: "Class 6-A",
      parentName: "Ramesh Kumar",
      reason: "Fever",
      fromDate: "10 Aug 2026",
      toDate: "10 Aug 2026",
      appliedDate: "09 Aug 2026",
      status: "Pending",
    ),
    LeaveRequest(
      studentName: "Sneha Patel",
      className: "Class 7-B",
      parentName: "Mahesh Patel",
      reason: "Family Function",
      fromDate: "12 Aug 2026",
      toDate: "13 Aug 2026",
      appliedDate: "10 Aug 2026",
      status: "Pending",
    ),
    LeaveRequest(
      studentName: "Arjun Kumar",
      className: "Class 8-A",
      parentName: "Kiran Kumar",
      reason: "Medical Checkup",
      fromDate: "08 Aug 2026",
      toDate: "08 Aug 2026",
      appliedDate: "07 Aug 2026",
      status: "Approved",
    ),
    LeaveRequest(
      studentName: "Anjali Sharma",
      className: "Class 6-A",
      parentName: "Suresh Sharma",
      reason: "Travel",
      fromDate: "05 Aug 2026",
      toDate: "06 Aug 2026",
      appliedDate: "04 Aug 2026",
      status: "Rejected",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  int get pendingCount =>
      leaveRequests.where((e) => e.status == "Pending").length;

  int get approvedCount =>
      leaveRequests.where((e) => e.status == "Approved").length;

  int get rejectedCount =>
      leaveRequests.where((e) => e.status == "Rejected").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),

      appBar: AppBar(
        backgroundColor: const Color(0xff1565C0),
        centerTitle: true,
        title: Text(
          "Leave Management",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search Student",

                prefixIcon: const Icon(Icons.search),

                filled: true,

                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    "Pending",
                    pendingCount.toString(),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    "Approved",
                    approvedCount.toString(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    "Rejected",
                    rejectedCount.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [Container(), Container(), Container()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),

      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(.12),

            child: Text(
              count,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class LeaveRequest {
  String studentName;
  String className;
  String parentName;
  String reason;
  String fromDate;
  String toDate;
  String appliedDate;
  String status;

  LeaveRequest({
    required this.studentName,
    required this.className,
    required this.parentName,
    required this.reason,
    required this.fromDate,
    required this.toDate,
    required this.appliedDate,
    required this.status,
  });
  Widget _buildLeaveCard({
    required String studentName,
    required String className,
    required String reason,
    required String fromDate,
    required String toDate,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xffE3F2FD),
                  child: Icon(Icons.person, color: Color(0xff1565C0)),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      Text(
                        className,
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.blue),
                const SizedBox(width: 8),
                Text("$fromDate  →  $toDate", style: GoogleFonts.poppins()),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(child: Text(reason, style: GoogleFonts.poppins())),
              ],
            ),

            if (status == "Pending") ...[
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.check),
                      label: const Text("Approve"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.close),
                      label: const Text("Reject"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
