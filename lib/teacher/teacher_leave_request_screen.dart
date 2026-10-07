import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_storage.dart';
import '../models/teacher_leave_model.dart';
import '../services/teacher_leave_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() =>
      _LeaveRequestScreenState();
}

class _LeaveRequestScreenState
    extends State<LeaveRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  bool _isLoading = true;
  bool _isSubmitting = false;

  String? _errorMessage;

  List<TeacherLeaveModel> _leaveRequests = [];

  static const Color primaryColor = Color(0xff1565C0);
  static const Color primaryDark = Color(0xff0D47A1);
  static const Color backgroundColor = Color(0xffF5F8FC);

  static const List<String> _leaveTypes = [
    'Casual Leave',
    'Sick Leave',
    'Emergency Leave',
    'Personal Leave',
    'Medical Leave',
    'Earned Leave',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _searchController.addListener(() {
      if (!mounted) return;

      setState(() {
        _searchText =
            _searchController.text.trim().toLowerCase();
      });
    });

    _loadLeaves();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD LEAVES
  // ============================================================

  Future<void> _loadLeaves() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final token = await AuthStorage.getToken();
      final teacherId = await AuthStorage.getTeacherId();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login session expired. Please login again.',
        );
      }

      if (teacherId == null) {
        throw Exception(
          'Teacher ID not found. Please login again.',
        );
      }

      debugPrint(
        '========== LOAD TEACHER LEAVES ==========',
      );
      debugPrint('Teacher ID: $teacherId');

      final service = TeacherLeaveService(token);

      final leaves = await service.getMyLeaves(teacherId);

      leaves.sort(
        (a, b) => b.startDate.compareTo(a.startDate),
      );

      if (!mounted) return;

      setState(() {
        _leaveRequests = leaves;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('LOAD LEAVES ERROR: $e');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }

  // ============================================================
  // COUNTS
  // ============================================================

  int get pendingCount {
    return _leaveRequests.where(
      (leave) =>
          leave.status.toUpperCase() == 'PENDING',
    ).length;
  }

  int get approvedCount {
    return _leaveRequests.where(
      (leave) =>
          leave.status.toUpperCase() == 'APPROVED',
    ).length;
  }

  int get rejectedCount {
    return _leaveRequests.where(
      (leave) =>
          leave.status.toUpperCase() == 'REJECTED',
    ).length;
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<TeacherLeaveModel> _filteredLeaves(
    String status,
  ) {
    return _leaveRequests.where((leave) {
      final leaveStatus =
          leave.status.toUpperCase();

      if (leaveStatus != status) {
        return false;
      }

      if (_searchText.isEmpty) {
        return true;
      }

      final leaveType =
          leave.leaveType.toLowerCase();

      final reason =
          (leave.reason ?? '').toLowerCase();

      final rejectionReason =
          (leave.rejectionReason ?? '').toLowerCase();

      return leaveType.contains(_searchText) ||
          reason.contains(_searchText) ||
          rejectionReason.contains(_searchText);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildPremiumHeader(),
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================================
  // PREMIUM HEADER
  // ============================================================

  Widget _buildPremiumHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            primaryColor,
            Color(0xff1976D2),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              48,
              20,
              18,
            ),
            child: Row(
              children: [
                _headerIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Management',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your leave requests',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(
                            alpha: 0.78,
                          ),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                _headerIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: _isLoading
                      ? null
                      : _loadLeaves,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              0,
              18,
              20,
            ),
            child: _buildHeaderOverview(),
          ),

          _buildTabs(),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 44,
          width: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  '${_leaveRequests.length} Leave Requests',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pendingCount > 0
                      ? '$pendingCount request${pendingCount == 1 ? '' : 's'} waiting for approval'
                      : 'You are all caught up',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(
                      alpha: 0.76,
                    ),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  pendingCount.toString(),
                  style: GoogleFonts.poppins(
                    color: primaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Pending',
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade600,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 4,
        ),
        dividerColor: Colors.transparent,
        labelColor: primaryColor,
        unselectedLabelColor:
            Colors.white.withValues(alpha: 0.70),
        labelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          _tabItem(
            'Pending',
            pendingCount,
          ),
          _tabItem(
            'Approved',
            approvedCount,
          ),
          _tabItem(
            'Rejected',
            rejectedCount,
          ),
        ],
      ),
    );
  }

  Widget _tabItem(
    String title,
    int count,
  ) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(
                alpha: 0.06,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaveList('PENDING'),
              _buildLeaveList('APPROVED'),
              _buildLeaveList('REJECTED'),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText:
                'Search leave type or reason...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: primaryColor,
              size: 21,
            ),
            suffixIcon: _searchText.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LEAVE LIST
  // ============================================================

  Widget _buildLeaveList(
    String status,
  ) {
    final leaves = _filteredLeaves(status);

    if (leaves.isEmpty) {
      return RefreshIndicator(
        color: primaryColor,
        onRefresh: _loadLeaves,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            _buildEmptyState(status),
            const SizedBox(height: 120),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadLeaves,
      child: ListView.builder(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          18,
          4,
          18,
          110,
        ),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          return _buildLeaveCard(leaves[index]);
        },
      ),
    );
  }

  // ============================================================
  // LEAVE CARD
  // ============================================================

  Widget _buildLeaveCard(
    TeacherLeaveModel leave,
  ) {
    final status = leave.status.toUpperCase();

    final statusColor = _statusColor(status);

    final isPending = status == 'PENDING';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.045,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              14,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // TOP
                Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            statusColor.withValues(
                              alpha: 0.18,
                            ),
                            statusColor.withValues(
                              alpha: 0.07,
                            ),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _leaveTypeIcon(
                          leave.leaveType,
                        ),
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.leaveType,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style:
                                GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  const Color(0xff172033),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            leave.id > 0
                                ? 'Leave #${leave.id}'
                                : 'Leave Request',
                            style:
                                GoogleFonts.poppins(
                              fontSize: 9,
                              color:
                                  Colors.grey.shade500,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _statusBadge(
                      status,
                      statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // DATE SECTION
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xffF7F9FC),
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LEAVE PERIOD',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 8,
                                    letterSpacing: 0.7,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: Colors
                                        .grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _formatDateRange(
                                    leave.startDate,
                                    leave.endDate,
                                  ),
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.w700,
                                    color:
                                        const Color(
                                      0xff202838,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 9,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(
                                11,
                              ),
                              border: Border.all(
                                color:
                                    Colors.grey.shade200,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '${_calculateDays(leave.startDate, leave.endDate)}',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w800,
                                    color:
                                        primaryColor,
                                  ),
                                ),
                                Text(
                                  _calculateDays(
                                            leave.startDate,
                                            leave.endDate,
                                          ) ==
                                          1
                                      ? 'DAY'
                                      : 'DAYS',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 7,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: Colors
                                        .grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // REASON
                if (leave.reason != null &&
                    leave.reason!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 13),
                  _infoRow(
                    icon:
                        Icons.notes_rounded,
                    title: 'Reason',
                    value: leave.reason!,
                    color: Colors.orange,
                  ),
                ],

                // APPLIED
                const SizedBox(height: 13),
                _infoRow(
                  icon:
                      Icons.schedule_rounded,
                  title: 'Applied',
                  value: _formatDateTime(
                    leave.appliedAt ??
                        leave.createdAt,
                  ),
                  color: primaryColor,
                ),

                // APPROVED BY
                if (status == 'APPROVED' &&
                    leave.approvedBy != null) ...[
                  const SizedBox(height: 10),
                  _infoRow(
                    icon:
                        Icons.verified_rounded,
                    title: 'Approved by',
                    value: leave.approvedBy!,
                    color: Colors.green,
                  ),
                ],

                // APPROVED AT
                if (status == 'APPROVED' &&
                    leave.approvedAt != null) ...[
                  const SizedBox(height: 10),
                  _infoRow(
                    icon:
                        Icons.check_circle_outline,
                    title: 'Approved on',
                    value: _formatDateTime(
                      leave.approvedAt,
                    ),
                    color: Colors.green,
                  ),
                ],

                // REJECTION
                if (status == 'REJECTED' &&
                    leave.rejectionReason != null &&
                    leave.rejectionReason!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 13),
                  _buildRejectionBox(
                    leave.rejectionReason!,
                  ),
                ],
              ],
            ),
          ),

          // ACTIONS
          if (isPending)
            _buildPendingActions(leave),
        ],
      ),
    );
  }

  Widget _statusBadge(
    String status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 6,
            width: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _prettyStatus(status),
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          height: 28,
          width: 28,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: 0.09,
            ),
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: color,
            size: 15,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  color: const Color(0xff3A4354),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionBox(
    String reason,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xfffff5f5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.red.withValues(
            alpha: 0.10,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: Colors.red.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.red.shade600,
              size: 17,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Rejection Reason',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.4,
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingActions(
    TeacherLeaveModel leave,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFBFCFE),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: Icons.edit_rounded,
              label: 'Edit Request',
              color: primaryColor,
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _showApplyLeaveDialog(
                        existingLeave: leave,
                      );
                    },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: Colors.red.shade600,
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _confirmDelete(leave);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
      ),
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: color.withValues(
            alpha: 0.25,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // FLOATING BUTTON
  // ============================================================

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed:
          _isSubmitting
              ? null
              : () => _showApplyLeaveDialog(),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 7,
      icon: const Icon(
        Icons.add_rounded,
      ),
      label: Text(
        'Apply Leave',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // APPLY / EDIT DIALOG
  // ============================================================

  Future<void> _showApplyLeaveDialog({
    TeacherLeaveModel? existingLeave,
  }) async {
    final isEdit = existingLeave != null;

    String selectedLeaveType =
        _normaliseLeaveType(
      existingLeave?.leaveType,
    );

    final leaveTypeController =
        TextEditingController(
      text: existingLeave != null &&
              !_leaveTypes.contains(
                existingLeave.leaveType,
              )
          ? existingLeave.leaveType
          : '',
    );

    final reasonController =
        TextEditingController(
      text: existingLeave?.reason ?? '',
    );

    DateTime startDate =
        existingLeave?.startDate ??
            DateTime.now();

    DateTime endDate =
        existingLeave?.endDate ??
            DateTime.now();

    final formKey =
        GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            final isOther =
                selectedLeaveType == 'Other';

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              child: Container(
                constraints:
                    const BoxConstraints(
                  maxWidth: 520,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(26),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildDialogHeader(
                          isEdit,
                          dialogContext,
                        ),

                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            22,
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Leave Details',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      const Color(
                                    0xff1B2433,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),

                              // LEAVE TYPE
                              DropdownButtonFormField<
                                  String>(
                                value:
                                    selectedLeaveType,
                                isExpanded: true,
                                decoration:
                                    _inputDecoration(
                                  'Leave Type',
                                  Icons
                                      .category_outlined,
                                ),
                                items: _leaveTypes
                                    .map(
                                      (
                                        type,
                                      ) {
                                        return DropdownMenuItem<
                                            String>(
                                          value: type,
                                          child: Text(
                                            type,
                                            style:
                                                GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    .toList(),
                                onChanged:
                                    (value) {
                                  if (value ==
                                      null) {
                                    return;
                                  }

                                  setDialogState(() {
                                    selectedLeaveType =
                                        value;
                                  });
                                },
                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .trim()
                                          .isEmpty) {
                                    return 'Please select leave type';
                                  }
                                  return null;
                                },
                              ),

                              if (isOther) ...[
                                const SizedBox(
                                  height: 12,
                                ),
                                TextFormField(
                                  controller:
                                      leaveTypeController,
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 12,
                                  ),
                                  decoration:
                                      _inputDecoration(
                                    'Enter leave type',
                                    Icons.edit_note_rounded,
                                  ),
                                  validator:
                                      (value) {
                                    if (selectedLeaveType ==
                                            'Other' &&
                                        (value == null ||
                                            value
                                                .trim()
                                                .isEmpty)) {
                                      return 'Enter leave type';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              const SizedBox(
                                height: 16,
                              ),

                              Text(
                                'Leave Period',
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      Colors.grey.shade700,
                                ),
                              ),

                              const SizedBox(
                                height: 9,
                              ),

                              // DATES
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        _datePickerField(
                                      context,
                                      title:
                                          'Start Date',
                                      date:
                                          startDate,
                                      onTap:
                                          () async {
                                        final today =
                                            DateTime(
                                          DateTime.now()
                                              .year,
                                          DateTime.now()
                                              .month,
                                          DateTime.now()
                                              .day,
                                        );

                                        DateTime initial =
                                            startDate;

                                        if (initial
                                            .isBefore(
                                          today,
                                        )) {
                                          initial =
                                              today;
                                        }

                                        final selected =
                                            await showDatePicker(
                                          context:
                                              context,
                                          initialDate:
                                              initial,
                                          firstDate:
                                              isEdit &&
                                                      existingLeave!
                                                          .startDate
                                                          .isBefore(
                                                        today,
                                                      )
                                                  ? existingLeave
                                                      .startDate
                                                  : today,
                                          lastDate:
                                              today.add(
                                            const Duration(
                                              days: 365,
                                            ),
                                          ),
                                        );

                                        if (selected !=
                                            null) {
                                          setDialogState(
                                            () {
                                              startDate =
                                                  selected;

                                              if (endDate
                                                  .isBefore(
                                                startDate,
                                              )) {
                                                endDate =
                                                    startDate;
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child:
                                        _datePickerField(
                                      context,
                                      title:
                                          'End Date',
                                      date:
                                          endDate,
                                      onTap:
                                          () async {
                                        DateTime initial =
                                            endDate;

                                        if (initial
                                            .isBefore(
                                          startDate,
                                        )) {
                                          initial =
                                              startDate;
                                        }

                                        final selected =
                                            await showDatePicker(
                                          context:
                                              context,
                                          initialDate:
                                              initial,
                                          firstDate:
                                              startDate,
                                          lastDate:
                                              DateTime.now()
                                                  .add(
                                            const Duration(
                                              days: 365,
                                            ),
                                          ),
                                        );

                                        if (selected !=
                                            null) {
                                          setDialogState(
                                            () {
                                              endDate =
                                                  selected;
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: 12,
                              ),

                              // DURATION
                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 13,
                                  vertical: 10,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      const Color(
                                    0xffEEF6FF,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    13,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .timelapse_rounded,
                                      color:
                                          primaryColor,
                                      size: 19,
                                    ),
                                    const SizedBox(
                                      width: 9,
                                    ),
                                    Text(
                                      'Leave Duration',
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors
                                            .grey
                                            .shade600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '${_calculateDays(startDate, endDate)} ${_calculateDays(startDate, endDate) == 1 ? 'Day' : 'Days'}',
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight
                                                .w800,
                                        color:
                                            primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              TextFormField(
                                controller:
                                    reasonController,
                                maxLines: 4,
                                style:
                                    GoogleFonts.poppins(
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                decoration:
                                    _inputDecoration(
                                  'Reason (optional)',
                                  Icons
                                      .description_outlined,
                                ).copyWith(
                                  alignLabelWithHint:
                                      true,
                                ),
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        OutlinedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          dialogContext,
                                        );
                                      },
                                      style:
                                          OutlinedButton
                                              .styleFrom(
                                        foregroundColor:
                                            Colors.grey
                                                .shade700,
                                        side:
                                            BorderSide(
                                          color: Colors
                                              .grey
                                              .shade300,
                                        ),
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          vertical: 13,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            13,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        style:
                                            GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child:
                                        ElevatedButton.icon(
                                      onPressed:
                                          _isSubmitting
                                              ? null
                                              : () async {
                                                  if (!formKey
                                                      .currentState!
                                                      .validate()) {
                                                    return;
                                                  }

                                                  if (endDate
                                                      .isBefore(
                                                    startDate,
                                                  )) {
                                                    _showMessage(
                                                      'End date cannot be before start date.',
                                                      Colors
                                                          .red,
                                                    );
                                                    return;
                                                  }

                                                  final finalLeaveType =
                                                      selectedLeaveType ==
                                                              'Other'
                                                          ? leaveTypeController
                                                              .text
                                                              .trim()
                                                          : selectedLeaveType;

                                                  Navigator.pop(
                                                    dialogContext,
                                                  );

                                                  await _submitLeave(
                                                    leaveType:
                                                        finalLeaveType,
                                                    startDate:
                                                        startDate,
                                                    endDate:
                                                        endDate,
                                                    reason:
                                                        reasonController
                                                            .text
                                                            .trim(),
                                                    existingLeave:
                                                        existingLeave,
                                                  );
                                                },
                                      icon:
                                          Icon(
                                        isEdit
                                            ? Icons
                                                .save_rounded
                                            : Icons
                                                .send_rounded,
                                        size: 17,
                                      ),
                                      label:
                                          Text(
                                        isEdit
                                            ? 'Save Changes'
                                            : 'Submit Request',
                                        style:
                                            GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                      style:
                                          ElevatedButton
                                              .styleFrom(
                                        backgroundColor:
                                            primaryColor,
                                        foregroundColor:
                                            Colors.white,
                                        elevation: 0,
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          vertical: 13,
                                        ),
                                        shape:
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    leaveTypeController.dispose();
    reasonController.dispose();
  }

  Widget _buildDialogHeader(
    bool isEdit,
    BuildContext dialogContext,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        14,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            primaryColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(26),
          topRight: Radius.circular(26),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.14,
              ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              isEdit
                  ? Icons.edit_calendar_rounded
                  : Icons.event_available_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit
                      ? 'Edit Leave Request'
                      : 'Apply for Leave',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isEdit
                      ? 'Update your pending request'
                      : 'Submit a new leave request',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withValues(
                      alpha: 0.72,
                    ),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submitLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    TeacherLeaveModel? existingLeave,
  }) async {
    try {
      if (!mounted) return;

      setState(() {
        _isSubmitting = true;
      });

      final token = await AuthStorage.getToken();
      final teacherId =
          await AuthStorage.getTeacherId();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login session expired. Please login again.',
        );
      }

      if (teacherId == null) {
        throw Exception(
          'Teacher ID not found. Please login again.',
        );
      }

      final service =
          TeacherLeaveService(token);

      if (existingLeave == null) {
        await service.applyLeave(
          teacherId: teacherId,
          leaveType: leaveType,
          startDate: startDate,
          endDate: endDate,
          reason:
              reason.isEmpty ? null : reason,
        );
      } else {
        await service.updateLeave(
          leaveId: existingLeave.id,
          teacherId: teacherId,
          leaveType: leaveType,
          startDate: startDate,
          endDate: endDate,
          reason:
              reason.isEmpty ? null : reason,
        );
      }

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        existingLeave == null
            ? 'Leave request submitted successfully.'
            : 'Leave request updated successfully.',
        Colors.green,
      );

      await _loadLeaves();
    } catch (e) {
      debugPrint(
        'SUBMIT LEAVE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        _friendlyError(e),
        Colors.red,
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _confirmDelete(
    TeacherLeaveModel leave,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(
                      alpha: 0.10,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red.shade600,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Delete Leave Request?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'This pending leave request will be permanently deleted.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.grey.shade700,
                          side: BorderSide(
                            color:
                                Colors.grey.shade300,
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        child:
                            const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red.shade600,
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        child:
                            const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed != true) return;

    try {
      if (!mounted) return;

      setState(() {
        _isSubmitting = true;
      });

      final token = await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login session expired. Please login again.',
        );
      }

      final service =
          TeacherLeaveService(token);

      await service.deleteLeave(leave.id);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        'Leave request deleted successfully.',
        Colors.green,
      );

      await _loadLeaves();
    } catch (e) {
      debugPrint(
        'DELETE LEAVE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showMessage(
        _friendlyError(e),
        Colors.red,
      );
    }
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _datePickerField(
    BuildContext context, {
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xffF6F8FB),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 34,
              width: 34,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.09,
                ),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: primaryColor,
                size: 17,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 8,
                      color: Colors.grey.shade500,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date),
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          const Color(0xff252D3A),
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

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState(
    String status,
  ) {
    final color = _statusColor(status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 35,
      ),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.08,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _emptyIcon(status),
              size: 42,
              color: color.withValues(
                alpha: 0.65,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _searchText.isEmpty
                ? 'No ${status.toLowerCase()} requests'
                : 'No matching requests',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xff222B3A),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _emptyDescription(status),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _emptyDescription(
    String status,
  ) {
    if (_searchText.isNotEmpty) {
      return 'Try searching with a different leave type or reason.';
    }

    switch (status) {
      case 'PENDING':
        return 'Your submitted leave requests waiting for approval will appear here.';
      case 'APPROVED':
        return 'Once your leave is approved, it will appear here.';
      case 'REJECTED':
        return 'Rejected leave requests will appear here with the rejection reason.';
      default:
        return 'No leave requests found.';
    }
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        100,
      ),
      children: [
        _skeleton(
          height: 48,
          radius: 17,
        ),
        const SizedBox(height: 14),
        _skeleton(
          height: 250,
          radius: 22,
        ),
        const SizedBox(height: 14),
        _skeleton(
          height: 230,
          radius: 22,
        ),
        const SizedBox(height: 14),
        _skeleton(
          height: 230,
          radius: 22,
        ),
      ],
    );
  }

  Widget _skeleton({
    required double height,
    required double radius,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(radius),
      ),
      child: const Center(
        child: SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return RefreshIndicator(
      color: primaryColor,
      onRefresh: _loadLeaves,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(
                      alpha: 0.08,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 34,
                    color: Colors.red.shade500,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Unable to load requests',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _errorMessage ??
                      'Something went wrong.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    height: 1.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadLeaves,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 17,
                    ),
                    label: const Text('Try Again'),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          primaryColor,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 11,
        color: Colors.grey.shade500,
      ),
      prefixIcon: Icon(
        icon,
        color: primaryColor,
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xffF6F8FB),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade100,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.2,
        ),
      ),
    );
  }

  Color _statusColor(
    String status,
  ) {
    switch (status) {
      case 'APPROVED':
        return Colors.green.shade600;
      case 'REJECTED':
        return Colors.red.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _leaveTypeIcon(
    String type,
  ) {
    final value = type.toLowerCase();

    if (value.contains('sick') ||
        value.contains('medical')) {
      return Icons.medical_services_rounded;
    }

    if (value.contains('emergency')) {
      return Icons.emergency_rounded;
    }

    if (value.contains('personal')) {
      return Icons.person_rounded;
    }

    if (value.contains('casual')) {
      return Icons.beach_access_rounded;
    }

    if (value.contains('earned')) {
      return Icons.card_giftcard_rounded;
    }

    return Icons.event_note_rounded;
  }

  IconData _emptyIcon(
    String status,
  ) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty_rounded;
      case 'APPROVED':
        return Icons.check_circle_outline_rounded;
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.event_busy_rounded;
    }
  }

  String _prettyStatus(
    String status,
  ) {
    if (status.isEmpty) {
      return 'Pending';
    }

    return status[0] +
        status.substring(1).toLowerCase();
  }

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateRange(
    DateTime start,
    DateTime end,
  ) {
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return _formatDate(start);
    }

    if (start.year == end.year &&
        start.month == end.month) {
      return '${start.day} → ${end.day} ${_monthName(end.month)} ${end.year}';
    }

    return '${_formatDate(start)}  →  ${_formatDate(end)}';
  }

  String _monthName(
    int month,
  ) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  String _formatDateTime(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return 'Date unavailable';
    }

    final hour = dateTime.hour == 0
        ? 12
        : dateTime.hour > 12
            ? dateTime.hour - 12
            : dateTime.hour;

    final minute =
        dateTime.minute.toString().padLeft(
              2,
              '0',
            );

    final period =
        dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${_formatDate(dateTime)}, $hour:$minute $period';
  }

  int _calculateDays(
    DateTime start,
    DateTime end,
  ) {
    final startOnly = DateTime(
      start.year,
      start.month,
      start.day,
    );

    final endOnly = DateTime(
      end.year,
      end.month,
      end.day,
    );

    final difference =
        endOnly.difference(startOnly).inDays;

    return difference < 0
        ? 0
        : difference + 1;
  }

  String _normaliseLeaveType(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Casual Leave';
    }

    if (_leaveTypes.contains(value)) {
      return value;
    }

    return 'Other';
  }

  String _friendlyError(
    dynamic error,
  ) {
    if (error is Exception) {
      final message =
          error.toString();

      if (message.contains(
        'already has leave',
      )) {
        return 'You already have leave during this period.';
      }

      if (message.contains(
        'pending leave',
      )) {
        return 'Only pending leave requests can be modified.';
      }

      if (message.contains(
        '401',
      )) {
        return 'Your login session has expired. Please login again.';
      }

      return message
          .replaceFirst('Exception: ', '');
    }

    return error.toString();
  }

  void _showMessage(
    String message,
    Color color,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == Colors.green
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior:
              SnackBarBehavior.floating,
          margin: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      );
  }
}