import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/homework_model.dart';
import '../services/homework_service.dart';
import '../auth/auth_storage.dart';

class HomeworkScreen extends StatefulWidget {
  final int classId;
  final String className;

  final int subjectId;
  final String subject;

  // Assigned section - teacher cannot change this.
  final int sectionId;
  final String sectionName;

  const HomeworkScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.subjectId,
    required this.subject,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  static const Color primaryColor = Color(0xff1565C0);
  static const Color secondaryColor = Color(0xff42A5F5);
  static const Color backgroundColor = Color(0xffF5F8FC);
  static const Color textColor = Color(0xff172033);

  String? token;
  int? teacherId;

  late HomeworkService homeworkService;

  List<HomeworkModel> homeworkList = [];

  bool loadingHomework = false;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      token = await AuthStorage.getToken();
      teacherId = await AuthStorage.getTeacherId();

      if (token == null || teacherId == null) {
        throw Exception(
          'Teacher session not found. Please login again.',
        );
      }

      homeworkService = HomeworkService(token!);

      initialized = true;

      await _loadHomework();
    } catch (e) {
      if (!mounted) return;

      _showMessage(e.toString());
    }
  }

  Future<void> _loadHomework() async {
    if (teacherId == null || !initialized) return;

    setState(() {
      loadingHomework = true;
    });

    try {
      final result =
          await homeworkService.getByTeacherClassAndSection(
        teacherId!,
        widget.classId,
        widget.sectionId,
      );

      if (!mounted) return;

      setState(() {
        homeworkList = result;
        loadingHomework = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingHomework = false;
      });

      _showMessage(e.toString());
    }
  }

  String _formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '-';
    }

    final parsed = DateTime.tryParse(date);

    if (parsed == null) {
      return date;
    }

    return '${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} '
        '${parsed.year}';
  }

  String _monthName(int month) {
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

    if (month < 1 || month > 12) {
      return '';
    }

    return months[month - 1];
  }

  Future<void> _showAddHomework() async {
    await _showHomeworkForm();
  }

  Future<void> _showEditHomework(
    HomeworkModel homework,
  ) async {
    await _showHomeworkForm(
      homework: homework,
    );
  }

  Future<void> _showHomeworkForm({
    HomeworkModel? homework,
  }) async {
    final titleController = TextEditingController(
      text: homework?.title ?? '',
    );

    final descriptionController = TextEditingController(
      text: homework?.description ?? '',
    );

    final attachmentController = TextEditingController(
      text: homework?.attachmentUrl ?? '',
    );

    DateTime selectedDate;

    if (homework?.dueDate != null &&
        homework!.dueDate!.isNotEmpty) {
      selectedDate =
          DateTime.tryParse(homework.dueDate!) ??
              DateTime.now().add(
                const Duration(days: 1),
              );
    } else {
      selectedDate = DateTime.now().add(
        const Duration(days: 1),
      );
    }

    String selectedPriority =
        (homework?.priority ?? 'MEDIUM').toUpperCase();

    String selectedStatus =
        (homework?.status ?? 'ACTIVE').toUpperCase();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height * 0.92,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 22,
                    right: 22,
                    top: 12,
                    bottom:
                        MediaQuery.of(context).viewInsets.bottom +
                            18,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 45,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                  colors: [
                                    primaryColor,
                                    secondaryColor,
                                  ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homework == null
                                        ? 'Create Homework'
                                        : 'Edit Homework',
                                    style:
                                        GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    '${widget.className} • '
                                    '${widget.subject} • '
                                    'Section ${widget.sectionName}',
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style:
                                        GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Locked assignment information.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xffEAF4FF),
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  const Color(0xffD5E9FA),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 38,
                                width: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: primaryColor,
                                  size: 19,
                                ),
                              ),

                              const SizedBox(width: 11),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assigned Section',
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Text(
                                      'Section ${widget.sectionName}',
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        _formLabel('Homework Title'),

                        const SizedBox(height: 8),

                        _premiumField(
                          controller: titleController,
                          hint: 'Enter homework title',
                          icon: Icons.title_rounded,
                        ),

                        const SizedBox(height: 16),

                        _formLabel('Description'),

                        const SizedBox(height: 8),

                        _premiumField(
                          controller:
                              descriptionController,
                          hint:
                              'Write homework instructions...',
                          icon: Icons.notes_rounded,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 16),

                        _formLabel('Due Date'),

                        const SizedBox(height: 8),

                        InkWell(
                          borderRadius:
                              BorderRadius.circular(16),
                          onTap: () async {
                            final now = DateTime.now();

                            final firstDate = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );

                            final initialDate =
                                selectedDate.isBefore(
                              firstDate,
                            )
                                    ? firstDate
                                    : selectedDate;

                            final picked =
                                await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: firstDate,
                              lastDate:
                                  DateTime(2100),
                            );

                            if (picked != null) {
                              setSheetState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xffE3F2FD,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons
                                        .calendar_month_rounded,
                                    color: primaryColor,
                                    size: 21,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Due Date',
                                        style:
                                            GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors
                                              .grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(
                                          selectedDate
                                              .toIso8601String(),
                                        ),
                                        style:
                                            GoogleFonts.poppins(
                                          fontWeight:
                                              FontWeight.w600,
                                          color: textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .chevron_right_rounded,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _premiumDropdown(
                                label: 'Priority',
                                value:
                                    selectedPriority,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'LOW',
                                    child:
                                        Text('Low'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'MEDIUM',
                                    child:
                                        Text('Medium'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'HIGH',
                                    child:
                                        Text('High'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setSheetState(() {
                                      selectedPriority =
                                          value;
                                    });
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _premiumDropdown(
                                label: 'Status',
                                value:
                                    selectedStatus,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'ACTIVE',
                                    child:
                                        Text('Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'COMPLETED',
                                    child:
                                        Text('Completed'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'CANCELLED',
                                    child:
                                        Text('Cancelled'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setSheetState(() {
                                      selectedStatus =
                                          value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        _formLabel('Attachment URL'),

                        const SizedBox(height: 8),

                        _premiumField(
                          controller:
                              attachmentController,
                          hint:
                              'Optional attachment link',
                          icon:
                              Icons.attach_file_rounded,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style:
                                ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  primaryColor,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  17,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              if (titleController.text
                                  .trim()
                                  .isEmpty) {
                                _showMessage(
                                  'Please enter homework title',
                                );
                                return;
                              }

                              if (teacherId == null) {
                                _showMessage(
                                  'Teacher information missing',
                                );
                                return;
                              }

                              final dueDate =
                                  '${selectedDate.year}-'
                                  '${selectedDate.month.toString().padLeft(2, '0')}-'
                                  '${selectedDate.day.toString().padLeft(2, '0')}';

                              try {
                                Navigator.pop(
                                  sheetContext,
                                );

                                if (homework == null) {
                                  await homeworkService
                                      .createHomework(
                                    classId:
                                        widget.classId,
                                    sectionId:
                                        widget.sectionId,
                                    teacherId:
                                        teacherId!,
                                    subjectId:
                                        widget.subjectId,
                                    title:
                                        titleController
                                            .text
                                            .trim(),
                                    description:
                                        descriptionController
                                            .text
                                            .trim(),
                                    dueDate:
                                        dueDate,
                                    status:
                                        selectedStatus,
                                    attachmentUrl:
                                        attachmentController
                                                .text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : attachmentController
                                                .text
                                                .trim(),
                                    priority:
                                        selectedPriority,
                                  );
                                } else {
                                  await homeworkService
                                      .updateHomework(
                                    id: homework.id!,
                                    classId:
                                        widget.classId,
                                    sectionId:
                                        widget.sectionId,
                                    teacherId:
                                        teacherId!,
                                    subjectId:
                                        homework.subjectId ??
                                            widget.subjectId,
                                    title:
                                        titleController
                                            .text
                                            .trim(),
                                    description:
                                        descriptionController
                                            .text
                                            .trim(),
                                    dueDate:
                                        dueDate,
                                    status:
                                        selectedStatus,
                                    attachmentUrl:
                                        attachmentController
                                                .text
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : attachmentController
                                                .text
                                                .trim(),
                                    priority:
                                        selectedPriority,
                                  );
                                }

                                await _loadHomework();

                                if (!mounted) return;

                                _showMessage(
                                  homework == null
                                      ? 'Homework created successfully'
                                      : 'Homework updated successfully',
                                );
                              } catch (e) {
                                if (!mounted) return;

                                _showMessage(
                                  e.toString(),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  homework == null
                                      ? Icons
                                          .publish_rounded
                                      : Icons.save_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),

                                const SizedBox(width: 9),

                                Text(
                                  homework == null
                                      ? 'Publish Homework'
                                      : 'Update Homework',
                                  style:
                                      GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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

    titleController.dispose();
    descriptionController.dispose();
    attachmentController.dispose();
  }

  Widget _formLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  Widget _premiumField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontSize: 13,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: maxLines > 1 ? 0 : 4,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _premiumDropdown({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>>
        items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      items: items,
      onChanged: onChanged,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Future<void> _deleteHomework(
    HomeworkModel homework,
  ) async {
    final shouldDelete =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),
          title: Text(
            'Delete Homework?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          content: Text(
            'Delete "${homework.title ?? 'this homework'}"?',
            style: GoogleFonts.poppins(
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red.shade600,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                'Delete',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true ||
        homework.id == null) {
      return;
    }

    try {
      await homeworkService.deleteHomework(
        homework.id!,
      );

      await _loadHomework();

      if (!mounted) return;

      _showMessage(
        'Homework deleted successfully',
      );
    } catch (e) {
      _showMessage(
        e.toString(),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message.replaceFirst(
            'Exception: ',
            '',
          ),
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight:
                FontWeight.w500,
          ),
        ),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(14),
        ),
      ),
    );
  }

  int _activeCount() {
    return homeworkList
        .where(
          (item) =>
              (item.status ?? '')
                  .toUpperCase() ==
              'ACTIVE',
        )
        .length;
  }

  int _completedCount() {
    return homeworkList
        .where(
          (item) =>
              (item.status ?? '')
                  .toUpperCase() ==
              'COMPLETED',
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        surfaceTintColor:
            Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          'Homework',
          style:
              GoogleFonts.poppins(
            color: textColor,
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed:
                _loadHomework,
            icon: const Icon(
              Icons.refresh_rounded,
              color: textColor,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _loadHomework,
        child: CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding:
                  const EdgeInsets.fromLTRB(
                18,
                8,
                18,
                110,
              ),
              sliver: SliverList(
                delegate:
                    SliverChildListDelegate([
                  _buildHeaderCard(),

                  const SizedBox(height: 16),

                  _buildAssignedSectionCard(),

                  const SizedBox(height: 22),

                  _buildHomeworkHeader(),

                  const SizedBox(height: 14),

                  if (loadingHomework)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child:
                            CircularProgressIndicator(
                          color:
                              primaryColor,
                        ),
                      ),
                    )
                  else if (homeworkList
                      .isEmpty)
                    _buildEmptyState()
                  else
                    ...homeworkList.map(
                      (homework) =>
                          _homeworkCard(
                        homework,
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        elevation: 6,
        backgroundColor:
            primaryColor,
        onPressed:
            _showAddHomework,
        icon: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
        label: Text(
          'Add Homework',
          style:
              GoogleFonts.poppins(
            color: Colors.white,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            primaryColor,
            Color(0xff1976D2),
            secondaryColor,
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primaryColor
                .withOpacity(0.20),
            blurRadius: 20,
            offset:
                const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.18),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color:
                      Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      widget.className,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                        height: 2),

                    Text(
                      widget.subject,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts.poppins(
                        color: Colors
                            .white
                            .withOpacity(
                                0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding:
                const EdgeInsets.all(13),
            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(
                      0.12),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
              border: Border.all(
                color: Colors.white
                    .withOpacity(
                        0.14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      _headerStat(
                    Icons
                        .assignment_rounded,
                    '${homeworkList.length}',
                    'Total',
                  ),
                ),

                Container(
                  width: 1,
                  height: 35,
                  color: Colors.white
                      .withOpacity(
                          0.18),
                ),

                Expanded(
                  child:
                      _headerStat(
                    Icons
                        .play_circle_fill_rounded,
                    '${_activeCount()}',
                    'Active',
                  ),
                ),

                Container(
                  width: 1,
                  height: 35,
                  color: Colors.white
                      .withOpacity(
                          0.18),
                ),

                Expanded(
                  child:
                      _headerStat(
                    Icons
                        .check_circle_rounded,
                    '${_completedCount()}',
                    'Done',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedSectionCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color:
              const Color(0xffE1E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xffE3F2FD),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color:
                  primaryColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Assigned Section',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors
                        .grey.shade600,
                  ),
                ),
                const SizedBox(
                    height: 2),
                Text(
                  'Section ${widget.sectionName}',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        textColor,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xffE8F5E9),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Text(
              'LOCKED',
              style:
                  GoogleFonts.poppins(
                fontSize: 9,
                fontWeight:
                    FontWeight.w700,
                color:
                    Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(
    IconData icon,
    String value,
    String label,
  ) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.white
              .withOpacity(0.9),
          size: 19,
        ),

        const SizedBox(width: 7),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Text(
              value,
              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white,
                fontWeight:
                    FontWeight.w700,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style:
                  GoogleFonts.poppins(
                color: Colors.white
                    .withOpacity(
                        0.72),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHomeworkHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                'Assigned Homework',
                style:
                    GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      textColor,
                ),
              ),

              const SizedBox(
                  height: 2),

              Text(
                'Manage tasks for Section ${widget.sectionName}',
                style:
                    GoogleFonts.poppins(
                  fontSize: 11,
                  color:
                      Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (homeworkList.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0xffE3F2FD),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Text(
              '${homeworkList.length} Tasks',
              style:
                  GoogleFonts.poppins(
                color:
                    primaryColor,
                fontSize: 11,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 42,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 78,
            width: 78,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xffE3F2FD),
              borderRadius:
                  BorderRadius.circular(
                24,
              ),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color:
                  primaryColor,
              size: 38,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'No Homework Yet',
            style:
                GoogleFonts.poppins(
              fontSize: 17,
              fontWeight:
                  FontWeight.w700,
              color:
                  textColor,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Create the first homework task for Section ${widget.sectionName}.',
            textAlign:
                TextAlign.center,
            style:
                GoogleFonts.poppins(
              fontSize: 12,
              color:
                  Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  primaryColor,
              elevation: 0,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
            ),
            onPressed:
                _showAddHomework,
            icon: const Icon(
              Icons.add_rounded,
              color:
                  Colors.white,
              size: 19,
            ),
            label: Text(
              'Add Homework',
              style:
                  GoogleFonts.poppins(
                color:
                    Colors.white,
                fontWeight:
                    FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeworkCard(
    HomeworkModel homework,
  ) {
    final priority =
        (homework.priority ??
                'MEDIUM')
            .toUpperCase();

    final status =
        (homework.status ??
                'ACTIVE')
            .toUpperCase();

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.035),
            blurRadius: 12,
            offset:
                const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration:
                    BoxDecoration(
                  gradient:
                      const LinearGradient(
                    colors: [
                      Color(
                          0xffE3F2FD),
                      Color(
                          0xffBBDEFB),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color:
                      primaryColor,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      homework.title ??
                          'Untitled Homework',
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            textColor,
                      ),
                    ),

                    const SizedBox(
                        height: 3),

                    Text(
                      homework.subjectName ??
                          widget.subject,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                padding:
                    EdgeInsets.zero,
                icon: Icon(
                  Icons
                      .more_vert_rounded,
                  color: Colors
                      .grey.shade600,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),
                onSelected:
                    (value) {
                  if (value ==
                      'edit') {
                    _showEditHomework(
                      homework,
                    );
                  } else if (value ==
                      'delete') {
                    _deleteHomework(
                      homework,
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .edit_rounded,
                          size: 18,
                          color:
                              primaryColor,
                        ),
                        const SizedBox(
                            width: 10),
                        Text(
                          'Edit',
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize:
                                13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value:
                        'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .delete_outline_rounded,
                          size: 18,
                          color: Colors
                              .red
                              .shade600,
                        ),
                        const SizedBox(
                            width: 10),
                        Text(
                          'Delete',
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize:
                                13,
                            color: Colors
                                .red
                                .shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          if ((homework
                      .description ??
                  '')
              .isNotEmpty)
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                12,
              ),
              decoration:
                  BoxDecoration(
                color:
                    backgroundColor,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Text(
                homework
                    .description!,
                maxLines: 3,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors
                      .grey.shade700,
                  height: 1.45,
                ),
              ),
            ),

          if ((homework
                      .description ??
                  '')
              .isNotEmpty)
            const SizedBox(
                height: 13),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                Icons.school_rounded,
                '${homework.className ?? widget.className}'
                ' • Section ${homework.sectionName ?? widget.sectionName}',
              ),

              _infoChip(
                Icons
                    .calendar_today_rounded,
                _formatDate(
                  homework.dueDate,
                ),
              ),

              _statusChip(
                Icons.flag_rounded,
                _priorityLabel(
                  priority,
                ),
                _priorityColor(
                  priority,
                ),
              ),

              _statusChip(
                status == 'COMPLETED'
                    ? Icons
                        .check_circle_rounded
                    : status ==
                            'CANCELLED'
                        ? Icons
                            .cancel_rounded
                        : Icons
                            .play_circle_fill_rounded,
                _statusLabel(
                  status,
                ),
                _statusColor(
                  status,
                ),
              ),
            ],
          ),

          if ((homework
                      .attachmentUrl ??
                  '')
              .isNotEmpty) ...[
            const SizedBox(
                height: 13),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xffF3F7FB,
                ),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .attach_file_rounded,
                    color:
                        primaryColor,
                    size: 18,
                  ),

                  const SizedBox(
                      width: 8),

                  Expanded(
                    child: Text(
                      'Attachment available',
                      style:
                          GoogleFonts
                              .poppins(
                        fontSize: 11,
                        color:
                            primaryColor,
                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons
                        .open_in_new_rounded,
                    size: 16,
                    color:
                        primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color:
            backgroundColor,
        borderRadius:
            BorderRadius.circular(
          11,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                primaryColor,
          ),
          const SizedBox(
              width: 6),
          Text(
            text,
            style:
                GoogleFonts.poppins(
              fontSize: 10,
              color:
                  Colors.grey.shade700,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(
    IconData icon,
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color: color.withOpacity(
            0.09),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(
              width: 6),
          Text(
            text,
            style:
                GoogleFonts.poppins(
              fontSize: 10,
              color: color,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _priorityLabel(
    String value,
  ) {
    switch (value) {
      case 'HIGH':
        return 'High Priority';
      case 'LOW':
        return 'Low Priority';
      default:
        return 'Medium Priority';
    }
  }

  Color _priorityColor(
    String value,
  ) {
    switch (value) {
      case 'HIGH':
        return Colors.red.shade600;
      case 'LOW':
        return Colors.green.shade600;
      default:
        return Colors.orange.shade700;
    }
  }

  String _statusLabel(
    String value,
  ) {
    switch (value) {
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Active';
    }
  }

  Color _statusColor(
    String value,
  ) {
    switch (value) {
      case 'COMPLETED':
        return Colors.green.shade600;
      case 'CANCELLED':
        return Colors.red.shade600;
      default:
        return primaryColor;
    }
  }
}