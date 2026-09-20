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

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    _searchController.addListener(() {
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

  Future<void> _loadLeaves() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final token = await AuthStorage.getToken();
      final teacherId =
          await AuthStorage.getTeacherId();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login token not found. Please login again.',
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

      final service =
          TeacherLeaveService(token);

      final leaves =
          await service.getMyLeaves(teacherId);

      leaves.sort(
        (a, b) => b.startDate.compareTo(
          a.startDate,
        ),
      );

      if (!mounted) return;

      setState(() {
        _leaveRequests = leaves;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD LEAVES ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  int get pendingCount =>
      _leaveRequests
          .where(
            (leave) =>
                leave.status.toUpperCase() ==
                'PENDING',
          )
          .length;

  int get approvedCount =>
      _leaveRequests
          .where(
            (leave) =>
                leave.status.toUpperCase() ==
                'APPROVED',
          )
          .length;

  int get rejectedCount =>
      _leaveRequests
          .where(
            (leave) =>
                leave.status.toUpperCase() ==
                'REJECTED',
          )
          .length;

  List<TeacherLeaveModel> _filteredLeaves(
    String status,
  ) {
    return _leaveRequests.where((leave) {
      if (leave.status.toUpperCase() !=
          status) {
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
          (leave.rejectionReason ?? '')
              .toLowerCase();

      return leaveType.contains(_searchText) ||
          reason.contains(_searchText) ||
          rejectionReason.contains(
            _searchText,
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF5F8FC),
      appBar: AppBar(
        backgroundColor:
            const Color(0xff1565C0),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'My Leave',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor:
              Colors.white70,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xff1565C0),
        foregroundColor: Colors.white,
        onPressed:
            _isSubmitting ? null : _showApplyLeaveDialog,
        icon: const Icon(Icons.add),
        label: Text(
          'Apply Leave',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search leave type or reason',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 12,
                ),
                prefixIcon:
                    const Icon(Icons.search),
                suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController
                                  .clear();
                            },
                            icon: const Icon(
                              Icons.clear,
                            ),
                          )
                        : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(18),
                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Pending',
                    pendingCount.toString(),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Approved',
                    approvedCount.toString(),
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'Rejected',
                    rejectedCount.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : _errorMessage != null
                    ? _buildError()
                    : TabBarView(
                        controller:
                            _tabController,
                        children: [
                          _buildLeaveList(
                            'PENDING',
                          ),
                          _buildLeaveList(
                            'APPROVED',
                          ),
                          _buildLeaveList(
                            'REJECTED',
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                color.withValues(alpha: 0.12),
            child: Text(
              count,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveList(
    String status,
  ) {
    final leaves =
        _filteredLeaves(status);

    if (leaves.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadLeaves,
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 130),
            Icon(
              _emptyIcon(status),
              size: 65,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            Text(
              _searchText.isEmpty
                  ? 'No ${status.toLowerCase()} leave requests'
                  : 'No matching leave requests',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status == 'PENDING'
                  ? 'Your submitted leave requests will appear here.'
                  : status == 'APPROVED'
                      ? 'Approved leave requests will appear here.'
                      : 'Rejected leave requests will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaves,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          18,
          4,
          18,
          100,
        ),
        physics:
            const AlwaysScrollableScrollPhysics(),
        itemCount: leaves.length,
        itemBuilder: (context, index) {
          return _buildLeaveCard(
            leaves[index],
          );
        },
      ),
    );
  }

  Widget _buildLeaveCard(
    TeacherLeaveModel leave,
  ) {
    final status =
        leave.status.toUpperCase();

    final statusColor =
        _statusColor(status);

    final isPending =
        status == 'PENDING';

    return Card(
      elevation: 2,
      margin:
          const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xffE3F2FD,
                    ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color:
                        Color(0xff1565C0),
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
                        style:
                            GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Applied ${_formatDateTime(leave.appliedAt ?? leave.createdAt)}',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors
                              .grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color: statusColor
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    _prettyStatus(status),
                    style:
                        GoogleFonts.poppins(
                      color: statusColor,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Container(
              padding:
                  const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color:
                    const Color(0xffF5F8FC),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color:
                        Color(0xff1565C0),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leave Period',
                          style:
                              GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors
                                .grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateRange(
                            leave.startDate,
                            leave.endDate,
                          ),
                          style:
                              GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (leave.reason != null &&
                leave.reason!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 19,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      leave.reason!,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors
                            .grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (status == 'APPROVED' &&
                leave.approvedBy != null) ...[
              const SizedBox(height: 12),
              _detailRow(
                Icons.verified_rounded,
                'Approved by',
                leave.approvedBy!,
                Colors.green,
              ),
            ],

            if (status == 'REJECTED' &&
                leave.rejectionReason !=
                    null &&
                leave.rejectionReason!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Colors.red.shade50,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Rejection Reason',
                            style:
                                GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors
                                  .red.shade700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            leave
                                .rejectionReason!,
                            style:
                                GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors
                                  .red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isPending) ...[
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () =>
                                  _showApplyLeaveDialog(
                                    existingLeave:
                                        leave,
                                  ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 18,
                      ),
                      label:
                          const Text('Edit'),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            const Color(
                          0xff1565C0,
                        ),
                        side:
                            const BorderSide(
                          color:
                              Color(0xff1565C0),
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
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _isSubmitting
                              ? null
                              : () =>
                                  _confirmDelete(
                                    leave,
                                  ),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                      ),
                      label:
                          const Text('Delete'),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            Colors.red,
                        side:
                            const BorderSide(
                          color: Colors.red,
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

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showApplyLeaveDialog({
    TeacherLeaveModel? existingLeave,
  }) async {
    final isEdit =
        existingLeave != null;

    final leaveTypeController =
        TextEditingController(
      text: existingLeave?.leaveType ?? '',
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
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              title: Text(
                isEdit
                    ? 'Edit Leave'
                    : 'Apply for Leave',
                style:
                    GoogleFonts.poppins(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller:
                            leaveTypeController,
                        decoration:
                            _inputDecoration(
                          'Leave Type',
                          Icons.category_outlined,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'Enter leave type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _datePickerField(
                        context,
                        title: 'Start Date',
                        date: startDate,
                        onTap: () async {
                          final selected =
                              await showDatePicker(
                            context: context,
                            initialDate:
                                startDate,
                            firstDate:
                                DateTime.now(),
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
                            setDialogState(() {
                              startDate =
                                  selected;

                              if (endDate
                                  .isBefore(
                                startDate,
                              )) {
                                endDate =
                                    startDate;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      _datePickerField(
                        context,
                        title: 'End Date',
                        date: endDate,
                        onTap: () async {
                          final selected =
                              await showDatePicker(
                            context: context,
                            initialDate:
                                endDate.isBefore(
                              startDate,
                            )
                                ? startDate
                                : endDate,
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
                            setDialogState(() {
                              endDate =
                                  selected;
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      TextFormField(
                        controller:
                            reasonController,
                        maxLines: 3,
                        decoration:
                            _inputDecoration(
                          'Reason (optional)',
                          Icons
                              .description_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancel'),
                ),
                ElevatedButton(
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
                                ScaffoldMessenger
                                    .of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'End date cannot be before start date.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(
                                dialogContext,
                              );

                              await _submitLeave(
                                leaveType:
                                    leaveTypeController
                                        .text
                                        .trim(),
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
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xff1565C0,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  child: Text(
                    isEdit
                        ? 'Update'
                        : 'Submit',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    leaveTypeController.dispose();
    reasonController.dispose();
  }

  Future<void> _submitLeave({
    required String leaveType,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    TeacherLeaveModel? existingLeave,
  }) async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      final token =
          await AuthStorage.getToken();
      final teacherId =
          await AuthStorage.getTeacherId();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login token not found.',
        );
      }

      if (teacherId == null) {
        throw Exception(
          'Teacher ID not found.',
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
        'Failed: $e',
        Colors.red,
      );
    }
  }

  Future<void> _confirmDelete(
    TeacherLeaveModel leave,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: Text(
            'Delete Leave?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this pending leave request?',
            style: GoogleFonts.poppins(
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final token =
          await AuthStorage.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Login token not found.',
        );
      }

      final service =
          TeacherLeaveService(token);

      await service.deleteLeave(
        leave.id,
      );

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
        'Failed to delete leave: $e',
        Colors.red,
      );
    }
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 12,
      ),
      prefixIcon: Icon(icon),
      filled: true,
      fillColor:
          const Color(0xffF5F8FC),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _datePickerField(
    BuildContext context, {
    required String title,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(13),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color:
              const Color(0xffF5F8FC),
          borderRadius:
              BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month,
              color:
                  Color(0xff1565C0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors
                          .grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(date),
                    style:
                        GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
            ),
          ],
        ),
      ),
    );
  }

  IconData _emptyIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty_rounded;
      case 'APPROVED':
        return Icons.check_circle_outline;
      default:
        return Icons.cancel_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _prettyStatus(String status) {
    if (status.isEmpty) {
      return 'Pending';
    }

    return status[0] +
        status.substring(1).toLowerCase();
  }

  String _formatDate(DateTime date) {
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

    return '${_formatDate(start)}  →  ${_formatDate(end)}';
  }

  String _formatDateTime(
    DateTime? dateTime,
  ) {
    if (dateTime == null) {
      return 'date unavailable';
    }

    final date = _formatDate(dateTime);

    final hour =
        dateTime.hour == 0
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
        dateTime.hour >= 12
            ? 'PM'
            : 'AM';

    return '$date, $hour:$minute $period';
  }

  Widget _buildError() {
    return RefreshIndicator(
      onRefresh: _loadLeaves,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 150),
          const Icon(
            Icons.cloud_off_outlined,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 15),
          Text(
            'Unable to load leave requests',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Text(
              _errorMessage ??
                  'Something went wrong.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color:
                    Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _loadLeaves,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xff1565C0,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Retry'),
            ),
          ),
        ],
      ),
    );
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
          content: Text(
            message,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: color,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }
}