
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student_model.dart';
import '../services/student_service.dart';

class StudentProfileScreen extends StatefulWidget {
  final int studentId;

  const StudentProfileScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  StudentModel? student;

  bool isLoading = true;
  String? errorMessage;

  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  // ============================================================
  // LOAD STUDENT
  // ============================================================

  Future<void> _loadStudent() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final service = StudentService(token);

      final result = await service.getStudentById(widget.studentId);

      if (!mounted) return;

      setState(() {
        student = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load student profile.';
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

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
            Icons.arrow_back_rounded,
            color: textColor,
          ),
        ),

        title: Text(
          'Student Profile',
          style: GoogleFonts.poppins(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: _loadStudent,

            icon: const Icon(
              Icons.refresh_rounded,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 6),
        ],
      ),

      body: _buildBody(),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (student == null) {
      return _buildError();
    }

    return RefreshIndicator(
      onRefresh: _loadStudent,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(18, 18, 18, 35),

        child: Column(
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 18),

            _buildAcademicCard(),

            const SizedBox(height: 18),

            _buildPersonalInformation(),

            const SizedBox(height: 18),

            _buildContactInformation(),

            const SizedBox(height: 18),

            _buildAdmissionInformation(),

            const SizedBox(height: 18),

            _buildAddressCard(),

            const SizedBox(height: 18),

            _buildStatusCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final s = student!;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        borderRadius: BorderRadius.circular(26),

        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          // Avatar
          Container(
            width: 86,
            height: 86,

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,

              border: Border.all(
                color: Colors.white.withOpacity(0.55),
                width: 2,
              ),
            ),

            child: Center(
              child: Text(
                _getInitials(s.name),

                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Text(
            s.name.isEmpty ? 'Student' : s.name,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Roll No: ${_display(s.rollNumber)}',

            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,

            children: [
              _headerBadge(
                Icons.badge_outlined,
                'Admission ${_display(s.admissionNo)}',
              ),

              _headerBadge(
                Icons.verified_rounded,
                _display(s.status, fallback: 'Active'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerBadge(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),

          const SizedBox(width: 5),

          Text(
            text,

            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACADEMIC
  // ============================================================

  Widget _buildAcademicCard() {
    final s = student!;

    return _sectionCard(
      title: 'Academic Information',
      icon: Icons.school_rounded,

      children: [
        _infoRow(
          icon: Icons.format_list_numbered_rounded,
          label: 'Roll Number',
          value: _display(s.rollNumber),
        ),

        _divider(),

        _infoRow(
          icon: Icons.badge_outlined,
          label: 'Admission Number',
          value: _display(s.admissionNo),
        ),

        _divider(),

        _infoRow(
          icon: Icons.grid_view_rounded,
          label: 'Section ID',
          value: s.sectionId.toString(),
        ),

        _divider(),

        _infoRow(
          icon: Icons.calendar_month_rounded,
          label: 'Academic Year ID',
          value: s.academicYearId.toString(),
        ),
      ],
    );
  }

  // ============================================================
  // PERSONAL INFORMATION
  // ============================================================

  Widget _buildPersonalInformation() {
    final s = student!;

    return _sectionCard(
      title: 'Personal Information',
      icon: Icons.person_rounded,

      children: [
        _infoRow(
          icon: Icons.person_outline_rounded,
          label: 'Full Name',
          value: _display(s.name),
        ),

        _divider(),

        _infoRow(
          icon: Icons.cake_outlined,
          label: 'Date of Birth',
          value: _formatDate(s.dateOfBirth),
        ),

        _divider(),

        _infoRow(
          icon: Icons.wc_rounded,
          label: 'Gender',
          value: _display(s.gender),
        ),

        _divider(),

        _infoRow(
          icon: Icons.bloodtype_outlined,
          label: 'Blood Group',
          value: _display(s.bloodGroup),
        ),
      ],
    );
  }

  // ============================================================
  // CONTACT
  // ============================================================

  Widget _buildContactInformation() {
    final s = student!;

    return _sectionCard(
      title: 'Contact Information',
      icon: Icons.contact_phone_rounded,

      children: [
        _infoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: _display(s.phone),
        ),

        _divider(),

        _infoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: _display(s.email),
        ),
      ],
    );
  }

  // ============================================================
  // ADMISSION
  // ============================================================

  Widget _buildAdmissionInformation() {
    final s = student!;

    return _sectionCard(
      title: 'Admission Information',
      icon: Icons.assignment_rounded,

      children: [
        _infoRow(
          icon: Icons.event_available_rounded,
          label: 'Admission Date',
          value: _formatDate(s.admissionDate),
        ),

        _divider(),

        _infoRow(
          icon: Icons.family_restroom_rounded,
          label: 'Parent ID',
          value: s.parentId.toString(),
        ),
      ],
    );
  }

  // ============================================================
  // ADDRESS
  // ============================================================

  Widget _buildAddressCard() {
    final s = student!;

    return _sectionCard(
      title: 'Address',
      icon: Icons.location_on_rounded,

      children: [
        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: const Color(0xffF7F9FC),
            borderRadius: BorderRadius.circular(15),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Icon(
                Icons.location_on_outlined,
                color: primaryColor,
                size: 21,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  _display(
                    s.address,
                    fallback: 'Address not available',
                  ),

                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusCard() {
    final s = student!;

    final status = s.status.trim().isEmpty
        ? 'Active'
        : s.status;

    final isActive = status.toLowerCase() == 'active';

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xffE5EAF1),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xffE8F5E9)
                  : const Color(0xffffebee),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(
              isActive
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,

              color: isActive
                  ? Colors.green
                  : Colors.redAccent,

              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Student Status',

                  style: GoogleFonts.poppins(
                    color: const Color(0xff7A8697),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  status,

                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xffE8F5E9)
                  : const Color(0xffffebee),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              isActive ? 'Active' : status,

              style: GoogleFonts.poppins(
                color: isActive
                    ? Colors.green.shade700
                    : Colors.redAccent,

                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),

        border: Border.all(
          color: const Color(0xffE6EBF2),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration: BoxDecoration(
                  color: const Color(0xffEAF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 11),

              Text(
                title,

                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: const Color(0xffF5F8FC),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: const Color(0xff60758E),
            size: 19,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                label,

                style: GoogleFonts.poppins(
                  color: const Color(0xff8A94A3),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,

                maxLines: 2,
                overflow: TextOverflow.ellipsis,

                style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Divider(
        height: 1,
        thickness: 0.8,
        color: const Color(0xffEDF0F4),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 76,
              height: 76,

              decoration: BoxDecoration(
                color: const Color(0xffffebee),
                borderRadius: BorderRadius.circular(24),
              ),

              child: const Icon(
                Icons.person_off_outlined,
                color: Colors.redAccent,
                size: 38,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to load profile',

              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Please check your connection and try again.',

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: const Color(0xff7A8697),
                fontSize: 12.5,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadStudent,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('Try Again'),

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _display(
    String value, {
    String fallback = 'Not available',
  }) {
    if (value.trim().isEmpty) {
      return fallback;
    }

    return value;
  }

  String _formatDate(String value) {
    if (value.trim().isEmpty) {
      return 'Not available';
    }

    try {
      final date = DateTime.parse(value);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value;
    }
  }

  String _getInitials(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return 'S';
    }

    final parts = trimmed.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

