import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BirthdayStatusScreen extends StatefulWidget {
  const BirthdayStatusScreen({super.key});

  @override
  State<BirthdayStatusScreen> createState() => _BirthdayStatusScreenState();
}

class _BirthdayStatusScreenState extends State<BirthdayStatusScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color backgroundColor = Color(0xffF5F8FC);

  bool isLoading = false;

  // Dummy data for now.
  // Later this will come from:
  // GET /api/v1/student-birthday-status/today
  final List<Map<String, dynamic>> birthdays = [
    {
      'name': 'Rahul Kumar',
      'class': 'Class 5',
      'section': 'A',
      'age': 10,
      'initials': 'RK',
    },
    {
      'name': 'Ananya Reddy',
      'class': 'Class 7',
      'section': 'B',
      'age': 12,
      'initials': 'AR',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xff172033),
            size: 20,
          ),
        ),
        title: Text(
          'Birthday Status',
          style: GoogleFonts.poppins(
            color: const Color(0xff172033),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _refreshBirthdayStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBirthdayHeader(),

              const SizedBox(height: 22),

              _buildQuickStatus(),

              const SizedBox(height: 26),

              _buildSectionHeader(),

              const SizedBox(height: 14),

              if (isLoading)
                _buildLoadingState()
              else if (birthdays.isEmpty)
                _buildEmptyState()
              else
                ...birthdays.map(
                  (birthday) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildBirthdayCard(birthday),
                  ),
                ),

              const SizedBox(height: 12),

              _buildChatBanner(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // HEADER
  // =========================================================

  Widget _buildBirthdayHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xff1565C0),
            Color(0xff42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -15,
            child: Container(
              width: 95,
              height: 95,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 25,
            bottom: -35,
            child: Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '🎂',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today’s Birthdays',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      birthdays.isEmpty
                          ? 'No birthdays today'
                          : '${birthdays.length} students celebrating today',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================
  // QUICK STATUS
  // =========================================================

  Widget _buildQuickStatus() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            icon: Icons.cake_rounded,
            title: '${birthdays.length}',
            subtitle: 'Birthdays',
            iconBackground: const Color(0xffFFF1E8),
            iconColor: const Color(0xffF97316),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatusCard(
            icon: Icons.chat_bubble_rounded,
            title: 'Chat',
            subtitle: 'Birthday Chat',
            iconBackground: const Color(0xffE8F1FF),
            iconColor: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconBackground,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xff172033),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // SECTION HEADER
  // =========================================================

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Celebrations Today',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xff172033),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Wish your students a happy birthday',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: const Color(0xffE8F1FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${birthdays.length} Today',
            style: GoogleFonts.poppins(
              color: primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BIRTHDAY CARD
  // =========================================================

  Widget _buildBirthdayCard(Map<String, dynamic> birthday) {
    final String name = birthday['name'] ?? '';
    final String className = birthday['class'] ?? '';
    final String section = birthday['section'] ?? '';
    final int age = birthday['age'] ?? 0;
    final String initials = birthday['initials'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xffE3F2FD),
                      Color(0xffBBDEFB),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xff172033),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$className • Section $section',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF4E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text(
                      '🎂',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$age',
                      style: GoogleFonts.poppins(
                        color: const Color(0xffF97316),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            height: 1,
            color: const Color(0xffEEF1F5),
          ),

          const SizedBox(height: 13),

          SizedBox(
            width: double.infinity,
            height: 43,
            child: OutlinedButton.icon(
              onPressed: () {
                _showBirthdayWish(name);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: Color(0xffD6E5F8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(
                Icons.celebration_rounded,
                size: 18,
              ),
              label: Text(
                'Send Birthday Wish',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // CHAT BANNER
  // =========================================================

  Widget _buildChatBanner() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: _openBirthdayChat,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xff172033),
              Color(0xff26364F),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Birthday Chat',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Join the birthday conversations',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 38,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xffE8EDF4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                '🎈',
                style: TextStyle(fontSize: 34),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Birthdays Today',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xff172033),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'There are no student birthdays today.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // LOADING
  // =========================================================

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      ),
    );
  }

  // =========================================================
  // ACTIONS
  // =========================================================

  Future<void> _refreshBirthdayStatus() async {
    setState(() {
      isLoading = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 700),
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showBirthdayWish(String studentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xff172033),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          'Birthday wish for $studentName will be sent through chat.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _openBirthdayChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        content: Text(
          'Birthday Chat screen will open here.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}